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
        kris.scale.set(2, 2);

        addUI();
        new FlxTimer().start(0.65, (_)-> start());
    }

    var box:FlxSprite;
    var testPanel:Panel;
    function addUI()
    {
        final p = 'darkworld/battle/UI'; //just to shorten some code lol

        testPanel = new Panel(0, 0, 'kris');
        add(testPanel);
        testPanel.screenCenter(X);
        
        box = new FlxSprite().loadGraphic(Asset.image('$p/box'));
        add(box);

        box.y = FlxG.height + box.height;
        testPanel.y = FlxG.height + testPanel.height;
    }

    function start()
    {
        kris.animation.play('idle-loop');
        FlxG.sound.playMusic(Asset.sound('darkworld/battle-themes/rudebuster', 'music'));

        FlxTween.tween(box, {y:FlxG.height - box.height}, 0.6, {ease: FlxEase.expoOut});
    }

    override public function update(delta:Float)
    {
        super.update(delta);    
        if(FlxG.keys.justPressed.P) testPanel.isOpen = !testPanel.isOpen;

        testPanel.y = FlxMath.lerp(testPanel.y, box.y - (testPanel.height - 2), delta * 12);
    }
}