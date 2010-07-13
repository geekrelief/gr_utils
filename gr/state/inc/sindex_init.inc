import flash.utils.describeType;

if (SIndex == null) {
    SIndex = new Dictionary();

    CONFIG::gr_debug {

        // discover states
        var type:XML = describeType(sindexTarget);

        for each(var method:XML in type.method) {
            var mname:String = method.@name.toString();
            var retType:String = method.@returnType.toString();
            var paramCount:int = method.parameter.length();
            var paramType:String = method.parameter.@type;
            if (mname.indexOf('s_') == 0 
                && retType == "int" 
                && paramCount == 1 
                && paramType == "gr.state::Signal") {
                SIndex[sindexTarget[mname]] = mname;
            }
        }

    }
}
