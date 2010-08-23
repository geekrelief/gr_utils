package gr.state {
    public class StateContext {
        
        public var id:int;
        public var className:String;
        public var stateName:String;
        public var state:Function;

        public function StateContext(_id:int, _className:String, _stateName:String, _state:Function) {
            id = _id;
            className = _className;
            stateName = _stateName;
            state = _state;
        }
    }
}
