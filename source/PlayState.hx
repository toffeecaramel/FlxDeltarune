package;

import DialogueBox.Positioning;
import backend.utils.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.FlxTrail;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import game.battle.*;
import game.chars.*;

class PlayState extends FlxState
{
	var lilGroup:FlxGroup;
	var player:FlxSprite;

    override public function create():Void
	{
        super.create();

        lilGroup = new FlxGroup();
        add(lilGroup);

        var wall = new FlxSprite(100, 100);
        wall.makeGraphic(128, 64, 0xff555555);
        lilGroup.add(wall);

        player = new FlxSprite(110, 150);
        player.makeGraphic(32, 48, 0xff0000ff);
        lilGroup.add(player);
    }

    override public function update(elapsed:Float):Void
	{
        super.update(elapsed);

        if (FlxG.keys.pressed.LEFT) player.x -= 120 * elapsed;
        if (FlxG.keys.pressed.RIGHT) player.x += 120 * elapsed;
        if (FlxG.keys.pressed.UP) player.y -= 120 * elapsed;
        if (FlxG.keys.pressed.DOWN) player.y += 120 * elapsed;

        lilGroup.members.sort((a,b) -> Std.int(cast(a, FlxSprite).y - cast(b, FlxSprite).y));
    }
}

