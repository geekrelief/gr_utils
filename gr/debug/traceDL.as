package gr.debug
{
    import flash.display.DisplayObjectContainer;
    import flash.display.DisplayObject;

    public function traceDL(container:DisplayObjectContainer, options:* = undefined, indentString:String = "", depth:int = 0, childAt:int = 0):void
    {
        if (typeof options == "undefined") options = Number.POSITIVE_INFINITY;

        if (depth > options) return;

        const INDENT:String = "   ";
        var i:int = container.numChildren;

        while (i--)
        {
            var child:DisplayObject = container.getChildAt(i);
            var output:String = indentString + (childAt++) + ": " + child.name + " ➔ " + child;

            // debug alpha/visible properties
            output += "\t\talpha: " + child.alpha.toFixed(2) + "/" + child.visible;

            // debug x and y position
            output += ", @: (" + child.x + ", " + child.y + ")";

            // debug transform properties
            output += ", w: " + child.width + "px (" + child.scaleX.toFixed(2) + ")";
            output += ", h: " + child.height + "px (" + child.scaleY.toFixed(2) + ")"; 
            output += ", r: " + child.rotation.toFixed(1) + "°";

            if (typeof options == "number") trace(output);
                else if (typeof options == "string" && output.match(new RegExp(options, "gi")).length != 0)
                {
                    trace(output, "in", container.name, "➔", container);
                }

            if (child is DisplayObjectContainer) traceDL(DisplayObjectContainer(child), options, indentString + INDENT, depth + 1);
        }
    }
}
