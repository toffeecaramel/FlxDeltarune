package;

import backend.effects.*;
import backend.game.DeltaText;
import backend.game.DeltaTypedText;
import backend.utils.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.FlxTrail;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.battle.*;
import game.chars.*;
import game.ui.*;
import zero.flixel.ui.RichText;

class PlayState extends FlxState
{
	var lilGroup:FlxGroup;
	var player:FlxSprite;
    var richText:RichText;
    var dialogueBox:DialogueBox;

    override public function create():Void
	{
        super.create();
    }

    override public function update(elapsed:Float):Void
	{
        super.update(elapsed);
    }
}