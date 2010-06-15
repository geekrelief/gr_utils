package gr.events {
    import flash.events.Event;

    dynamic public class AEvent extends Event {

        public var data:*;
        public function AEvent(_type:String, _data:* = null, _bubbles:Boolean = false, _cancelable:Boolean = false) {
            super(_type, _bubbles, _cancelable);
            data = _data;
            if(data != null) {
                for(var i:* in data) {
                    this[i] = data[i];
                }
            }    
        }

        public override function toString():String {
            var args:Array = ["AEvent", "type", "target", "currentTarget"];
            if(data != null) {
                for(var i:* in data) {
                    args.push(i);
                }
            }
            return formatToString.apply(this, args);
        }
    }
}
