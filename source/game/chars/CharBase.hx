package game.chars;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

@:publicFields
class CharBase extends FlxSprite
{
    var charPath(default, set):String = 'kris';

    function new(?x:Float = 0, ?y:Float = 0, charPath:String = 'kris')
    {
        super(x, y);
        this.charPath = charPath;
    }

    @:noCompletion function set_charPath(char:String):String
    {
        this.charPath = char;

        final data = Asset.loadJSON('assets/images/chars/$char');
        this.frames = Asset.getAtlas('chars/$char');

        for (i in 0...data.animations.length)
        {
            final anim = data.animations[i];
            (anim.indices != null)
            ? this.animation.addByIndices(anim.name, anim.prefix, anim.indices, '', anim.fps ?? 24, anim.looped ?? false)
            : this.animation.addByPrefix(anim.name, anim.prefix, anim.fps ?? 24, anim.looped ?? false);
        }

        return this.charPath;
    }
}

typedef CharAnim = {
    var name:String;
    var prefix:String;
    var indices:Array<Int>;
    var fps:Int;
}