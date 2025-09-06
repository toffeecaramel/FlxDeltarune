package backend.game;

import flixel.math.FlxPoint;
import game.chars.CharBase;

/**
 * Represents an Ally, that follows the party's main leader.
 */
class Follower extends CharBase {
    /**
     * An array of positions.
     * If this Ally is in a Party, this will be the positions of the Ally the index ahead of it.
     * Optionally, you can make the the delay based on the indes of this Ally in the party,
     * and make it follow the Part leader. They both have a similar effect.
     */
    public var targetTrail:Array<FlxPoint> = [];
    /**
     * How many positions the Ally is behind its target.
     */
    public var delay:Int = 10;
    
    override public function update(elapsed:Float):Void
    {
        // fixes a crash.
        // prevents to update pos and anim when in battle mode
        if(variant != 'normal')
            return super.update(elapsed);

        var oldX = x;
        var oldY = y;

        if (targetTrail.length > delay) {
            var pos = targetTrail.shift();
            setPosition(pos.x, pos.y);
        }

        var deltaX = x - oldX;
        var deltaY = y - oldY;
        var dist = Math.sqrt(deltaX * deltaX + deltaY * deltaY);

        if (dist > 0) {
            var dir = if (Math.abs(deltaX) > Math.abs(deltaY)) (deltaX > 0 ? "right" : "left") else (deltaY > 0 ? "down" : "up");
            animation.play("walk-" + dir);
            var isRunning = (dist > 2.5);
            animation.curAnim.frameRate = 9 * (isRunning ? 2 : 1.0);
        } else {
            if (animation.curAnim != null) {
                animation.curAnim.pause();
            }
        }

        super.update(elapsed);
    }
}