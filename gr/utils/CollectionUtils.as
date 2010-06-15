package gr.utils {
    import gr.debug.xinspect;
    import gr.debug.atrace;
    import flash.utils.describeType;

    public class CollectionUtils {

        public static function head(_a:*):* {
            return _a[0];
        }

        public static function tail(_a:*):* {
            switch(_a.length) {
                case 0:
                    return null;
                case 1:
                    return _a.slice(1, _a.length);
            } 
        }

        public static function last(_a:*):* {
            return _a[_a.length-1];
        }

        public static function exists(_a:*, _item:*, _cmp:Function = null):Boolean {
            var idx:int = _cmp == null ? _a.indexOf( _item ) : indexOfCompareFunc(_a,_item,_cmp);
            return ( idx >= 0 );
        }

        public static function removeIndex( _a:*, _idx:int ):void {
            _a = _a.splice(_idx,1);
        }

        public static function removeIndexes( _a:*, _indexes:Array ):void {
            for( var i:int = 0; i < _indexes.length; ++i ) {
                removeIndex( _a, _indexes[i] );
            }
        }

        public static function removeItem( _a:*, _item:*, _cmp:Function = null ):Boolean {
            var idx:int = _cmp == null ? _a.indexOf( _item ) : indexOfCompareFunc(_a,_item,_cmp);
            if( idx >= 0 ) {
                _a = _a.splice(idx,1);
                return true;
            }
            
            return false;
        }
        
        public static function removeItems( _a:*, _items:*, _cmp:Function = null ):Boolean {
            var ret:Boolean = true;
            var length:int = _items.length;
            for( var i:int = 0; i < length; ++i ) {
                if( !removeItem(_a,_items[i],_cmp) ) {
                    ret = false;
                }
            }

            return ret;
        }

        public static function forLoop( _a:*, _do:Function):void {
            var length:int = _a.length;
            for(var i:int = 0; i < length; ++i) {
                _do(_a[i]);
            }
        }

        public static function areEqual( _a:*, _b:* ):Boolean {
            if( _a.length != _b.length ) {
                return false;
            }

            for( var a:int = 0; a < _a.length; ++a ) {
                if( _b.indexOf( _a[a] ) < 0 ) {
                    return false;
                }
            }

            return true;
        }

        public static function isUnique( _a:* ):Boolean {
            return makeUnique(_a).length == _a.length;
        }

        public static function makeUnique( _a:*, _cmp:Function = null ):* {
            return _a.filter( function(e:Object, i:int, a:*):Boolean {
                var idx:int = (_cmp == null) ? a.indexOf(e) : indexOfCompareFunc( a, e, _cmp );
                return idx == i;
            });
        }

        public static function countItems( _a:*, _item:* ):int {
            var count:int = 0;
            for( var i:int = 0; i < _a.length; ++i ) {
                if( _a[i] == _item ) {
                    ++count;
                }
            }
            
            return count;
        }

        public static function toString(_a:*):String {
            var strParts:Array = new Array();
            for(var i:int = 0; i < _a.length; ++i) {
                var classInfo:XML = describeType(_a[i]);
                if( classInfo.@name.toString() == "Array" ) {
                    strParts.push( CollectionUtils.toString(_a[i]) );
                } else {
                    strParts.push( xinspect(_a[i]) );
                }
            }

            return "["+_a.join(", ")+"]";
        }

        /** Finds the index of element _e inside of collection _a, using the _cmp function to compare the elements */
        public static function indexOfCompareFunc( _a:*, _e:*, _cmp:Function ):int {
            for( var i:int = 0; i < _a.length; ++i ) {
                if( _cmp(_e, _a[i]) == 0 ) {
                    return i;
                }
            }

            return -1;
        }
    }
}
