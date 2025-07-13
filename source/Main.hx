package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import game.battle.*;
import hxFileManager.FileManager;
import openfl.display.Sprite;

class Main extends Sprite
{
	final preloadSndList = ['darkworld/battle/weaponpull.wav'];
	final preloadMusList = ['darkworld/battle-themes/rudebuster.ogg'];
	public function new()
	{
		super();
		FlxSprite.defaultAntialiasing = false;
		FileManager.initThreadPool();
		
		addChild(new FlxGame(0, 0, PlayState));
		
		for (mus in preloadMusList)
			for (snd in preloadSndList)
			{
				FlxG.sound.load(Asset.sound(mus, "music"));
				FlxG.sound.load(Asset.sound(snd));
			}
	}
}
