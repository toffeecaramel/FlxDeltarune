package backend.effects;

import backend.game.interfaces.IEffect;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;

import flixel.animation.FlxAnimation;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.group.*;
import flixel.system.FlxAssets;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;

/**
 * A modified version of FlxTrail with some cool additions.
 * @author Gama11 (Original Trail)
 */
class DeltaTrail extends flixel.group.FlxSpriteContainer
{
	/**
	 * Stores the FlxSprite the trail is attached to.
	 */
	public var target(default, null):FlxSprite;

	/**
	 * How often to update the trail
	 */
	public var delay:Int;

	/**
	 * Whether the trail generation is paused
	 */
	public var paused:Bool = false;

	/**
	 * The velocity applied to each trail sprite.
	 */
	public var trailVelocity:FlxPoint;

	/**
	 * Whether to check for x changes or not.
	 */
	public var xEnabled:Bool = true;

	/**
	 * Whether to check for y changes or not.
	 */
	public var yEnabled:Bool = true;

	/**
	 * Whether to check for angle changes or not.
	 */
	public var rotationsEnabled:Bool = true;

	/**
	 * Whether to check for scale changes or not.
	 */
	public var scalesEnabled:Bool = true;

	/**
	 * Whether to check for frame changes of the parent FlxSprite or not.
	 */
	public var framesEnabled:Bool = true;

	/**
	 * The maximum number of trail sprites.
	 */
	public var trailLength:Int = 10;

	var _counter:Int = 0;
	var _graphic:flixel.system.FlxAssets.FlxGraphicAsset;
	var _initialAlpha:Float = 0.4;
	var _alphaDecrement:Float = 0.05;
	var _spriteOrigin:FlxPoint;

	/**
	 * Creates a Trail effect for a FlxSprite.
	 * 
	 * @param target The FlxSprite the trail will be attached to.
	 * @param graphic The image to use for the Trail Sprites. If none, will use the FlxSprite's graphic.
	 * @param length The maximum amount of sprites the trail can have.
	 * @param delay How often to update the trail. 0 will update it every frame.
	 * @param alpha The initial alpha value for newly created sprites for the trail.
	 * @param diff How much to decrement the alpha of existing sprites when a new one is added
	 */
	public function new(target:FlxSprite, ?graphic:flixel.system.FlxAssets.FlxGraphicAsset,
		length = 10, delay = 3, alpha = 0.4, diff = 0.05):Void
	{
		super();

		_spriteOrigin = FlxPoint.get().copyFrom(target.origin);

		this.target = target;
		this.delay = delay;
		this._graphic = graphic;
		this._initialAlpha = alpha;
		this._alphaDecrement = diff;
		this.trailLength = length;
		this.trailVelocity = FlxPoint.get(0, 0);

		solid = false;
	}

	override public function destroy():Void
	{
		FlxDestroyUtil.put(_spriteOrigin);
		_spriteOrigin = null;

		target = null;
		_graphic = null;
		trailVelocity.put();
		trailVelocity = null;

		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		_counter++;

		if(_counter >= delay && countLiving() < trailLength)
		{
			_counter = 0;

			for(i in 0...members.length)
			{
				final sprite = members[i];
				if(sprite != null && sprite.exists)
				{
					sprite.alpha -= _alphaDecrement;
					if(sprite.alpha <= 0) sprite.kill();
				}
			}

			// emit new sprite if still under length
			if(countLiving() < trailLength && !paused)
				emitTrailSprite();
		}

		// enforces max length killing oldes if exceeded
		while (countLiving() > trailLength) killOldest();

		super.update(elapsed);
	}

	private function emitTrailSprite():Void
	{
	    var trailSprite:FlxSprite = recycle(FlxSprite);
	    trailSprite.active = true;
	    trailSprite.solid = solid;
	    trailSprite.alpha = _initialAlpha;
	    trailSprite.offset.copyFrom(target.offset);
	    trailSprite.setPosition(target.x, target.y);

	    if(rotationsEnabled)
	    {
	        trailSprite.angle = target.angle;
	        trailSprite.origin.copyFrom(_spriteOrigin);
	    }

	    if(scalesEnabled)
	        trailSprite.scale.copyFrom(target.scale);

	    if(_graphic == null)
	    {
	        trailSprite.loadGraphicFromSprite(target);
	        if(framesEnabled && target.animation.curAnim != null)
	        {
	            trailSprite.animation.frameIndex = target.animation.frameIndex;
	            trailSprite.animation.curAnim.frameRate = 0;
	            trailSprite.flipX = target.flipX;
	            trailSprite.flipY = target.flipY;
	            //trailSprite.animation.curAnim = target.animation.curAnim;
	        }
	    }
	    else trailSprite.loadGraphic(_graphic);

	    trailSprite.velocity.copyFrom(trailVelocity);
	    trailSprite.exists = true;
	}

	private function killOldest():Void
	{
		for(i in 0...members.length)
		{
			final sprite = members[i];
			if(sprite != null && sprite.exists)
			{
				sprite.kill();
				return;
			}
		}
	}

	public function resetTrail():Void group.kill();
}