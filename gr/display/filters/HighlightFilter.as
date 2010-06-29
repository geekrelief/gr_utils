package gr.display.filters {

    import flash.display.BitmapData;
    import flash.filters.GlowFilter;
    import domisuto.math.Origin;
    
    /**
    * HighlightFilter: renders an inner highlight.
    */
    public class HighlightFilter extends BitmapDataFilter {

        public function HighlightFilter() { 
            m_glow = new GlowFilter();
            m_glow.inner = true;
        }

        protected var m_glow:GlowFilter;

        override public function get name():String {
            return "highlight";
        }

        override public function get optionsStr():String {
            return ""+color;
        }

        public function get color():uint { return m_glow.color; }
        public function set color(_val:uint):void { m_glow.color = _val; }

        override public function filter(_bd:BitmapData):void { 
            _bd.applyFilter(_bd, _bd.rect, Origin, m_glow);
        }
    }
}
