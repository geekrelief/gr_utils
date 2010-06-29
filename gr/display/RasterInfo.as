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
	/**
	 * 
     * Used by Rasterizer
	 * @author Marek Brun
     */

    import flash.display.BitmapData;
    import flash.geom.Rectangle;

    public class RasterInfo {

        public var className:String;
        public var bitmaps:Vector.<BitmapData>;
        public var bounds:Vector.<Rectangle>;
        public var gotAllFramesBitmaps:Boolean;
        public var countRasterizedFrames:uint;
        private var totalFrames:uint;

        public function RasterInfo(className:String, totalFrames:uint) {
            this.className=className;
            this.totalFrames=totalFrames;
            bitmaps = new Vector.<BitmapData>(totalFrames, true);
            bounds = new Vector.<Rectangle>(totalFrames, true);
        }

        /**
         * If there's alredy bitmap for that frame method returns false
         */
        public function getGotFrameData(frame:uint):Boolean {
            return bitmaps[frame-1];
        }

        public function setFrameData(frame:uint, bd:BitmapData, bounds:Rectangle):void {
            bitmaps[frame-1]=bd;
            this.bounds[frame-1]=bounds;
            countRasterizedFrames++;
            if(countRasterizedFrames>=totalFrames) {
                gotAllFramesBitmaps=true;
            }
        }
    }
}
