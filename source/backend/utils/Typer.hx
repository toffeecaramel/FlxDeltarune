package backend.utils;

import flixel.FlxG;
import flixel.util.FlxSignal;

using StringTools;

typedef TyperStruct = {
    /**
     * The text that will be displayed once typing.
     */
    var ?text:String;

    /**
     * The speed in which the text will type.
     */
    var ?speed:Float;

    /**
     * Whether should it start with a delay.
     */
    var ?startDelay:Float;

    /**
     * Whether the typer should do a small pause when there's characters such as ",", ".", "!", "?", etc...
     */
    var ?separatorsPause:Bool;
}

@:publicFields //I am addicted to using public fields, help

/**
 * A class for helping out on typed-like texts.
 */
class Typer
{
    // -- Public variables (variables that can be changed/accessed from outside) -- //
    
    /**
     * All the typer parameters, such as text, speed, etc.
     */
    var parameters:TyperStruct;

    /**
     * Whether the typer is paused or not.
     */
    var paused:Bool = true;

    /**
     * The last displayed letter's index.
     */
    var curIndex:Int = 0;

    /**
     * The last displayed letter.
     */
    var curLetter:String = '';

    /**
     * The last displayed text.
     */
    var curText:String = '';

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
    
    // -- Private variables (Only can be accessed by this class, unless @:privateAccess) -- //

    /**
     * A timer used for every character.
     */
    private var _timer:Float = 0;

    /**
     * The characters in which will pause the text for a brief time. Only works if `separatorsPause` is true.
     */
    private final separators:Array<String> = [
        ',', '.', ';', ':', '!', '?' //TODO: maybe add more to this? 
    ];

    // -- Regular functions -- //

    function new(?parameters:TyperStruct)
    {
        this.parameters = parameters ?? {
            text: 'Hello, Dark World!',
            speed: 0.04,
            startDelay: 0,
            separatorsPause: true
        };

        FlxG.signals.postUpdate.add(update);
    }

    function update()
    {
        if (paused || parameters.text == null || curIndex >= parameters.text.length) return;

        _timer += FlxG.elapsed;
        if (_timer >= parameters.speed)
        {
            _timer = 0;
            curLetter = parameters.text.charAt(curIndex++);
            curText += curLetter;
            onType.dispatch(curIndex, curLetter, curText);

            if (curIndex >= parameters.text.length)
                onFinish.dispatch();
        }
    }

    // -- Get/Setters Functions (nothing so far) -- //
}