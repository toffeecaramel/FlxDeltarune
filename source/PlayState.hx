package;

import DialogueBox.Positioning;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.effects.FlxTrail;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import game.battle.*;
import game.chars.*;

class PlayState extends FlxState
{
	private var box:DialogueBox;
	final datas:Array<Dynamic> = 
	[
		['default', null, null, '* You decide to kill\nyourself rn', BOTTOM],
		['darkworld', null, null, '* You decide to kill\nyourself but in the\ndark world, wow.', TOP],
		['default', 'susie', 'confused', '* Kris... WHERE THE\nFUCK ARE WE?!', BOTTOM],
		['darkworld', 'noelle', 'angry', '* ...I hate you.', CENTER]
	];

	var bg = new Background();
	var krisGhost:FlxTrail;

	override public function create()
	{
		super.create();
		
		add(bg);
		box = new DialogueBox();
		add(box);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if(FlxG.keys.justPressed.O)
		{
			final data:Array<Dynamic> = datas[FlxG.random.int(0, datas.length - 1)];
			box.show(data[0], data[1], data[2], data[3], data[4]);
			trace(data);
		}
	}

	public function startBattle()
	{
	}
}
