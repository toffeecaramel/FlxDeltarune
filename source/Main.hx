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

		//fixes some stuff, but looks weird on fullscreen.
		//hm.
		//alright, I should figure that out later... I guess...
		//FlxG.scaleMode = new flixel.system.scaleModes.PixelPerfectScaleMode();

		var console = new DebugConsole(800, 400);
		console.visible = false;
		addChild(console);
		Logger.init(console);

		FlxG.updateFramerate = FlxG.drawFramerate = 30;
		FlxG.fixedTimestep = true;
	}
}
