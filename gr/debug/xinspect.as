package gr.debug
{

    import flash.utils.describeType;

    public function xinspect( o:Object ):String
    {
        // create a string to store the object's jsonstring value
        var s:String = "";

        // determine if o is a class instance or a plain object
        var classInfo:XML = describeType( o );
        if ( classInfo.@name.toString() == "Object" )
        {

            return inspect(o);
            /*
            // the value of o[key] in the loop below - store this 
            // as a variable so we don't have to keep looking up o[key]
            // when testing for valid values to convert
            var value:Object;

            // loop over the keys in the object and add their converted
            // values to the string
            for ( var key:String in o )
            {
                // assign value to a variable for quick lookup
                value = o[key];

                // don't add function's to the JSON string
                if ( value is Function )
                {
                    // skip this key and try another
                    continue;
                }

                // when the length is 0 we're adding the first item so
                // no comma is necessary
                if ( s.length > 0 ) {
                    // we've already added an item, so add the comma separator
                    s += ", "
                }

                s += key + ":" + String( value );
            }
            */
        }
        else // o is a class instance
        {
            // Loop over all of the variables and accessors in the class and 
            // serialize them along with their values.
            for each ( var v:XML in classInfo..*.( 
                        name() == "variable"
                        ||
                        ( 
                         name() == "accessor"
                         // Issue #116 - Make sure accessors are readable
                         && attribute( "access" ).charAt( 0 ) == "r" ) 
                        ) )
            {
                // Issue #110 - If [Transient] metadata exists, then we should skip
                if ( v.metadata && v.metadata.( @name == "Transient" ).length() > 0 )
                {
                    continue;
                }

                // When the length is 0 we're adding the first item so
                // no comma is necessary
                if ( s.length > 0 ) {
                    // We've already added an item, so add the comma separator
                    s += ", "
                }

                s += v.@name.toString() + ":" 
                    + String( o[ v.@name ] );
            }

        }

        if(s.length > 0) {
            return "{" + s + "}";
        } else {
            return s;
        }
    }
}
