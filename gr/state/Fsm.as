package gr.state {

    import gr.debug.atrace;

    public class Fsm {

        public function Fsm(_initState:Function) {
            m_state = s_top;
            m_initState = _initState;
        }

        include "inc/ret.inc"
        include "inc/signals.inc"
        include "inc/sindex_def.inc"

        protected var m_initState:Function;
        protected var m_state:Function;


        public function init(_sindexTarget:* = null):void {

            CONFIG::gr_debug {
                if(_sindexTarget != null) {
                    sindexTarget = _sindexTarget;
                }
            }

            include "inc/sindex_init.inc"

            if(m_initState(SIG_INIT) != RET_TRAN) { // set the initial transition
                // top most initial transition must be taken
                throw new Error("Initial State must transition.");
            }

            m_state(SIG_ENTER);
        }
        
        public function s_top(_s:Signal):int {
            return RET_HANDLED; // ignore anything reaching the top
        }

        public function dispatch(_s:Signal):void {
            var res:int;

            var cur:Function = m_state;
            res = m_state(_s);

            // handle a request to transition
            if (res == RET_TRAN) {
                CONFIG::gr_debug {
                    atrace("on " + _s + " transition from: " + SIndex[cur]+" to: " + SIndex[m_state]);
                }

                cur(SIG_EXIT);
                m_state(SIG_ENTER);                    
            }
        }

        // asynchronous signal dispatching
        public function post(_s:Signal, _to:Fsm = null):void {
            if(_to == null) {
                _s.to = this;
            }
            InDispatcher.post(_s);
        }

        // return this a signal is handled
        public function handled():int {
            return RET_HANDLED;
        }

        // return this to transition
        public function stran(_target:Function):int {
            m_state = _target;
            return RET_TRAN;
        }
    }
}
