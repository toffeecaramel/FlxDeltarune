package game.battle;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;

/**
 * The attack bar, used when choosing the 'fight' option in a battle.
 */
class AttackBar extends FlxSpriteContainer
{
    /**
     * The bar sprite.
     */
    private var bar = new FlxSprite().loadGraphic(Asset.image('battle/ui/fightBar'));

    /**
     * The button (hit) sprite.
     */
    private var button = new FlxSprite().loadGraphic(Asset.image('battle/ui/fightBar-button'), true, 10, 38);

    /**
     * Signal dispatched when the player presses a key.
     * The result is just a float value that goes from 1 to 2 depending on accuracy.
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
        button.animation.play('default');

        add(button);

        //TODO: Adjust this so there's no flaws for other party members.
        //TODO²: Make hits count in order too.
        button.x = x + FlxG.random.float(200, 150);
    }

    private var pressed:Bool = false;
    override public function update(delta:Float)
    {
        super.update(delta);

        //TODO: Check if this is accurate??
        if(visible && active && !pressed)
            button.x -= delta * 152;

        if(FlxG.keys.justPressed.ENTER && canPress && !pressed)
        {
            pressed = true;
            button.animation.play('press', true);

            // this shit melted my brain but it works i guess
            final result = 1 - FlxMath.bound(Math.abs(button.x - (bar.x + 4)) / bar.width, 0, 1);
            onPress.dispatch(result);

            if(result >= 0.96) button.color = FlxColor.ORANGE;

            FlxTween.tween(button, {"scale.x": 3, "scale.y": 3, alpha: 0}, 0.8, {ease: FlxEase.circOut});
        }
    }

    /**
     * Resets the fields, and randomizes the initial position.
     */
    public function r()
    {
        button.scale.set(1,1);
        button.alpha = 1;
    }
}