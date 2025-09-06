package game.chars;

import haxe.io.Path;

//TODO: doccument this.a.

@:publicFields
class CharBase extends FlxSprite
{
    var charPath(default, set):String = 'kris';
    var mainName(default, set):String = 'kris';
    var variant(default, set):String = 'normal';
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

    function updateGraphics()
    {
        var path = 'mods/$modName/Characters/$mainName/$variant/$mainName-$variant';
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
    }

    @:noCompletion function set_variant(variant:String):String
    {
        this.variant = variant;
        updateGraphics();

        return this.variant;
    }

    @:noCompletion function set_mainName(name:String):String
    {
        this.mainName = name;
        updateGraphics();

        return this.mainName;
    }

    @:noCompletion function set_charPath(char:String):String
    {
        this.charPath = char;
        mainName = char.split('/')[0];
        variant = char.split('/')[1];
        updateGraphics();

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