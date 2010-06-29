package gr.display.filters {

    import flash.display.BitmapData;
    
    /**
    * BitmapDataFilter is used by BitmapDataProcessor to do operations on the bitmap. This is destructive.  
    * BitmapDataFilters can be arbitrarily complex or as simple as wrap a flash.filter
    */
    public class BitmapDataFilter {

        public function BitmapDataFilter() { }

        public function get name():String {
            // return the name of the filter
            throw new Error("please override"); 
            return "";
        }

        public function get optionsStr():String {
            // return the options associated with the filter as a string
            throw new Error("please override");
            return "";
        }

        public function filter(_bd:BitmapData):void { 
            throw new Error("please override"); 
        }
    }
}
