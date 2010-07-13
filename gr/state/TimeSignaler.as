package gr.state {

    import flash.utils.Timer;
    import flash.utils.getTimer;
    import flash.events.TimerEvent;
    import gr.debug.*;

    public class TimeSignaler {

        public function TimeSignaler() {
        }

        protected var m_everyTimePosts:Array;
        protected var m_inTimePosts:Array;
        protected var m_timer:Timer;

        public function init():void {
            m_everyTimePosts = [];
            m_inTimePosts = [];
            m_timer = new Timer(0, 0);
            m_timer.addEventListener(TimerEvent.TIMER, onTimer);
            m_timer.start();
        }

        public function postIn(_s:Signal, _time:int):TimePost {
            var tp:TimePost = new TimePost(_s, _time);
            m_inTimePosts.push(tp);
            return tp;
        }

        public function cancelPostIn(_tp:TimePost):TimePost {
            if (_tp == null) {
                throw new Error("Cannot cancelPostIn on null TimePost.");
            }

            var i:int = m_inTimePosts.indexOf(_tp);
            if(i != -1) {
                m_inTimePosts.splice(i, 1);
            }
            
            return null;
        }

        // posts a signal every time interval, to cancel need to cancelPostEvery using the returned TimePost
        public function postEvery(_s:Signal, _time:int):TimePost {
            var tp:TimePost = new TimePost(_s, _time);
            m_everyTimePosts.push(tp);
            return tp;
        }

        public function cancelPostEvery(_tp:TimePost):TimePost {
            if (_tp == null) {
                throw new Error("Cannot cancelPostEvery on null TimePost.");
            }

            var i:int = m_everyTimePosts.indexOf(_tp);
            if(i != -1) {
                m_everyTimePosts.splice(i, 1);
            }
            
            return null;
        }

            protected function onTimer(_e:TimerEvent):void {
                // check the when property for each of the 'in' and 'every' signals
                var time:int = getTimer();
                var elapsed:int;
                var i:int;
                var inDispatched:Boolean = false; 
                var tp:TimePost;

                // check 'in' posts
                for(i = 0; i < m_inTimePosts.length; ++i) {
                    tp = m_inTimePosts[i];
                    elapsed = time - tp.start;
                    if (elapsed >= tp.time) {
                        InDispatcher.dispatch(tp.signal);
                        tp.signal = null;
                        inDispatched = true;
                    }
                }

                // remove dispatched 'in' posts
                if (inDispatched) {
                    var inTimePosts:Array = m_inTimePosts;
                    m_inTimePosts = [];
                    
                    for(i = 0; i < inTimePosts.length; ++i) {
                        tp = inTimePosts[i];
                        if(tp.signal != null) {
                            m_inTimePosts.push(tp);
                        }
                    }
                }

                // check 'every' posts
                for(i = 0; i < m_everyTimePosts.length; ++i) {
                    tp = m_everyTimePosts[i];
                    elapsed = time - tp.start;
                    if(elapsed >= tp.time) {
                        tp.start = time - (elapsed - tp.time);
                        InDispatcher.dispatch(tp.signal);
                    }
                }
            }
    }
}
