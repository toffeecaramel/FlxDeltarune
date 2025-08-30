package backend.game.interfaces;

/**
 * An interface for handling effects on sprites.
 */
interface IEffect {
    /**
     * The sprite target.
     */
    public var target:FlxSprite;

    /**
     * When stopping the effect.
     */
    public function stop():Void;

    /**
     * When restarting the effect.
     */
    public function restart():Void;

    /**
     * When updating the effect.
     * @param elapsed 
     */
    public function update(elapsed:Float):Void;
}