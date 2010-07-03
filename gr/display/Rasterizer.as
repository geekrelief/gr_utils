package gr.display {

    import flash.events.EventDispatcher;
    import flash.events.Event;

    import flash.utils.Dictionary;
    import flash.display.MovieClip;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.geom.Rectangle;
    import flash.geom.Matrix;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getDefinitionByName;
    import gr.debug.atrace;
	

    public class Rasterizer extends EventDispatcher {

        public static const RASTERIZED:String = 'rasterized';

        private static var m_Rasterized:Dictionary = new Dictionary(true);

        public static function rasterize(_obj:*):Rasterizer {
            var r:Rasterizer = null;
            if(_obj is String) {
                _obj = Class(getDefinitionByName(String(_obj)));
            } 

            if (_obj is Class) {
				_obj = new _obj();
                r = new Rasterizer(__Private.instance, _obj);
            }

            var className:String = getQualifiedClassName(_obj);
			
			if (className == 'flash.display::MovieClip') {
				// if this is a movieclip with no name then we have to use the mc as the index
				r = new Rasterizer(__Private.instance, _obj);
				m_Rasterized[_obj] = r;
			} else if ((_obj as MovieClip) != null) {
				// this mc has a name so all instances of it can share the same bitmap data
                var siblingr:Rasterizer = m_Rasterized[className];
                r = new Rasterizer(__Private.instance, _obj, siblingr);
                if(siblingr == null) {
                    m_Rasterized[className] = r;
                }
            } else {
                throw new Error("Cannot rasterize "+className);
            }
			
            return r;
        }
		
		public function forceStep():void {
			for (var i:int = 1; i < mc.totalFrames + 1; ++i) {
				mc.gotoAndStop(i);
				enterFrame(null);
			}
		}

        protected var m_rasteredFrameCount:int = 0;
        protected var m_rasteredFrames:Dictionary = new Dictionary();
        public var m_bds:Vector.<BitmapData>;
        public var m_bounds:Vector.<Rectangle>;

        public var mc:MovieClip;

        public function Rasterizer(__p:__Private, _mc:MovieClip, _r:Rasterizer = null) {
            mc = _mc;
            m_rasteredFrames = new Dictionary();

            for(var i:int = 1; i < mc.totalFrames+1; ++i) {
                m_rasteredFrames[i] =  false;
            }
			
            if(_r == null) {
                m_bds = new Vector.<BitmapData>(mc.totalFrames, true);
                m_bounds = new Vector.<Rectangle>(mc.totalFrames, true); 
                mc.addEventListener(Event.ENTER_FRAME, enterFrame);
            } else {
                if(_r.isRasterized()) { // copy references to sibling's data
                    copySiblingData(_r);
                } else {
                    // sibling is still processing, wait for sibling to finish
                    _r.addEventListener(RASTERIZED, siblingRasterized);
                }
            }
        }

        public function isRasterized():Boolean {
            return m_rasteredFrameCount == mc.totalFrames;
        }

        protected var bm:Bitmap = new Bitmap(null, "never", true);
        public function enterFrame(e:Event):void {
            if (!m_rasteredFrames[mc.currentFrame]) {
                var br:Rectangle = mc.getBounds(mc);
				br.x *= mc.scaleX;
				br.width *= mc.scaleX;
				br.y *= mc.scaleY;
				br.height *= mc.scaleY;
				
                var bd:BitmapData = new BitmapData(br.width + 1, br.height+1, true, 0);
				bd.draw(mc, new Matrix(mc.scaleX, 0, 0, mc.scaleY, -br.x, -br.y));
                m_bounds[mc.currentFrame-1] = br;
                m_bds[mc.currentFrame-1] = bd;

                m_rasteredFrameCount++;
                m_rasteredFrames[mc.currentFrame] = true;
            }

            if (isRasterized()) {
                prepRaster();
            }
        }

        protected function prepRaster():void {
            mc.removeEventListener(Event.ENTER_FRAME, enterFrame);
            m_rasteredFrames = null;
            
//            if (mc.stage != null) {
                mc.addEventListener(Event.EXIT_FRAME, exitFrame);
//            }
            mc.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
            mc.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
            dispatchEvent(new Event(RASTERIZED));
        }

        protected function exitFrame(e:Event):void {
            rasterizeFrame();
        }

        protected function rasterizeFrame():void {
            // need to replace the children for every render because flash recreates MovieClip children created on the timeline
            while(mc.numChildren > 0) {
                mc.removeChild(mc.getChildAt(0));
            }
           
            mc.addChild(bm);
			bm.scaleX = 1 / mc.scaleX;
			bm.scaleY = 1 / mc.scaleY;

            bm.bitmapData = m_bds[mc.currentFrame - 1];
            bm.x = m_bounds[mc.currentFrame - 1].x / mc.scaleX;
            bm.y = m_bounds[mc.currentFrame - 1].y / mc.scaleY;
        }

        protected function addedToStage(e:Event):void {
            mc.addEventListener(Event.EXIT_FRAME, exitFrame);
        }

        protected function removedFromStage(e:Event):void {
            mc.removeEventListener(Event.EXIT_FRAME, exitFrame);
        }

        protected function copySiblingData(_r:Rasterizer):void {
            m_bds = _r.m_bds;
            m_bounds = _r.m_bounds;
            m_rasteredFrameCount = mc.totalFrames;
            prepRaster();
        }

        protected function siblingRasterized(e:Event):void {
            copySiblingData(Rasterizer(e.target));
        }
    }
}

internal class __Private {
    public static var instance:__Private = new __Private();
    public function __Private() {
    }
}
