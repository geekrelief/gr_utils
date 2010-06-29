package gr.display.filters {

    import flash.display.BitmapData;
    import flash.geom.ColorTransform; 

    /**
    * AlphaFilter: applies an alpha ColorTransform.
    */
    public class AlphaFilter extends BitmapDataFilter {

        public function AlphaFilter() { 
            m_ct = new ColorTransform();
        }

        protected var m_ct:ColorTransform;

        override public function get name():String {
            return "alpha";
        }

        override public function get optionsStr():String {
            return multiplier+","+offset;
        }

        public function get multiplier():Number { return m_ct.alphaMultiplier; } 
        public function set multiplier(_val:Number):void { m_ct.alphaMultiplier = _val; } 

        public function get offset():Number { return m_ct.alphaOffset; }
        public function set offset(_val:Number):void { m_ct.alphaOffset = _val; }

        override public function filter(_bd:BitmapData):void { 
            _bd.colorTransform(_bd.rect, m_ct);
        }
    }
}
