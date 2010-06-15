package gr.state {

    import flash.utils.getTimer;

    public class TimePost {
        public function TimePost(_s:Signal, _time:int) {
            signal = _s;
            time = _time;
            start = getTimer();
        }

        public var signal:Signal;
        public var time:int;
        public var start:int;
    }
}
