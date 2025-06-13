package;

import DialogueBox.Positioning;
import backend.utils.*;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.effects.FlxTrail;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import game.battle.*;
import game.chars.*;

class PlayState extends FlxState
{
	var bg = new Background();

	override public function create()
	{
		super.create();
		var thing = new Typer();
		thing.paused = false;
		thing.onType.add((index, letter, text) -> 
		{
			trace('\nindex: $index\nletter: $letter\ntext: $text');
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function startBattle()
	{
	}
}
