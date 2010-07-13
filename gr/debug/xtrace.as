package gr.debug {
    public function xtrace(_msg:* = "", _depth:int=1):void {
        CONFIG::gr_debug {
            trace(" = > atrace "+traceMessage(xinspect(_msg), _depth));
        }
    }
}
