/*
 * Copyright the original author or authors.
 * 
 * Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *	  http://www.mozilla.org/MPL/MPL-1.1.html
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package gr.display {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	/**
	 * 
	 * MCRasterizer will replace all vectors with bitmap to gain more FPS.
	 * 
	 * usage:
	 * MCRasterizer.rasterize(mc); - it can be used multiple time on the same instance 
	 * 
	 * If you planning to use multiple instances of the same library object, please
	 * give it a class name. Then bitmap data from frames will be created only once and shared
	 * amongst all instances. To be sure that all rasterized clips have class name set
	 * "onlyMCWithClassName" static variable for "true" before rasterizing.
	 * You can also setup warning "maxUsedMBError"
	 * 
	 * MCRasterizer will create and store BitmapData (in size just like boundingbox of certain frame)
	 * for every frame of your animation so if you rasterize loong and big animation please
	 * check memory consumption (static variable "usedMemory").
	 * 
	 * WARNING: clip (class) will be rasterized only after clip play all frames.
	 * If it's library instance is already initialized - then rasterizing
	 * starts immediately.
	 * 
	 * @author Marek Brun
	 */
	public class Rasterizer extends EventDispatcher{
		
		public static const COMPLETE : String = 'RasterizeComplete';
		
		static public var usedMemoryKB:uint;
        static public var maxUsedMBError:uint=300;
		static public var onlyMCWithClassName:Boolean=false;
		static private var isBeenMaxUsedMBError:Boolean;
		
		private var _mc:MovieClip;
		//private var dbg:InstanceDebugServiceProxy;
		private var bitmapDisplay:Bitmap;
		public var bitmapSmoothing:Boolean=true;
		private static var dictClassName_info:Dictionary=new Dictionary(true);
		public var info:RasterInfo;

		public function Rasterizer(access:Private, mc:MovieClip) {
			this._mc=mc;
			
			mc.isRasterized=false;
			
			var className:String=getQualifiedClassName(mc);
			if(className=='flash.display::MovieClip'){
				if(onlyMCWithClassName){
					throw new Error('Please setup class name for rasterized MovieClip (instance:'+mc.name+')');
				}else{
					info=createRasterInfo(mc);
				}
			}else{
				if(!dictClassName_info[className]){
					dictClassName_info[className]=createRasterInfo(mc);
				}
				info=dictClassName_info[className];
			}
			
			bitmapDisplay=new Bitmap();
			
			if(info.gotAllFramesBitmaps){
				startRasterizing();
			}else{
				mc.addEventListener(Event.ENTER_FRAME, onEF_WhileGettingBitmaps);
			}
			
		}
		
		public function getIsRasterized():Boolean {
			return info.gotAllFramesBitmaps;
		}

		private function get mc():MovieClip {  return _mc; }
		
		protected function startRasterizing():void {
			for(var i:uint=1;i<mc.totalFrames+1;i++){
				mc.addFrameScript(i, rasterizeCurrentFrame);
			}
			mc.removeEventListener(Event.ENTER_FRAME, onEF_WhileGettingBitmaps);
			mc.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			mc.isRasterized=true;
			rasterizeCurrentFrame();
		}
		
		private static function createRasterInfo(mc:MovieClip):RasterInfo {
			var info:RasterInfo=new RasterInfo(getQualifiedClassName(mc), mc.totalFrames);
			return info;
		}
		
		protected function rasterizeCurrentFrame():void {
			if(!mc.stage){ return; }
			while(mc.numChildren>0){
				mc.removeChild(mc.getChildAt(0));
			}
			mc.addChild(bitmapDisplay);
			bitmapDisplay.smoothing=bitmapSmoothing;
			bitmapDisplay.bitmapData=info.bitmaps[mc.currentFrame];
			bitmapDisplay.x=info.bounds[mc.currentFrame].x;
			bitmapDisplay.y=info.bounds[mc.currentFrame].y;
		}
		
		private static function getBitmapDataByDisplay(display:DisplayObject):BitmapData {
			var bounds:Rectangle=display.getBounds(display);
			var bd:BitmapData=new BitmapData(
				Math.max(1, Math.min(2880, bounds.width)),
				Math.max(1, Math.min(2880, bounds.height)),
				true,
				0x00000000
			);
			bd.draw(display, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));
			return bd;
		}
		
		/**
		 * This can be called for the same MovieClip instance multiple times - MCRasterizer instance for that MovieClip will be created only once 
		 */
		public static function rasterize(mc:MovieClip):Rasterizer {
			if(servicedObjects[mc]){
				return servicedObjects[mc];
			}else{
				servicedObjects[mc]=new Rasterizer(null, mc);
			}
			return servicedObjects[mc];
		}
		
		private static const servicedObjects : Dictionary = new Dictionary(true);
		
//********************************************************************************************
//		events for MCRasterizer
//********************************************************************************************
		protected function onEF_WhileGettingBitmaps(event:Event):void {
			if(!info.getGotFrameData(mc.currentFrame)){
				//getting bitmap for current frame
				var bd:BitmapData=getBitmapDataByDisplay(mc);
				info.setFrameData(mc.currentFrame, bd, mc.getBounds(mc));
				usedMemoryKB+=((bd.width*bd.height*32)/8)/1024;
			}
			if(info.gotAllFramesBitmaps){
				//clip is  fully rasterized
				dispatchEvent(new Event(Rasterizer.COMPLETE));
				startRasterizing();
			}
			if(usedMemoryKB/1024>maxUsedMBError && !isBeenMaxUsedMBError){
				isBeenMaxUsedMBError=true;
				throw new Error('Memory used for rasterizing is above '+maxUsedMBError+' MB');
			}
		}
		
		protected function onFrameScript_WhileRasterizing(event:Event):void {
			rasterizeCurrentFrame();
		}
		
		protected function onAddedToStage(event:Event):void {
			mc.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			rasterizeCurrentFrame();
		}
		
		
	}
}

internal class Private {}

