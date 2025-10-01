package frontend.mods;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import lime.app.Application;
import backend.game.*;

class IntroState extends FlxState
{
	var script:rulescript.RuleScript;

	override public function create():Void
	{
		super.create();
		script = Asset.script('mods/${curMod.info.modName}/ChapterSelect/intro/script', curMod.info.bytecodeInterp);
        setScriptVar(script, 'state', this);
		callScriptMethod(script, 'create', true);
	}

	override public function update(delta:Float):Void
	{
		if(script.variables.exists('preUpdate')) callScriptMethod(script, 'preUpdate', true);
		super.update(delta);
		if(script.variables.exists('postUpdate')) callScriptMethod(script, 'postUpdate', true);
	}

	public function getDeltaLogo():flixel.graphics.FlxGraphic
		return Asset.image('ui/logo');

	public function getDeltaSoul():flixel.graphics.FlxGraphic
		return Asset.image('ui/logo-heart');
}