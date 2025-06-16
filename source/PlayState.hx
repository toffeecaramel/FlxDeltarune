package;

import backend.effects.*;
import backend.utils.*;
import com.gskinner.motion.GTween;
import com.gskinner.motion.easing.Sine;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.FlxTrail;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.battle.*;
import game.chars.*;
import game.ui.UIBox;

class PlayState extends FlxState
{
	var lilGroup:FlxGroup;
	var player:FlxSprite;
    override public function create():Void
	{
        super.create();

        var a = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
        add(a);

        box = new UIBox(10, 10);
        add(box);
        box.screenCenter();
    }
    var box:UIBox;
    override public function update(elapsed:Float):Void
	{
        super.update(elapsed);
    }
}

