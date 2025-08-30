package backend.utils;

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
class Typer extends FlxBasic
{
    // -- Public variables (variables that can be changed/accessed from outside) -- //
    
    /**
     * All the typer parameters, such as text, speed, etc.
     */
    var parameters(default, set):TyperStruct;

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

    /**
     * Creates a new typer.
     * @param parameters A TyperStruct.
     */
    function new(?parameters:TyperStruct)
    {
        // just some default values in case its null :)
        this.parameters = parameters ?? {
            text: 'Hello, Dark World!',
            speed: 0.04,
            startDelay: 0,
            separatorsPause: true
        };

        super();
    }

    private var _pauseTimer:Float = 0;
    private var _startDelayTimer:Float = 0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        // kinda obvious, but just pause in case of any these conditions
        if (paused || parameters.text == null || curIndex >= parameters.text.length) return;

        // start delay handle
        if (_startDelayTimer >= 0)
        {
            _startDelayTimer -= elapsed;
            if (_startDelayTimer <= 0)
                onStart.dispatch();
            return;
        }
        
        // separators pause handle
        if (_pauseTimer > 0)
        {
            _pauseTimer -= elapsed;
            return;
        }

        // display text when the timer's above the speed thing
        _timer += elapsed;
        if (_timer >= parameters.speed)
        {
            _timer = 0;
            curLetter = parameters.text.charAt(curIndex++);
            curText += curLetter;
            onType.dispatch(curIndex, curLetter, curText);

            // if the current character is the one in the separators
            if (parameters.separatorsPause && separators.contains(curLetter))
                _pauseTimer = parameters.speed * 4;

            // when complete
            if (curIndex >= parameters.text.length)
                onFinish.dispatch();
        }
    }

    /**
     * Ends the text and stops the typer.
     */
    function skip()
    {
        if (parameters.text == null) return;

        _startDelayTimer = 0;
        _pauseTimer = 0;
        _timer = 0;

        curText = parameters.text;
        curIndex = curText.length;
        curLetter = curText.charAt(curText.length - 1);

        onType.dispatch(curIndex, curLetter, curText);
        onFinish.dispatch();
    }

    /**
     * Pauses the typer.
     */
    function pause() return paused = true;

    /**
     * Resumes the typer.
     */
    function resume() return paused = false;

    // -- Get/Setters Functions -- //
    
    @:noCompletion function set_parameters(parameters:TyperStruct):TyperStruct
    {
        this.parameters = parameters;
        curIndex    = 0;
        curText     = "";
        curLetter   = "";
        paused      = false;
        _timer      = 0;
        _pauseTimer = 0;
        _startDelayTimer = this.parameters?.startDelay ?? 0;
        return this.parameters;
    }
}