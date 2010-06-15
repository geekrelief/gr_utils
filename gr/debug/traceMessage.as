package gr.debug {
    public function traceMessage(_msg:*, _depth:int=1, _stackOffset:int=3):String {
        CONFIG::debug {
        var output:String = "";
        var args:String = "()";
        var nl:String = "\n";
        var e:Error = new Error();
        var st:String = e.getStackTrace();
        if(st == null) return _msg;

        var lines:Array = st.split(nl).reverse();
        var start:int = _depth;
        if(lines.length - (_stackOffset+start) <= 0) {
            start = lines.length - _stackOffset;
        }

        for(var j:int = start; j > 0; --j) {
            var line:String = lines[lines.length-(_stackOffset+j)];
            var matches:Array = line.match(/\s+at\s(.+)\[.+:(\d+)\]/);

            if(matches == null) {
                matches = line.match(/\s+at\s(.+)/);
                matches[2] = "---";
            } 

            var lineNumber:String = matches[2];
            var func:String = matches[1].substr(0, matches[1].length -2);
            if(j == start)
                output += ("@ "+lineNumber+" "+func+args+nl);
            else
                output += (" - >        @ "+lineNumber+" "+func+args+nl);
        }

        output += (" - >          "+ String(_msg) + nl);

        if(!(_msg is String)) {
            output += (" - >        . "+ inspect(_msg) + nl);
        }

        return output;
        }
        
        return null;
    }
}
