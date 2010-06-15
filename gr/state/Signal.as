package gr.state {
    dynamic public class Signal {
        
        public var to:Hsm;
        public var from:Hsm;

        public static var EMPTY:Signal = new Signal("EMPTY", 0);
        public static var INIT:Signal = new Signal("INIT", 1);
        public static var ENTER:Signal = new Signal("ENTER", 2);
        public static var EXIT:Signal = new Signal("EXIT", 3);
        public static var CALLBACK:Signal = new Signal("CALLBACK", 4);
        public static var UPDATE:Signal = new Signal("UPDATE", 5);
        public static var ERROR:Signal = new Signal("ERROR", 6);

        public function Signal(_name:String, _id:int) {
            m_name = _name;
            m_id = _id;
        }

        private var m_name:String;
        public function get name():String {
            return m_name;
        }

        private var m_id:int;
        public function get id():int {
            return m_id;
        }

        private static var m_nextUserSignalId:int = 1024;
        public static function getNextSignal(_name:String):Signal {
            return new Signal(_name, ++m_nextUserSignalId);
        }

        public function toString():String {
            return "Signal " + m_name + ", "+ m_id;
        }
    }
}
