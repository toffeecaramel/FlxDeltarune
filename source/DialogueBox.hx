package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

using StringTools;

enum Positioning {
    TOP;
    CENTER;
    BOTTOM;
}

class DialogueBox extends FlxSpriteGroup
{
    public var dbox:FlxSprite;
    public function new()
    {
        super();

        dbox = new FlxSprite();
        dbox.antialiasing = false;
        add(dbox);
        dbox.alpha = 0.0001;
    }

    public function show(box:String = 'default', speaker:String = null, expression:String = 'default', typtxt:String = 'Hello, World!', pos:Positioning = BOTTOM)
    {
        dbox.alpha = 1;
        dbox.loadGraphic(Asset.image('dialogueboxes/$box'));
        dbox.scale.set(2, 2);
        dbox.updateHitbox();
        dbox.screenCenter(X);

        switch(pos)
        {
            case TOP: dbox.y = 16;
            case CENTER: dbox.screenCenter();
            case BOTTOM: dbox.y = (FlxG.height - dbox.height) - 16;
        }
    }
}