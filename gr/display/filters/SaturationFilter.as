package gr.display.filters {

    import flash.display.BitmapData;
    import flash.filters.ColorMatrixFilter;
    import domisuto.math.Origin;
    
    /**
    * SaturationFilter: set the saturation in range 0-1+ (0:fully desaturate, 1:normal saturation, >1: increased saturation)
    * Original code: http://www.gotoandlearnforum.com/viewtopic.php?f=29&t=16565
    */
    public class SaturationFilter extends BitmapDataFilter {

        public static const DESATURATE:Number = 0;
        public static const NORMAL:Number     = 1;
        public static const SATURATE:Number   = 2;

        public function SaturationFilter() {
            m_sat = new ColorMatrixFilter();
            m_level = NORMAL;
        }

        protected var m_sat:ColorMatrixFilter;
        protected var m_level:Number;

        override public function get name():String {
            return "saturation";
        }

        override public function get optionsStr():String {
            // return the options associated with the filter as a string
            return ""+m_level;
        }

        public function get level():Number {
            return m_level;
        }

        public function set level(_val:Number):void {
            m_level = _val;
            m_sat.matrix = [
                0.114 + 0.886 * m_level, 0.299 * (1 - m_level),
                0.587 * (1 - m_level), 0, 0, 0.114 * (1 - m_level),
                0.299 + 0.701 * m_level, 0.587 * (1 - m_level),
                0,  
                0,  
                0.114 * (1 - m_level), 0.299 * (1 - m_level),
                0.587 + 0.413 * m_level, 
                0, 0, 0, 0, 0, 1, 0
                ]; 
        }

        override public function filter(_bd:BitmapData):void { 
            _bd.applyFilter(_bd, _bd.rect, Origin, m_sat);
        }
    }
}
