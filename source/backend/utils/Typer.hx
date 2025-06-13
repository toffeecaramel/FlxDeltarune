package backend.utils;

import flixel.util.FlxSignal;

using StringTools;

// Umm nvm this I'll move it to somewhere else
/*typedef DialogData = {
    var speed:Float;
    var separatorsPause:Bool;
    var text
}*/

@:publicFields //I am addicted to using public fields, help
class Typer
{
    // -- Public variables (variables that can be changed/accessed from outside) -- //

    /**
     * The text that will be displayed once typing.
     * To start the typer, call `start()`
     */
    var text:String = 'Hello, Dark World!';

    /**
     * The speed in which the text will type.
     */
    var speed:Float = 0.04;

    /**
     * The current letter index.
     */
    var curIndex:Int = 0;

    /**
     * The last displayed letter.
     */
    var curLetter:String = '';

    /**
     * Signal dispatched when the typing starts.
     */
    final onStart = new FlxTypedSignal<Void->Void>();

    /**
     * Signal dispatched when a text is being typed.
     */
    final onType = new FlxTypedSignal<(curIndex:Int, curLetter:String, curFullText:String)->Void>();

    /**
     * Signal dispatched when the text finishes typing.
     */
    final onFinish = new FlxTypedSignal<Void->Void>();

    //TODO: an array for keys that skips the text to when it finishes.
    
    // -- Private variables (Only can be accessed by this class, unless @:privateAccess) -- //

    /**
     * Whether the typer is paused or not.
     */
    private var paused:Bool = true;
}