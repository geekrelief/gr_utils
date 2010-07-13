package gr.state {

    import gr.debug.atrace;
    import flash.utils.Dictionary;

    public class Hsm extends Fsm {

        public function Hsm(_initState:Function) {
            super(_initState);

            m_pathCache = new Dictionary();
        }

        include "inc/ret.inc"
        include "inc/signals.inc"
        include "inc/sindex_def.inc"

        protected var m_pathCache:Dictionary;

        override public function init(_sindexTarget:* = null):void {

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

            var top:Function = s_top;
            var path:Array = [];
            // drill into the target
            do {

                path[0] = m_state;
                m_state(SIG_EMPTY);
                var pathdx:int = 0;

                while(m_state != top) {
                    path[++pathdx] = m_state;
                    m_state(SIG_EMPTY);
                }

                m_state = path[0];
                // enter from parents
                do {
                    path[pathdx](SIG_ENTER);
                } while (--pathdx >= 0)

                top = path[0];

            } while(top(SIG_INIT) == RET_TRAN) // loop on initial transitions

            m_state = top;
        }

        override public function dispatch(_s:Signal):void {
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
                    cur(SIG_EXIT);
                    cur(SIG_ENTER);
                    return;
                }

                CONFIG::gr_debug {
                    atrace("on " + _s + " transition from: " + SIndex[cur]+" to: " + SIndex[target]);
                }

                // determine the LCA for the cur and target m_state
                // get the path for the cur state
                var cpath:Array = m_pathCache[cur];
                if(cpath == null) {
                    cpath = m_pathCache[cur] = [cur]; 

                    while (cur != s_top) {
                        cur(SIG_EMPTY);
                        cur = cpath[cpath.length] = m_state;
                    }
                }

                // get the path for the target
                cur = target;
                var tpath:Array = m_pathCache[target];
                if(tpath == null) {
                    tpath = m_pathCache[target] = [target];

                    while (cur != s_top) {
                        cur(SIG_EMPTY);
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
                m_state = tpath[0];
                cur = m_state; 
                while(cur(SIG_INIT) == RET_TRAN) {
                    // determine substate path, cur is an ancestor of m_state now
                    var ipath:Array = [m_state];
                    var ip:int = 0;
                    m_state(SIG_EMPTY);
                    while(m_state != cur) {
                        ipath[++ip] = m_state;
                        m_state(SIG_EMPTY);
                    }
                    // enter paths
                    do {
                        ipath[ip](SIG_ENTER);
                        --ip;
                    } while(ip >= 0)

                    cur = ipath[0];
                }
            }

            m_state = cur;
        }

        // return this to set the parent
        public function sparent(_parent:Function):int {
            m_state = _parent;
            return RET_PARENT;
        }
    }
}
