package gr.debug {
    import gr.utils.StringUtils;
    public function atrace(_msg:* = "", _depth:int=1):void {
        CONFIG::gr_debug {
            trace(" = > atrace ("+StringUtils.formatMS()+") "+traceMessage(_msg, _depth));
        }
    }
}
