package game.battle;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;

class AttackBar extends FlxSpriteContainer
{
    private var bar = new FlxSprite().loadGraphic(Asset.image('darkworld/battle/ui/fightBar'));
    private var button = new FlxSprite().loadGraphic(Asset.image('darkworld/battle/ui/fightBar-button'), true, 10, 38);

    /**
     * Signal dispatched when the player presses a key.
     * The result is just a float value that goes from 0 to 1 depending on accuracy.
     * You can multiply it by the damage value you want.
     */
    public final onPress = new FlxTypedSignal<(damage:Float)->Void>();

    /**
     * Whether or not allow pressing a key.
     */
    public var canPress:Bool = false;
    
    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);

        add(bar);
        button.animation.add('default', [0], 1);
        button.animation.add('press', [1], 1);
        button.animation.play('press');

        add(button);

        //TODO: Adjust this so there's no flaws for other party members.
        button.x = x + FlxG.random.float(200, 150);
    }

    private var pressed:Bool = false;
    override public function update(delta:Float)
    {
        super.update(delta);

        if(visible && active && !pressed)
            button.x -= delta * 124;

        if(FlxG.keys.justPressed.ENTER && canPress && !pressed)
        {
            pressed = true;
            button.animation.play('default', true);

            // this shit melted my brain but it works i guess
            final result = 1 - FlxMath.bound(Math.abs(button.x - (bar.x + 4)) / bar.width, 0, 1);
            onPress.dispatch(result);

            if(result >= 0.96) button.color = FlxColor.ORANGE;
            trace(result);

            FlxTween.tween(button, {"scale.x": 2, "scale.y": 2, alpha: 0}, 0.8, {ease: FlxEase.circOut});
        }
    }
}