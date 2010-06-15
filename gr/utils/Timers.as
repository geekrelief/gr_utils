package gr.utils {
    import flash.utils.getTimer;
    import flash.utils.Dictionary;
    
    public class Timers {

        public static function init():void {
            m_starts = new Dictionary();
            m_accum = new Dictionary();
            m_activations = new Dictionary();
        }

        private static var m_starts:Dictionary;
        private static var m_accum:Dictionary;
        private static var m_activations:Dictionary;

        public function Timers() {
        }

        public static function start(_id:* = true):void {
            m_starts[_id] = getTimer();
        }

        public static function elapsed(_id:* = true):int {
            return getTimer() - m_starts[_id];
        }

        public static function enter(_id:* = true):void {
            m_starts[_id] = getTimer();
            if(m_accum[_id] == null) {
                m_accum[_id] = 0;
                m_activations[_id] = 0;
            }
        }

        public static function exit(_id:* = true):void {
            m_accum[_id] += getTimer() - m_starts[_id];
            m_activations[_id]++;
        }

        public static function accumulated(_id:* = true):int {
            return m_accum[_id];
        }

        public static function accumulations():String {
            var out:String = "---Accumlated: \n";
            for (var id:String in m_accum) {
                out += (id+" - "+m_accum[id]+" - "+(m_accum[id]/m_activations[id])+"\n");
            }
            out += "\n";
            return out;
        }
    }
}
