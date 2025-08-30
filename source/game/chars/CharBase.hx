package game.chars;

import haxe.io.Path;

//TODO: doccument this.a.

@:publicFields
class CharBase extends FlxSprite
{
    var charPath(default, set):String = 'kris';
    var modName:String = '';
    var adjustedHitbox(default, set):Bool = false;

    function new(?x:Float = 0, ?y:Float = 0, charPath:String = 'kris', modName:String = '', adjustedHitbox:Bool = false)
    {
        super(x, y);
        if (modName == '' && currentMod != null)
            modName = currentMod.info.modName;
        this.modName = modName;
        this.charPath = charPath;
        this.adjustedHitbox = adjustedHitbox;
    }

    @:noCompletion function set_adjustedHitbox(adjusted:Bool):Bool
    {
        this.adjustedHitbox = adjusted;
        if (adjusted)
        {
            width = frameWidth * scale.x;   // hitbox width same as graphic width
            height = 5;                    // hitbox height shrunk
            offset.y = (frameHeight * scale.y) - height; // offset graphic down so bottom aligns
        }
        return this.adjustedHitbox;
    }

    @:noCompletion function set_charPath(char:String):String
    {
        this.charPath = char;
        var charName = char.split('/')[0];
        var charVariant = char.split('/')[1];
        var path = 'mods/$modName/Characters/${Path.normalize(char)}/$charName-$charVariant';
        final data:CharData = Asset.loadJSON('$path-data');
        this.frames = Asset.getOutSourcedAtlas(path);

        for (i in 0...data.animations.length)
        {
            final anim:CharAnim = data.animations[i];
            (anim.indices != null)
            ? this.animation.addByIndices(anim.name, anim.prefix, anim.indices, '', anim?.fps ?? 24, anim?.looped ?? false)
            : this.animation.addByPrefix(anim.name, anim.prefix, anim?.fps ?? 24, anim?.looped ?? false);
        }

        scale.set(data?.scale[0] ?? 1, data?.scale[1] ?? 1);

        antialiasing = data?.antialiasing ?? false;

        updateHitbox();

        return this.charPath;
    }
}

typedef CharData = {
    var scale:Array<Float>;
    var antialiasing:Bool;
    var animations:Array<CharAnim>;
}

typedef CharAnim = {
    var name:String;
    var prefix:String;
    var indices:Array<Int>;
    var fps:Int;
    var looped:Bool;
}