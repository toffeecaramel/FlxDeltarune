package game.ui;

import flixel.addons.ui.FlxUI9SliceSprite;
import openfl.geom.Rectangle;

class UIBox extends FlxUI9SliceSprite
{
    public function new(?x:Float = 0, ?y:Float = 0, box:String = 'battle')
    {
        final rect = new Rectangle(0, 0, 150, 150);
        super(x, y, Asset.image('ui/boxes/$box'), rect);
    }
}