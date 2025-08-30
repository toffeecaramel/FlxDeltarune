package backend.effects;

import flixel.tweens.FlxEase;
import backend.game.interfaces.IEffect;
/**
 * A class for applying a pulse effect to sprites.
 */
class DeltaPulse extends FlxBasic implements IEffect
{
    /**
     * The target sprite in which will pulse.
     */
    public var target:FlxSprite;

    /**
     * The duration of a full cycle.
     */
    public var duration:Float;

    /**
     * The amplitude (how much it'll scale)
     */
    public var amplitude:Float;

    /**
     * Whether to use a smooth (quad) easing or not.
     */
    public var ease:Bool;
    
    private var _timer:Float = 0;
    private var _baseScaleX:Float;
    private var _baseScaleY:Float;

    /**
     * @param target    The sprite to pulse
     * @param duration  Seconds for a full pulse cycle
     * @param amplitude Max additional scale (e.g., 0.2 for 120% at peak)
     * @param ease    Use smooth easing if true, linear otherwise
     */
    public function new(target:FlxSprite, duration:Float = 1.0, amplitude:Float = 0.2, ease:Bool = true)
    {
        this.target = target;
        this.duration = duration;
        this.amplitude = amplitude;
        this.ease = ease;
        
        _baseScaleX = target.scale.x;
        _baseScaleY = target.scale.y;
        super();
    }

    /**
     * Stops the effect and restores original scale.
     */
    public function stop():Void
    {
        active = false;
        _timer = 0;
        target.scale.set(_baseScaleX, _baseScaleY);
    }

    /**
     * Restart the effect from beginning.
     */
    public function restart():Void
    {
        if (!active)
            active = true;
        _timer = 0;
    }

    override public function update(elapsed:Float):Void
    {
        if (!active || target == null) return;

        super.update(elapsed);
        _timer += elapsed;

        // loop timer
        if (_timer > duration) _timer -= duration;
        var half = duration * 0.5;
        var t = _timer < half ? (_timer / half) : ((duration - _timer) / half);

        // t ranges 0->1->0
        var scaleOffset = amplitude * (ease ? FlxEase.quadInOut(t) : t);
        target.scale.set(_baseScaleX + scaleOffset, _baseScaleY + scaleOffset);
    }
}
