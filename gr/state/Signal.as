package gr.state {

    import flash.utils.Dictionary;
    import gr.debug.atrace;

    dynamic public class Signal {
        
        public static var SignalIndex:Dictionary = new Dictionary();

        public static var PARENT:Signal    = new Signal("PARENT"   , 0); // hsm parent discovery
        public static var INIT:Signal      = new Signal("INIT"     , 1); // hsm initial transition
        public static var ENTER:Signal     = new Signal("ENTER"    , 2); // enter the tate
        public static var EXIT:Signal      = new Signal("EXIT"     , 3); // exit the state
        public static var CALLBACK:Signal  = new Signal("CALLBACK" , 4); // callback into the state post enter

        public function Signal(_name:String, _id:int) {
            m_name = _name;
            m_id = _id;

            if (SignalIndex[m_name] != null) {
                throw new Error("Signal has a duplicate name in the SignalIndex: "+m_name +" "+SignalIndex[m_name].id);
            }

            SignalIndex[m_name] = this;
        }

        public var to:IID;

        private var m_name:String;
        public function get name():String {
            return m_name;
        }

        private var m_id:int;
        public function get id():int {
            return m_id;
        }
        
        private var m_recordable:Boolean;
        public function get recordable():Boolean { return m_recordable; }
        public function set recordable(_recordable:Boolean):void { m_recordable = _recordable; }

        private static var m_nextUserSignalId:int = 1024;
        public static function nextSignal(_name:String):Signal {
            return new Signal(_name, ++m_nextUserSignalId);
        }

        public function toString():String {
            return "(Signal - " + m_name + " : " + m_id+ ")";
        }
    }
}
