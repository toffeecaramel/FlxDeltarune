package backend.utils;

import flixel.FlxG;
import openfl.Lib;
import lime.app.Application;

@:publicFields
class DeltaUtils 
{
    public static function changeResolution(width:Int, height:Int):Void
    {
    	FlxG.resizeWindow(width, height);
        FlxG.resizeGame(width, height);

        final window = Application.current.window;
        if (window != null) {
            final screenWidth = window.display.bounds.width;
            final screenHeight = window.display.bounds.height;

            window.x = Std.int((screenWidth - width) / 2);
            window.y = Std.int((screenHeight - height) / 2);
        }
    }
}
