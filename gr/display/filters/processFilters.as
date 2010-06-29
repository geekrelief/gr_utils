package gr.display.filters {

    import flash.display.Bitmap;
    import flash.display.BitmapData;

    /**
    * Takes a Vector of BitmapDataFilters and runs it on a BitmapData to return a new BitmapData.
    */
    public function processFilters(_source:BitmapData, _filters:Vector.<BitmapDataFilter>):BitmapData {
        var bd:BitmapData = _source.clone();

        for(var i:int = 0; i < _filters.length; ++i) {
            _filters[i].filter(bd);
        }

        return bd;
    }
}
