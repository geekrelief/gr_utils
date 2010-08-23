package gr.state {

    import gr.debug.atrace;
    import flash.utils.Dictionary;

    /**
    * Hsm represents a hiearchical state machine. The main difference is that each state except for the s_top state
    * is required to respond to the SIG_PARENT:(Signal.PARENT) signal with its parent state by a sparent call. 
    * Any signals not handled by a state are passed up through the ancestor states until it is handled or ignored.
    * All signals are handled by s_top.  The initial state is required to transition to a start state.
    */
    public class Hsm extends Fsm {

        public function Hsm(_initState:Function) {
            super(_initState);

            m_pathCache = new Dictionary();
            m_top = s_top;
        }

        include "inc/ret.inc"
        include "inc/signals.inc"

        protected var m_pathCache:Dictionary;
        protected var m_top:Function;

        override public function init(_sindexTarget:IID = null):void {

            if (_sindexTarget != null) {
                if (_sindexTarget != this) {
                    InMachineIndex.register(_sindexTarget);
                }

                indexStates(_sindexTarget);
            }

            if(state(SIG_INIT) != RET_TRAN) { // set the initial transition
                // top most initial transition must be taken
                throw new Error("Initial State must transition.");
            }

            record(this, state, SIG_INIT);

            var top:Function = m_top;
            var path:Array = [];
            // drill into the target
            do {

                path[0] = state;
                state(SIG_PARENT);
                var pathdx:int = 0;

                while(state != top) {
                    path[++pathdx] = state;
                    state(SIG_PARENT);
                }

                state = path[0];
                // enter from parents
                do {
                    path[pathdx](SIG_ENTER);
                } while (--pathdx >= 0)

                top = path[0];

            } while(top(SIG_INIT) == RET_TRAN) // loop on initial transitions

            state = top;
        }

        override public function dispatch(_s:Signal):void {
            var res:int;

            var cur:Function = state;
            // this handles the signal propagation through the state and parents
            do {
                res = state(_s);
            } while (res == RET_PARENT)

            // handle a request to transition
            if(res == RET_TRAN) {
                var target:Function = state;

                record(this, state, _s);

                if(cur == target) {
                    cur(SIG_EXIT);
                    cur(SIG_ENTER);
                    return;
                }

                CONFIG::gr_debug {
                    atrace("on " + _s + " transition from: " + m_sIndex[cur]+" to: " + m_sIndex[target]);
                }

                // determine the LCA for the cur and target state
                // get the path for the cur state
                var cpath:Array = m_pathCache[cur];
                if(cpath == null) {
                    cpath = m_pathCache[cur] = [cur]; 

                    while (cur != m_top) {
                        cur(SIG_PARENT);
                        cur = cpath[cpath.length] = state;
                    }
                }

                state = null; // reset the state to clear LCA discovery for target

                // get the path for the target
                cur = target;
                var tpath:Array = m_pathCache[target];
                if(tpath == null) {
                    tpath = m_pathCache[target] = [target];

                    while (cur != m_top) {
                        cur(SIG_PARENT);
                        if (state == null) {
                            throw new Error(m_sIndex[cur] +" must define a parent state.");
                        }
                        cur = tpath[tpath.length] = state;
                    }
                }

                // find index of the last common ancestor in the path
                for(var cdx:int = cpath.length - 1, tdx:int = tpath.length - 1; cdx > -1 && tdx > -1; --cdx, --tdx) {
                    if(cpath[cdx] != tpath[tdx]) {
                        break;
                    }
                }

                // perform exits
                var exitdx:int = 0;
                while(exitdx <= cdx) {
                    cpath[exitdx](SIG_EXIT);
                    ++exitdx;
                }

                // perform enters
                var enterdx:int = tdx;
                while(enterdx >= 0) {
                    tpath[enterdx](SIG_ENTER);
                    --enterdx;
                }

                // drill into target hierarchy
                state = tpath[0];
                cur = state; 
                while(cur(SIG_INIT) == RET_TRAN) {
                    // determine substate path, cur is an ancestor of state now
                    var ipath:Array = [state];
                    var ip:int = 0;
                    state(SIG_PARENT);
                    while(state != cur) {
                        ipath[++ip] = state;
                        state(SIG_PARENT);
                    }
                    // enter paths
                    do {
                        ipath[ip](SIG_ENTER);
                        --ip;
                    } while(ip >= 0)

                    cur = ipath[0];
                }
            }

            state = cur;
        }

        /** 
        * Call sparent to pass the current signal to the parent state.
        */
        public function sparent(_parent:Function):int {
            state = _parent;
            return RET_PARENT;
        }

        /**
        * This is the default top state where all signals are consumed.  You may override it if you wish (e.g. to log unused signals).
        */
        public function s_top(_s:Signal):int {
            return RET_HANDLED; // ignore anything reaching the top
        }
    }
}
