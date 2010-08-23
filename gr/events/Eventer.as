package gr.events {

    import flash.events.*;
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;
    import flash.utils.Dictionary;
    import gr.debug.atrace;

    /**
    * Eventer simplifies that adding and removing of events listeners to a target object.
    * It is a proxy for adding and remove event listeners and has then option of triggering listener and removing it.
    * Eventer makes common adding and removing patterns faster to implement.
    * <p/> 
    * Example Usage:
    * <listing>
        var loader:Loader = new Loader();
        var ev:Eventer = new Eventer(loader);
        ev.complete(completed); // adds the event listener for Event.COMPLETE
        ev.errorHandler = errorHandler;
        ev.ioError(errored); // if this event is triggered the eventer instance triggers the errorHandler and resets
        ev.click(clicked, true); // accepts clicked once
        ev.clear(completed); // removes the event listener for Event.COMPLETE
        ev.reset(); // removes all registered listeners from loader
    * </listing>
    *
    */
    public dynamic class Eventer extends Proxy {

        /**
        * The object to which event listeners are attached.
        */
        public var obj:*;

        /**
        * Calls this function on error.
        */
        public var errorHandler:Function; 

        protected var m_listeners:Dictionary;


        public function Eventer(_obj:*) {
            obj = _obj;
            m_listeners = new Dictionary(true);
        }

        override flash_proxy function callProperty(_eventType:*, ..._rest):* {
            var type:String = String(_eventType);
            var handler:Function = _rest[0];
            var once:Boolean = (_rest.length == 2 ? Boolean(_rest[1]) : false);

            return setup(type, handler, once);
        }

        public function setup(_type:String, _handler:Function, _once:Boolean = false):Boolean {
            switch (_type) {
                // non errors
                case Event.COMPLETE: 
                case Event.INIT: 
                case ProgressEvent.PROGRESS:
                case MouseEvent.CLICK:
                case MouseEvent.MOUSE_DOWN:
                case MouseEvent.MOUSE_UP:
                case MouseEvent.MOUSE_MOVE:
                case MouseEvent.MOUSE_OUT:
                case MouseEvent.MOUSE_OVER:
                case MouseEvent.ROLL_OVER:
                case MouseEvent.ROLL_OUT:
                case MouseEvent.MOUSE_WHEEL:
                case Event.MOUSE_LEAVE:
                case Event.ADDED_TO_STAGE:
                case Event.RESIZE:
                case Event.ENTER_FRAME:
                case Event.EXIT_FRAME:
                case FullScreenEvent.FULL_SCREEN:
                case FocusEvent.FOCUS_IN:
                case FocusEvent.FOCUS_OUT:
                case KeyboardEvent.KEY_UP:
                case KeyboardEvent.KEY_DOWN:
                    add(_type, _handler, _once);
                    return true;

                // errors
                case IOErrorEvent.IO_ERROR:
                case SecurityErrorEvent.SECURITY_ERROR:
                    fail(_type, _handler, _once);
                    return true;

                default:
                    // do not know the type not sure what to do, 
                    // for more events extend and override
                    return false;
            }
        }

        /**
        * Resets the Eventer and nullifies its reference to the EventDispatcher
        */
        public function reset():void {
            for (var handler:String in m_listeners) {
                var listener:Object = m_listeners[handler];
                obj.removeEventListener(listener.event, listener.cb);
            }
            m_listeners = new Dictionary(true);
            obj = null;
        }

        /**
        * Clears an individual handler
        */
        public function clear(_handler:Function):void {
            var listener:Object = m_listeners[_handler];
            obj.removeEventListener(listener.event, listener.cb);
            delete m_listeners[_handler];
        }

        protected function getGoodListener(_handler:Function, _once:Boolean):Function {
            return function (_e:*):void {
                _handler(_e);
                if (_once) {
                    var listener:Object = m_listeners[_handler];
                    obj.removeEventListener(listener.event, listener.cb);
                    delete m_listeners[_handler];
                }
            }
        }

        protected function getErrorListener(_handler:Function):Function {
            return function (_e:*):void {
                _handler(_e);
                reset();
                if (errorHandler != null) {
                    errorHandler(_e);
                }
            }
        }

        public function add(_type:String, _handler:Function, _once:Boolean = false):void {
            var cb:Function = getGoodListener(_handler, _once);
            m_listeners[_handler] = {event:_type, cb: cb};
            obj.addEventListener(_type, cb);
        }

        public function fail(_type:String, _handler:Function, _once:Boolean = false):void {
            var cb:Function = getErrorListener(_handler);
            m_listeners[_handler] = {event:_type, cb:cb};
            obj.addEventListener(_type, cb);
        }
    }
}
