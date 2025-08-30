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
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (targetTrail.length > delay) {
            var targetPos = targetTrail.shift();
            setPosition(targetPos.x, targetPos.y);
        }
    }
}