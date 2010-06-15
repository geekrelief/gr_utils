package gr.utils {
    public class Functional {

        // partial application
        public static function pa(_that:Object, _f:Function, ... _args):Function {
            return function(..._more): * {
                return _f.apply(_that, _args.concat(_more));
            }
        }

        // partial application appended
        public static function paa(_that:Object, _f:Function, ... _post):Function {
            return function(..._args): * {
                return _f.apply(_that, _args.concat(_post));
            }
        }
        
        // partial application in the middle?
    }
}
