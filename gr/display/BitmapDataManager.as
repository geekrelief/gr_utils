package gr.display {

    import flash.utils.Dictionary;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import domisuto.display.filters.BitmapDataFilter;
    import domisuto.display.filters.processFilters;

    public class BitmapDataManager {

        private static var m_instance:BitmapDataManager;
        protected var m_bds:Dictionary;
        protected var m_filters:Dictionary;
        protected var m_filterVectors:Dictionary;

        public static function get instance():BitmapDataManager {
            if(m_instance == null) {
                m_instance = new BitmapDataManager();
            }
            return m_instance;
        }

        public function BitmapDataManager() {
            m_bds = new Dictionary();
            m_filters = new Dictionary();
            m_filterVectors = new Dictionary();
        }

        public function getBitmap(_id:String):Bitmap {
            var bd:BitmapData = m_bds[_id];
            if(bd != null) {
                var b:Bitmap = new Bitmap();
                b.bitmapData = bd;
                return b;
            }
            return null;
        }

        public function getBitmapData(_id:String):BitmapData {
            return m_bds[_id];
        }

        public function setBitmapData(_id:String, _bd:BitmapData):void {
            m_bds[_id] = _bd;
        }

        public function dispose(_id:String):void {
            m_bds[_id].dispose();
        }

        public function setFilter(_id:String, _filter:BitmapDataFilter):void {
            m_filters[_id] = _filter;
        }

        public function getFilter(_id:String):BitmapDataFilter {
            return m_filters[_id];
        }

        /**
        * Takes a vector of registered filter names and returns the filter.  
        * Common use case is with processTo to generate a set of new bitmapDatas.
        */
        public function getFilters(_filterNames:Vector.<String>):Vector.<BitmapDataFilter> {
            var filters:Vector.<BitmapDataFilter> = new Vector.<BitmapDataFilter>(_filterNames.length, true);
            for(var i:int = 0; i < _filterNames.length; ++i) {
                filters[i] = getFilter(_filterNames[i]);
            }
            return filters;
        }

        public function getFiltersByName(_name:String):Vector.<BitmapDataFilter> {
            return getFilters(m_filterVectors[_name]);
        }

        public function setFiltersName(_name:String, _filterNames:Vector.<String>):void {
            m_filterVectors[_name] = _filterNames;
        }

        /**
        * Takes an existing bitmapData identified by source, runs filters on it to create a new bitmap.
        */
        public function process(_source:String, _filters:Vector.<BitmapDataFilter>):BitmapData {
            return processFilters(getBitmapData(_source), _filters);
        }

        public function processByName(_source:String, _name:String):BitmapData {
            return processFilters(getBitmapData(_source), getFiltersByName(_name));
        }

        /**
        * Takes an existing bitmapData identified by source, runs filters on it to create a new bitmap, and registers it with a target name
        */
        public function processTo(_source:String, _target:String, _filters:Vector.<BitmapDataFilter>):void {
            var targetbd:BitmapData = processFilters(getBitmapData(_source), _filters);
            setBitmapData(_target, targetbd);
        }

        public function processToByName(_source:String, _target:String, _name:String):void {
            var targetbd:BitmapData = processFilters(getBitmapData(_source), getFiltersByName(_name));
            setBitmapData(_target, targetbd);
        }
    }
}
