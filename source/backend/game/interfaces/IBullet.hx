package backend.game.interfaces;

interface IBullet 
{
    /**
     * Whether or not should the bullet hurt the player.
     */
    public var shouldHurt:Bool;

    /**
     * Whether or not should the player be able to graze when near the bullet.
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