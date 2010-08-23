package gr.state {
    import flash.utils.getTimer;
    import flash.utils.Dictionary;
    import gr.utils.printf;
    import gr.utils.StringUtils;

    // used to manage a history of transitions and states for a state machine
    public class TransitionNode {

        public var next:TransitionNode;

        public var fsm:IID;                 // The id of the object containing the states
        public var stateName:String;        // The name of the state we transitioned to
        public var signalName:String;       // The name of the signal that caused a transition to this state.
        public var signalParams:Dictionary; // The parameters of the signal that caused a transition to this state.
        public var signalTime:int;          // The time of the signal

        public function TransitionNode(_fsm:IID, _stateName:String, _signal:Signal = null) {
            fsm = _fsm;
            stateName = _stateName;
            if (_signal != null) {
                signalName = _signal.name;
                signalParams = new Dictionary();
                for (var prop:String in _signal) {
                    signalParams[prop] = _signal[prop];
                }
                signalTime = getTimer();
            }
        }

        public function toString():String {
            return printf("%s @ %s -> %s", signalName, StringUtils.formatMS(signalTime), stateName);
        }
    }
}
