package gr.display {

    /**
    * Abstracts a BulkLoader instance so upon load complete it processes packed swfs or pngs for use with the BitmapDataManager.
    */

    import flash.events.EventDispatcher;
    import flash.events.Event;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.BulkProgressEvent;
    import br.com.stimuli.loading.loadingtypes.ImageItem;
    import br.com.stimuli.loading.loadingtypes.LoadingItem;

    import domisuto.display.BitmapDataManager;
    import domisuto.display.newBitmapData;
    import domisuto.math.Origin;
    import domisuto.iso.math.visualSizeFromPixels;
    import domisuto.events.AEvent;

    import domisuto.debug.atrace;
    import domisuto.debug.xinspect;
    import domisuto.debug.xtrace;

    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;

    public class BitmapLoader extends EventDispatcher {
        public function BitmapLoader() {
            super();

            m_assetsToLoad = new Dictionary();
            m_urlsToLoad = new Dictionary();

            m_loader = new BulkLoader();
            m_loader.addEventListener(BulkProgressEvent.COMPLETE, onAssetsComplete);
            m_loader.addEventListener(BulkProgressEvent.PROGRESS, onAssetsProgress);
            m_loader.addEventListener(BulkLoader.ERROR, onAssetsError);

            m_started = false;
            m_itemCount = 0;

            m_loaderContext = new LoaderContext();
            m_loaderContext.applicationDomain = ApplicationDomain.currentDomain;
        }
        
        public static const COMPLETE:String = "spriteLoaderComplete";
        public static const PROGRESS:String = "spriteLoaderProgress";
        public static const ERROR:String = "spriteLoaderError";

        protected var m_started:Boolean;
        protected var m_itemCount:int;
        protected var m_urlsToLoad:Dictionary;
        protected var m_assetsToLoad:Dictionary;
        protected var m_loader:BulkLoader;
        protected var m_loaderContext:LoaderContext;

        /**
        * specify the url of a packed swf for loading
        */
        public function add(_id:String, _url:String, _assetClass:String = null):void {
            if(_url.indexOf("swf") != -1 && _assetClass == null) {
                throw new Error("Cannot load swf without specifying an assetClass");
            }

            if (m_urlsToLoad[_url] == null) {
                m_urlsToLoad[_url] = true;
                m_loader.add(_url, {id: _id, maxTries: 5, context: m_loaderContext} );
            }

            ++m_itemCount;
            m_assetsToLoad[_id] = {id: _id, assetClass: _assetClass};
        }

        public function start():void {
            if(m_itemCount == 0) {
                dispatchEvent(new AEvent(COMPLETE));
                clear();
                return;
            }

            if(!m_started) {
                m_loader.start();
                m_started = true;
            } else {
                throw new Error("SpriteLoader can only be started once.");
            }
        }

        protected function onAssetsComplete(_e:BulkProgressEvent):void {
            var e:AEvent = new AEvent(COMPLETE);
            // load into the bitmaps into BitmapDataManager and animations into the SpriteManager
            for each (var o:Object in m_assetsToLoad) {
                if(o.assetClass == null) {
                    processImage(o.id);
                } else {
                    processSwf(o.id, o.assetClass);
                }
            }

            dispatchEvent(e);
            clear();
        }

        protected function processImage(_id:String):void {
            if(BitmapDataManager.instance.getBitmapData(_id) == null) {
                BitmapDataManager.instance.setBitmapData(_id, m_loader.getBitmapData(_id, true));
            }
        }

        protected function processSwf(_id:String, _assetClassName:String):void {
            var assetClass:Class = ApplicationDomain.currentDomain.getDefinition(_assetClassName) as Class;
            if(BitmapDataManager.instance.getBitmapData(_id) == null) {
                BitmapDataManager.instance.setBitmapData(_id, (new assetClass()).bitmapData);
            }
        }

        protected function onAssetsProgress(_e:BulkProgressEvent):void {
            // redispatch with progress data in AEvent
            var e:AEvent = new AEvent(PROGRESS);
            e.bytesLoaded = _e.bytesLoaded;
            e.bytesTotal = _e.bytesTotal;
            e.bytesTotalCurrent = _e.bytesTotalCurrent;
            e.itemsLoaded = _e.itemsLoaded;
            e.itemsTotal = _e.itemsTotal;
            e.weightPercent = _e.weightPercent;
            dispatchEvent(e);
        }

        protected function onAssetsError(_e:Event):void {
            // redispatch error and pass on any failed to load items
            var e:AEvent = new AEvent(ERROR);
            var failedItems:Array = m_loader.getFailedItems();
            e.failedAssets = new Vector.<Object>();

            for each(var item:LoadingItem in m_loader.getFailedItems() ) {
                e.failedAssets.push({url: item.url.url, id: item._id});
            }
            dispatchEvent(e);
            clear();
        }

        protected function clear():void {
            m_loader.removeEventListener(BulkProgressEvent.COMPLETE, onAssetsComplete);
            m_loader.removeEventListener(BulkProgressEvent.PROGRESS, onAssetsProgress);
            m_loader.removeEventListener(BulkLoader.ERROR, onAssetsError);
            m_loader.clear();
            m_loader = null;
            m_urlsToLoad = null;
            m_assetsToLoad = null;
        }
    }
}
