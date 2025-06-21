package game.battle;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.battle.*;
import game.chars.*;

class BattleSubState extends FlxSubState
{
    var bg:Background;
    var kris:CharBase;

    public static var battleTheme = 'rudebuster.ogg';
    public function new()
    {
        super();
        
        var awa = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(awa);
        
        bg = new Background();
        add(bg);
        bg.toAlpha = 1;

        //TODO: somehow get the player position on screen, and then move it to the side
        kris = new CharBase(70, 50, "kris/kris-battle");
        add(kris);
        kris.animation.play('attack', true);

        addUI();

        new FlxTimer().start(0.5, (_)-> start());
        FlxG.sound.play(Asset.sound('darkworld/battle/weaponpull.wav'));
    }

    var upperBox:FlxSprite;
    var box:FlxSprite;
    var testPanel:Panel;
    function addUI()
    {
        final p = 'darkworld/battle/UI'; //just to shorten some code lol

        upperBox = new FlxSprite().loadGraphic(Asset.image('$p/panels/panelClosed')); //yea
        upperBox.scale.x = 8; // lol
        upperBox.screenCenter(X);
        add(upperBox);
        
        testPanel = new Panel(0, 0, 'kris');
        add(testPanel);
        testPanel.screenCenter(X);
        testPanel.origin.y = testPanel.height;

        box = new FlxSprite().loadGraphic(Asset.image('$p/box'));
        add(box);
        
        box.y = upperBox.y = FlxG.height + (box.height * 2);
    }

    function start()
    {
        kris.animation.play('idle-loop');
        FlxG.sound.playMusic(Asset.sound('darkworld/battle-themes/$battleTheme', 'music'));

        FlxTween.tween(box, {y:FlxG.height - box.height}, 0.6, {ease: FlxEase.expoOut});
    }

    override public function update(delta:Float)
    {
        super.update(delta);    
        if(FlxG.keys.justPressed.P) testPanel.isOpen = !testPanel.isOpen;

        upperBox.y = box.y - upperBox.height + 2;
        testPanel.y = box.y - 36;
    }
}