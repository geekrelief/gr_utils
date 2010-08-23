package gr.state {

    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.utils.Dictionary;

    import gr.debug.atrace;

    // acts as a message bus for all state objects
    // anything can publish with the dispatcher

    public class Dispatcher {

        public function Dispatcher() {
        }

            protected var m_signals:Array;
            protected var m_subscribers:Dictionary;
            protected var m_timer:Timer;

        public function init():void {
            m_signals = [];
            m_subscribers = new Dictionary();
            m_timer = new Timer(0, 0);
            m_timer.addEventListener(TimerEvent.TIMER, onTimer);
        }

        public function destroy():void {
            m_timer.stop();
            m_timer.removeEventListener(TimerEvent.TIMER, onTimer);
            m_timer = null;
            m_subscribers = null;
            m_signals = null;
        }

        public function subscribe(_h:Hsm, _s:Signal):void {
            // subscribe to a signal
            if (m_subscribers[_s.id] == null) {
                m_subscribers[_s.id] = [];
            }
            m_subscribers[_s.id].push(_h);
        }

        public function unsubscribe(_h:Hsm, _s:Signal):void {
            if (m_subscribers[_s.id] != null) {
                var i:int = m_subscribers[_s.id].indexOf(_h);
                if (i != -1) {
                    m_subscribers[_s.id].splice(i, 1);
                }
            }
        }

        // asynchronous signal dispatching
        public function publish(_s:Signal):void {
            m_signals.push(_s);
            checkTimer();
        }

        // asynchronous signal dispatching
        // Active/Hsm objects are supposed to have their own threads
        // But the flash avm runs on a single thread. So Dispatcher handles the dispatch 
        // We also want Hsms to be able to subscribe to signals
        public function post(_s:Signal):void {
            m_signals.push(_s);
            checkTimer();
        }

        // this immediately dispatches the signal to the targets
        // used by TimeSignaler and FrameSignaler for immediate processing
        public function dispatch(_s:Signal):void {
            // posting directly first
            if(_s.to != null) {
                (_s.to as Fsm).dispatch(_s);
                return;
            }

            // no direct posting, check subscribers
            var subs:Array = m_subscribers[_s.id];
            if(subs != null) {
                for(var i:int = 0; i < subs.length; ++i) {
                    subs[i].dispatch(_s); // if the active objects post or publish we'll pick it up in the while loop
                }
            } 
        }

            protected function checkTimer():void {
                if(!m_timer.running) {
                    m_timer.start();
                }
            }

            protected function disableTimer():void {
                m_timer.stop();
            }

            protected function onTimer(_e:TimerEvent):void {
                // we can sniff the signals here

                while(m_signals.length > 0) {
                    // go through the published and posted signals and dispatch

                    var s:Signal = m_signals.shift();
                    dispatch(s);
                }

                disableTimer(); 
            }
    }
}
