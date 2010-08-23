package gr.state {

    import flash.utils.Dictionary;

    public class MachineIndex {

        protected var m_index:Dictionary;
        protected var NEXT_ID:int = 1;

        public function MachineIndex() {
            m_index = new Dictionary(true);
        }

        public function register(_fsm:IID):void {
            _fsm.id = NEXT_ID++;
            m_index[_fsm.id] = _fsm;
        }

        public function id(_id:int):* {
            return m_index[_id]
        }
    }
}
