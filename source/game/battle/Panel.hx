package game.battle;

import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.math.FlxMath;

/**
 * A panel that shows a character info on the battle (such as HP, buttons to fight, act, etc.)
 */
class Panel extends FlxSpriteContainer
{
    var panelBack = new FlxSprite().loadGraphic(Asset.image('darkworld/battle/UI/panels/panelClosed')); 
    var panelFront = new FlxSprite().loadGraphic(Asset.image('darkworld/battle/UI/panels/panelClosed'));

    /**
     * Whether the panel is open or not.
     */
    public var isOpen(default, set):Bool = false;

    /**
     * Creates a panel and updates the data.
     * @param x X Position.
     * @param y Y Position.
     * @param character The character's name. Note that it must match the file name!
     */
    public function new(?x:Float = 0, ?y:Float = 0, character:String = 'kris')
    {
        super(x, y);

        add(panelBack);
        add(panelFront);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        panelFront.y = FlxMath.lerp(panelFront.y, (isOpen) ? Std.int(panelBack.y - (panelBack.height - 2)) : panelBack.y, elapsed * 12);
    }

    @:noCompletion public function set_isOpen(isOpen:Bool):Bool 
    {
        this.isOpen = isOpen;

        panelFront.loadGraphic(Asset.image('darkworld/battle/UI/panels/${(isOpen) ? 'panelOpen' : 'panelClosed'}'));
        panelBack.loadGraphic(panelFront.graphic);

        return this.isOpen;
    }
}