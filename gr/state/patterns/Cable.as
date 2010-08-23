package gr.state.patterns {

    import gr.events.Eventer;
    import flash.events.Event;
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;
    import flash.utils.Dictionary;
    import gr.state.Signal;
    import gr.state.Fsm;

    import gr.debug.atrace;

    /**
    * The state Cable pattern transforms a flash event into a signal for an fsm.
    * <p/>
    * Example:
    * <listing>
    *   var c:Cable = new Cable(sprite, fsm);
    *   c.click(SIG_CLICKED);           // maps a click event on the sprite to the SIG_CLICKED signal for the fsm
    *   c.mouseDown(SIG_MDOWN, true);   // maps a mouseDown event on the sprite to the SIG_MDOWN signal for the fsm, and removes the listener on dispatch
    *   c.clear(SIG_CLICKED);           // removes the SIG_CLICKED signal mapping and event listener for the click event.
    *   c.reset();                      // removes all mappings and event listeners on the sprite setup by the cable
    * </listing>
    *
    */
    public dynamic class Cable extends Proxy {
        protected var m_ev:Eventer;
        protected var m_sm:Fsm;
        protected var m_sigHandlers:Dictionary;

        public function Cable(_obj:*, _sm:Fsm) {
            m_sm = _sm;
            m_sigHandlers = new Dictionary(true);
            m_ev = new Eventer(_obj);
        }


        override flash_proxy function callProperty(_eventType:*, ..._rest):* {
            // rest[0] is the signal
            // rest[1] specifies once
            var sig:Signal = Signal(_rest[0]);
            var once:Boolean = (_rest.length == 2 ? Boolean(_rest[1]) : false);
            var handler:Function = getHandler(sig); 

            m_sigHandlers[sig] = handler;
            if (!m_ev.setup(_eventType, handler, once)) {
                reset();        
                throw new Error("Failed to attach signal "+sig+"  to '"+_eventType+"'");
            }
        }

        protected function getHandler(_sig:Signal):Function {
            return function(_e:*):void {
                //atrace(Event(_e).type+" -> "+_sig);
                _sig.event = _e;
                m_sm.dispatch(_sig);
            }
        }

        public function clear(_sig:Signal):void {
            m_ev.clear(m_sigHandlers[_sig]);
            delete m_sigHandlers[_sig];
        }

        public function reset():void {
            m_ev.reset();
            for (var sig:String in m_sigHandlers) {
                delete m_sigHandlers[sig];
            }
            m_sigHandlers = new Dictionary(true);
            m_sm = null;
        }
    }
}
