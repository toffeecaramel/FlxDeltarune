package;

import openfl.display.Sprite;

class Main extends Sprite
{
	final preloadSndList = ['battle/weaponpull.wav'];
	final preloadMusList = ['battle-themes/rudebuster.ogg'];
	public function new()
	{
		super();
		FlxSprite.defaultAntialiasing = false;
		

        // TODO: make this work with the new mods system
		/*
		
		for (mus in preloadMusList){
			for (snd in preloadSndList)
			{
				FlxG.sound.load(Asset.sound(mus, "music"));
				FlxG.sound.load(Asset.sound(snd));
			}
        }
        */
		//addChild(new FlxGame(0, 0, frontend.mods.ModSelectState));
		addChild(new FlxGame(0, 0, Debugger));
        FlxG.autoPause = false;
	}
}
