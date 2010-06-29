package gr.display {

    // Wraps an animator and a set of BitmapData frames to animate

    import flash.display.BitmapData;
    import flash.display.BitmapData;

    public class BitmapAnimator {

        public function BitmapAnimator(_fps:int, _frames:Vector.<BitmapData>) {
            animator = new Animator(_fps, _frames.length);
            frames = _frames;
        }
        
        public var animator:Animator;
        public var frames:Vector.<BitmapData>;

        public function setStart(_curTime:int):void {
            animator.setStart(_curTime);
        }

        public function update(_curTime:int):BitmapData {
            return frames[animator.update(_curTime)];
        }
    }
}
