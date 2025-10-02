package;

import haxe.ui.Toolkit;
import openfl.display.Sprite;

class Main extends Sprite
{
	final preloadSndList = ['battle/weaponpull.wav'];
	final preloadMusList = ['battle-themes/rudebuster.ogg'];
	public function new()
	{
		super();
		FlxSprite.defaultAntialiasing = false;
		Toolkit.init();
		Toolkit.theme = 'dark';
		Toolkit.autoScale = false;
		haxe.ui.focus.FocusManager.instance.autoFocus = false;

        // TODO: make this work with the new mods system
        // actually I'll scrap this.
        // I'll do some preloader for mods
		/*
		
		for (mus in preloadMusList){
			for (snd in preloadSndList)
			{
				FlxG.sound.load(Asset.sound(mus, "music"));
				FlxG.sound.load(Asset.sound(snd));
			}
        }
        */
		
		var console = new DebugConsole(800, 400);
		console.visible = false;
		Logger.init(console);
		
		//addChild(new FlxGame(0, 0, frontend.mods.ChapterSelect));
		//addChild(new FlxGame(0, 0, game.editors.RoomEditor));
		addChild(new FlxGame(0, 0, Debugger));
		addChild(console);
		
        FlxG.autoPause = false;

		//fixes some stuff, but looks weird on fullscreen.
		//hm.
		//alright, I should figure that out later... I guess...
		//FlxG.scaleMode = new flixel.system.scaleModes.PixelPerfectScaleMode();

		FlxG.updateFramerate = FlxG.drawFramerate = 30;
		FlxG.fixedTimestep = true;
	}
}
