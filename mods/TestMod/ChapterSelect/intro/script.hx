import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxSprite;
import flixel.FlxG;
import backend.Asset;
import backend.game.DeltaText;

var soul:FlxSprite;
var logo:FlxSprite;
var chapter:DeltaText;
function create()
{
	soul = new FlxSprite().loadGraphic(state.getDeltaSoul());
	soul.alpha = 0.0001;
	state.add(soul);
	soul.screenCenter();
	
	logo = new FlxSprite().loadGraphic(state.getDeltaLogo());
	//logo.follow(soul);
	logo.alpha = 0.0001;
	state.add(logo);
	
	soul.scale.x = soul.scale.y = logo.scale.x = logo.scale.y = 2;
	
	chapter = new DeltaText();
    chapter.text = 'CHAPTER T';
    chapter.scale.set(2, 2);
    state.add(chapter);
    chapter.updateHitbox();
    chapter.screenCenter(0x10);
    chapter.alpha = 0.0001;

	FlxG.sound.playMusic(Asset.outSourcedSound('mods/TestMod/ChapterSelect/intro/ch4intro.ogg'), 0.8);
}

var soulFade:Bool = false;
var logoFade:Bool = false;
var chapterFade:Bool = false;
function postUpdate()
{
	if(FlxG.sound.music != null){
	
		if(FlxG.sound.music.time >= 5710 && !soulFade)
		{
			FlxG.sound.play(Asset.outSourcedSound('mods/TestMod/ChapterSelect/intro/greatshine.ogg'));
			soulFade = true;
		}
		
		if(FlxG.sound.music.time >= 7577 && !logoFade)
		{
			logoFade = true;
			FlxG.sound.play(Asset.outSourcedSound('mods/TestMod/ChapterSelect/intro/appear.ogg'));
		}
		
		if(FlxG.sound.music.time >=11366 && !chapterFade) chapterFade = true;
	}
	
	if(soulFade) soul.alpha += FlxG.elapsed;
	if(logoFade) logo.alpha += FlxG.elapsed / 2;
	if(chapterFade) chapter.alpha += FlxG.elapsed / 2;
	
	if(logo.alpha > 0.0001) logo.setPosition(soul.x, soul.y);
	chapter.y = logo.y + logo.height + 16;
	chapter.screenCenter(0x01);
}