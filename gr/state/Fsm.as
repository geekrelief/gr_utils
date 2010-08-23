package gr.state {

    import gr.debug.atrace;
    import flash.utils.describeType;
    import flash.utils.Dictionary;

    /**
    * The Fsm class represents a finite state machine and is the base class for the Hsm (hiearchical state machine).
    * The Fsm helps structure the state of your application by encapsulating the state of your program in functions.
    * Each state is a public function with a name that is prefixed with <code>s_</code>, takes a <code>Signal</code> parameter,
    * and returns an <code>int</code>.  State transitions are triggered by Signals, but a transition cannot occur on
    * a SIG_PARENT:<code>Signal.PARENT</code>, SIG_ENTER:<code>Signal.ENTER</code>, or SIG_EXIT:<code>Signal.EXIT</code>.
    * <p/>
    * The general structure of an Fsm state consists of a <code>switch</code> statement on the <code>Signal</code> parameter.
    * The cases represent "guards" where a signal is evaluated and either transitions the to another state, transitions to
    * a psuedo-state, or ignores the state.
    * <p/>
    * To transition to another state call and return the result of the <code>stran</code> method with the state to transition to.  
    * To consume or ignore a signal call and return the result of the <code>handled</code> method.
    * <p/>
    * To use the Fsm the initial state must be initialized.  You can either subclass Fsm and specify the initial state in the constructor,
    * or you can use composition and pass in the initial state method from a container class.  The latter allows for state injection
    * which is useful for objects that have states but must inherit from another base class (i.e. MovieClip). Any class using state
    * injection must implement the interface, IID, which is registered with the InMachineIndex.
    * <p/>
    * The InMachineIndex is a global variable of type MachineIndex which holds references to all instantiated machines for lookup.
    * It is possible to record a history of transitions and signals by setting the record property of the machine to true. 
    * <p/>
    * To 
    *
    */
    public class Fsm implements IID {
        public function Fsm(_initState:Function) {
            InMachineIndex.register(this);
            m_sIndex = new Dictionary();
            m_rsIndex = new Dictionary();
            indexStates(this);
            state = _initState;
        }

        include "inc/ret.inc"
        include "inc/signals.inc"

        /**
        * @internal Because AS3 does not allow variables in interfaces we need to define a getter and setter.
        */
        protected var m_id:int; 

        /**
        * The id of the state machine.
        */
        public function get id():int { return m_id; }
        public function set id(_id:int):void { m_id = _id; }
       
        /**
        * A lookup index mapping states to state names.
        */
        protected var m_sIndex:Dictionary;

        /**
        * A reverse lookup index mapping state names to states.
        */
        protected var m_rsIndex:Dictionary; 

        /**
        * A flag that tells the machine to record a history of transitions from state to state.
        */
        public var recording:Boolean;

        /**
        * The head of a linked list of transitions.
        */
        public var headT:TransitionNode;

        /**
        * @private
        */
        public var tailT:TransitionNode;

        /**
        * The current state.
        */
        public var state:Function;

        public function lookup(_stateName:String):StateContext {
            return m_rsIndex[_stateName];
        }

        /**
        * Used to initialize the Fsm.
        */
        public function init(_sindexTarget:IID = null):void {

            if (_sindexTarget != null) {
                if (_sindexTarget != this) {
                    InMachineIndex.register(_sindexTarget);
                }

                indexStates(_sindexTarget);
            }

            record(this, state, SIG_ENTER);

            state(SIG_ENTER);
        }

        /**
        * Records the state of the machine.
        *
        * @param fsm    An object implementing IID as the owner of the state.
        * @param state  A state of the fsm.
        * @param signal A signal that resulted in the transition to the state.
        */
        protected function record(_fsm:IID, _state:Function, _signal:Signal):void {
            if (recording) {
                if (headT != tailT) {
                    tailT.next = new TransitionNode(this, m_sIndex[state], _signal);
                    tailT = tailT.next;
                } else if (headT != null && headT == tailT) {
                    headT.next = tailT = new TransitionNode(this, m_sIndex[state], _signal);
                } else {
                    tailT = headT = new TransitionNode(this, m_sIndex[state], _signal);
                }
            }
        }

        /**
        * Prints a history of transitions.
        */
        public function printHistory():void {
            if(recording) {
                var node:TransitionNode = headT;
                var output:Vector.<String> = new Vector.<String>();
                output.push("\nTransition History--------------");
                while(node != null) {
                    output.push("\t"+output.length+"\t"+node.toString());
                    node = node.next;
                }
                atrace(output.join("\n"));                
            } else {
                atrace("Not recording");
            }
        }
        
        /**
        * A helper function to add the states of an object to the indexes.
        *
        * @param target An object implementing IID with states
        */
        public function indexStates(_target:IID):void {
            var type:XML = describeType(_target);
            var className:String = '('+_target.id+')'+type.@name.toString()+"/";

            for each(var method:XML in type.method) {
                var mname:String = method.@name.toString();
                var retType:String = method.@returnType.toString();
                var paramCount:int = method.parameter.length();
                var paramType:String = method.parameter.@type;
                if (mname.indexOf('s_') == 0 
                    && retType == "int" 
                    && paramCount == 1 
                    && paramType == "gr.state::Signal") {
                    m_sIndex[_target[mname]] = className+mname;
                    m_rsIndex[className+mname] = new StateContext(_target.id, type.@name.toString(), mname, _target[mname]);
                }
            }
        }

        /**
        * synchronous dispatch only use if you know exactly what will happen
        */
        public function dispatch(_s:Signal):void {
            var res:int;

            var cur:Function = state;
            res = state(_s);

            // handle a request to transition
            if (res == RET_TRAN) {

                record(this, state, _s);

                CONFIG::gr_debug {
                    atrace("on " + _s + " transition from: " + m_sIndex[cur]+" to: " + m_sIndex[state]);
                }

                cur(SIG_EXIT);
                state(SIG_ENTER);                    
            }
        }

        /** 
        * Dispatches a signal asynchronously. Useful for when you want to call back into a state after a SIG_ENTER 
        * which may result in a transition.
        */
        public function post(_s:Signal, _to:Fsm = null):void {
            if(_to == null) {
                _s.to = this;
            }
            InDispatcher.post(_s);
        }

        /**
        * Call and return handled() when a signal is processed or ignored.  A function should return handled() at the end a state's switch statement.
        * <listing>
        * public function s_a(_s:Signal):int {
        *     switch(_s) {
        *         case SIG_ENTER: {
        *             return handled(); // return instead of breaking between cases to avoid falling through
        *         }
        *         case SIG_EXIT: {
        *             return handled();
        *         }
        *         case SIG_CLICK: {
        *             return stran(s_clicked);
        *         }
        *     }
        *     return handled();
        * }
        * <listing>
        */
        public function handled():int {
            return RET_HANDLED;
        }

        /**
        * Return stran to transition to a new state
        *
        * @param target The target of the transition.
        */
        public function stran(_target:Function):int {
            state = _target;
            return RET_TRAN;
        }
    }
}
