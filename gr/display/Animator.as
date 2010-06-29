package gr.display {

    public class Animator {
        public function Animator(_fps:int, _frameCount:int) {
            fpsTick = 1000.0 / _fps;
            ifpsTick = _fps / 1000.0;
            frameCount = _frameCount;
        }

        // animation vars
        public var frameCount:int;
        public var frame:int;
        public var frameStep:int;
        public var start:int;
        public var elapsed:int;
        public var fpsTick:Number;
        public var ifpsTick:Number;


        public function setStart(_start:int):void {
            start = _start;
            frame = 0;
        }

        public function update(_curTime:int):int {
            elapsed = _curTime - start;
            if(elapsed >= fpsTick) {
                frameStep = elapsed * ifpsTick;
                start = _curTime - int(elapsed - (frameStep * fpsTick));
                frame = (frame + frameStep) % frameCount;                                
            }
            return frame;
        }

        public function get updated():Boolean {
            return (elapsed >= fpsTick);
        }
    }
}
