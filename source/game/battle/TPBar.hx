package game.battle;

import backend.game.DeltaText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.math.FlxMath;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

@:publicFields
class TPBar extends FlxSpriteContainer
{
    var bg:FlxSprite;
    var bgDark:FlxSprite;
    var whiteBar:FlxBar;
    var orangeBar:FlxBar;
    var redBar:FlxBar;
    var displayText:DeltaText;
    var display:FlxSprite;

    /**
     * The ammount of gathered TP, from 0 to 100.
     */
    var tp(default, set):Float = 0;

    final p = 'darkworld/battle/UI';
    /**
     * Creates a TP bar, with the percentage and all that. Remember that the `tp` variable must be updated everytime.
     * @param x X Position.
     * @param y Y Position.
     */
    function new(?x:Float = 0, ?y:Float = 0)
    {
        super(x, y);
        bg = new FlxSprite().loadGraphic(Asset.image('$p/tp-bar'));

        var bgDark = new FlxSprite().makeGraphic(Std.int(bg.width - 2), Std.int(bg.height - 2), 0xFF800000);
        add(bgDark);

        whiteBar = new FlxBar(0, 0, BOTTOM_TO_TOP, Std.int(bgDark.width), Std.int(bgDark.height));
        whiteBar.createFilledBar(FlxColor.TRANSPARENT, FlxColor.WHITE);
        
        redBar = new FlxBar(0, 0, BOTTOM_TO_TOP, Std.int(whiteBar.width), Std.int(whiteBar.height));
        redBar.createFilledBar(FlxColor.TRANSPARENT, 0xFFff0f15);
        add(redBar);
        add(whiteBar);
        
        orangeBar = new FlxBar(0, 0, BOTTOM_TO_TOP, Std.int(redBar.width), Std.int(redBar.height));
        orangeBar.createFilledBar(FlxColor.TRANSPARENT, FlxColor.WHITE); //its white at first since it changes when TP updates.
        add(orangeBar);
        add(bg);

        displayText = new DeltaText();
        displayText.text = '0';
        displayText.scale.set(0.9, 0.9);
        displayText.updateHitbox();
        add(displayText);
        displayText.x = bg.x - 31;
        displayText.y = (bg.height + displayText.height) / 2;

        display = new FlxSprite().loadGraphic(Asset.image('$p/tp-display'));
        add(display);
        display.x = displayText.x + 2;
        display.y += 29;
    }

    override function update(delta:Float)
    {
        super.update(delta);

        tp = FlxMath.bound(tp, 0, 100); //bound it just to make sure nothing crazy happens idk
        redBar.value = FlxMath.lerp(redBar.value, tp - 1, delta * 3);
        orangeBar.value = FlxMath.lerp(orangeBar.value, tp, delta * 8);
        whiteBar.value = FlxMath.lerp(whiteBar.value, tp + 1, delta * 19);

        // this was for debugging purposes hahahah
        //if(FlxG.keys.justPressed.K) tp += 10;
        //if(FlxG.keys.justPressed.M) tp = 0;
    }

    @:noCompletion public function set_tp(tpVal:Float)
    {
        this.tp = tpVal;
        if(tpVal < 101) displayText.text = '${Std.int(this.tp)}';

        displayText.visible = (tpVal < 100);
        orangeBar.color = (tpVal >= 100) ? 0xFFffd020 : 0xFFffa040;
        display.loadGraphic(Asset.image('$p/tp-display${(tpVal >= 100) ? 'MAX' : ''}'));

        return this.tp;
    }
}