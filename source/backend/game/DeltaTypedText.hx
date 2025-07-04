package backend.game;

import backend.utils.Typer;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSignal;

class DeltaTypedText extends FlxTypedGroup<FlxBasic>
{
    public var textDisplay:DeltaText;
    public var typer:Typer;

    public function new(x:Float, y:Float, ?params:TyperStruct)
    {
        super();

        textDisplay = new DeltaText();
        add(textDisplay);

        typer = new Typer(params);

        typer.onType.add(function(curIndex, curLetter, curFullText)
        {
            textDisplay.text = curFullText;
        });
        typer.resume();

        add(typer);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}
