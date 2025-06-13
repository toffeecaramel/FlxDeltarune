package game.chars;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

typedef CharData = {
    var name:String;
    var description:String;
    var mainColor:Array<Int>;
    var regularSpriteName:String;
    var ?battleSpriteName:String;
}

class CharBase extends FlxSprite
{
    public function new(x:Float, y:Float, darkWorld:Bool = true)
    {
        super(x, y);
    }
}