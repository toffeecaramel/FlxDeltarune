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

	var thing:Typer;
	override public function create()
	{
		super.create();
		thing = new Typer({text: 'Well, Don\'t mind me, buddy. I\'m just testing out. these. frickin. separators. AH!', 
		speed: 0.07, separatorsPause: true, startDelay: 1.4});

		thing.paused = false;
		thing.onType.add((index, letter, text) -> 
		{
			trace('\nindex: $index\nletter: $letter\ntext: $text');
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(FlxG.keys.justPressed.P) thing.pause();
		if(FlxG.keys.justPressed.R) thing.resume();

		if(FlxG.keys.justPressed.SHIFT) thing.skip();
	}

	public function startBattle()
	{
	}
}
