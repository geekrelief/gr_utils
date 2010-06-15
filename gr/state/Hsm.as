package gr.state {

    import gr.debug.atrace;
    import flash.utils.Dictionary;

    public class Hsm {

        public function Hsm(_initialState:Function) {
            m_state = s_top;
            m_initState = _initialState;

            m_sindex = new Dictionary();
            m_sindex[s_top] = 's_top';
            
            m_pathCache = new Dictionary();
        }

        public static var RET_HANDLED:int = 0;
        public static var RET_PARENT:int = 1;
        public static var RET_TRAN:int = 2;

        protected var m_initState:Function;
        protected var m_state:Function;

        protected var m_sindex:Dictionary;
        protected var m_pathCache:Dictionary;

        public function init():void {

            if(m_initState(Signal.INIT) != RET_TRAN) { // set the initial transition
                // top most initial transition must be taken
                throw new Error("Initial State must transition.");
            }

            var top:Function = s_top;
            var path:Array = [];
            // drill into the target
            do {

                path[0] = m_state;
                m_state(Signal.EMPTY);
                var pathdx:int = 0;

                while(m_state != top) {
                    path[++pathdx] = m_state;
                    m_state(Signal.EMPTY);
                }

                m_state = path[0];
                // enter from parents
                do {
                    path[pathdx](Signal.ENTER);
                } while (--pathdx >= 0)

                top = path[0];

            } while(top(Signal.INIT) == RET_TRAN) // loop on initial transitions

            m_state = top;
        }

        public function s_top(_s:Signal):int {
            return RET_HANDLED; // ignore anything reaching the top
        }

        public function dispatch(_s:Signal):void {
            var res:int;

            var cur:Function = m_state;
            // this handles the signal propagation through the state and parents
            do {
                res = m_state(_s);
            } while (res == RET_PARENT)

            // handle a request to transition
            if(res == RET_TRAN) {
                var target:Function = m_state;

                if(cur == target) {
                    cur(Signal.EXIT);
                    cur(Signal.ENTER);
                    return;
                }

                //atrace("transition request from cur: "+m_sindex[cur]+" to "+m_sindex[target]);

                // determine the LCA for the cur and target m_state
                // get the path for the cur state
                var cpath:Array = m_pathCache[cur];
                if(cpath == null) {
                    cpath = m_pathCache[cur] = [cur]; 

                    while (cur != s_top) {
                        cur(Signal.EMPTY);
                        cur = cpath[cpath.length] = m_state;
                    }
                }

                // get the path for the target
                cur = target;
                var tpath:Array = m_pathCache[target];
                if(tpath == null) {
                    tpath = m_pathCache[target] = [target];

                    while (cur != s_top) {
                        cur(Signal.EMPTY);
                        cur = tpath[tpath.length] = m_state;
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
                    cpath[exitdx](Signal.EXIT);
                    ++exitdx;
                }

                // perform enters
                var enterdx:int = tdx;
                while(enterdx >= 0) {
                    tpath[enterdx](Signal.ENTER);
                    --enterdx;
                }
            
                // drill into target hierarchy
                m_state = tpath[0];
                cur = m_state; 
                while(cur(Signal.INIT) == RET_TRAN) {
                    // determine substate path, cur is an ancestor of m_state now
                    var ipath:Array = [m_state];
                    var ip:int = 0;
                    m_state(Signal.EMPTY);
                    while(m_state != cur) {
                        ipath[++ip] = m_state;
                        m_state(Signal.EMPTY);
                    }
                    // enter paths
                    do {
                        ipath[ip](Signal.ENTER);
                        --ip;
                    } while(ip >= 0)

                    cur = ipath[0];
                }
            }

            m_state = cur;
        }

        // asynchronous signal dispatching
        public function post(_s:Signal, _to:Hsm = null):void {
            if(_to == null) {
                _s.to = this;
            }
            InDispatcher.post(_s);
        }

        // return this a signal is handled
        public function handled():int {
            return RET_HANDLED;
        }

        // return this to set the parent
        public function hparent(_parent:Function):int {
            m_state = _parent;
            return RET_PARENT;
        }

        // return this to transition
        public function htran(_target:Function):int {
            m_state = _target;
            return RET_TRAN;
        }
    }
}
