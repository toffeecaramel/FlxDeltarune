package backend.game.interfaces;

/**
 * An interface for a bullet type.
 */
interface IBullet 
{
    /**
     * The name for this bullet.
     */
     
    public var name:String;
    /**
     * Whether or not should the bullet hurt the player.
     */
    public var shouldHurt:Bool;

    /**
     * Whether or not should the player be able to graze (gain TP) when near the bullet.
     */
    public var shouldGraze:Bool;

    /**
     * The amount of damage the bullet will deal.
     */
    public var damage:Int;

    /**
     * Called when the bullet causes damage.
     */
    public function onDamage():Void;
}