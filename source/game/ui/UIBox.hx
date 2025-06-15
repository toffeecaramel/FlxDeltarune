package game.ui;

import flixel.addons.ui.FlxUI9SliceSprite;
import openfl.geom.Rectangle;

class UIBox extends FlxUI9SliceSprite
{
    public var w:Float = 0;
    public var h:Float = 0;
    public function new(?x:Float = 0, ?y:Float = 0, box:String = 'battle')
    {
        final frame = new Rectangle(0, 0, 150, 150);
        super(x, y, Asset.image('ui/boxes/$box'), frame, [5, 5, 145, 145]);
    }
}