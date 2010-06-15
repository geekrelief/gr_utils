package gr.debug {
    public function atrace(_msg:* = "", _depth:int=1):void {
        CONFIG::debug {
            trace(" = > atrace "+traceMessage(_msg, _depth));
        }
    }
}
