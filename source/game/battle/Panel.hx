package game.battle;

import flixel.FlxG;
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
     * An array containing all the buttons.
     */
    public var buttons:Array<FlxSprite> = [];

    /**
     * A map containing all the buttons and their strings, useful for getting a specific button.
     */
    public var buttonsMap:Map<String, FlxSprite> = [];

    /**
     * Whether the panel is open or not.
     */
    public var isOpen(default, set):Bool = false;

    //TODO: ALL THE PER CHARACTER DATA STUFF!!!!
    final tempItemList = ['fight', 'act', 'item', 'spare', 'defend'];

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
        for(i in 0...8)
        {
            var bar = new FlxSprite().makeGraphic(2, Std.int(panelBack.height));
            add(bar);
            coolBars.push(bar);
            bar.x = (i < 4) ? panelBack.x : panelBack.x + panelBack.width - bar.width;

            barsDelay.push(i * 0.1);
            barsTimer.push(0);
        }

        final spacing = 4;
        var totalWidth:Float = 0;

        for (item in tempItemList)
        {
            var btn = new FlxSprite().loadGraphic(Asset.image('darkworld/battle/UI/$item'));
            totalWidth += btn.width;
            buttons.push(btn);
            buttonsMap.set(item, btn);
        }

        // Position stuff
        totalWidth += spacing * (buttons.length - 1);
        var actualX = (panelBack.width - totalWidth) / 2;
        for (btn in buttons)
        {
            btn.x = actualX;
            btn.y = 4; //I think?
            actualX += btn.width + spacing;
            add(btn);
        }

        add(panelFront);

        changeSelection();
    }

    private var curSelected:Int = 0;
    private var coolBars:Array<FlxSprite> = [];
    private var barsDelay:Array<Float> = [];
    private var barsTimer:Array<Float> = [];

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        panelFront.y = FlxMath.lerp(panelFront.y, (isOpen) ? Std.int(panelBack.y - (panelBack.height - 2)) : panelBack.y, elapsed * 12);

        if(isOpen)
        {
            //TODO: Keybinds.
            if(FlxG.keys.justPressed.LEFT) changeSelection(-1);
            if(FlxG.keys.justPressed.RIGHT) changeSelection(1);

            // animation for the bars
            for (i in 0...coolBars.length)
            {
                final bar = coolBars[i];
                barsTimer[i] += elapsed;

                // wait for the delay timer
                if (barsTimer[i] < barsDelay[i]) continue;

                // move bar toward center
                bar.alpha -= elapsed * 1.35;
                bar.x += (i < 4 ? 1 : -1) * elapsed * 42; // left bars move right, right bars move left

                // if bar is invisible, reset
                if (bar.alpha <= 0)
                {
                    bar.alpha = 1;
                    barsTimer[i] = 0;
                    bar.x = (i < 4) ? panelBack.x : panelBack.x + panelBack.width - bar.width;
                    bar.y = panelBack.y;
                }
            }
        }
    }

    /**
     * Changes the selected button.
     * @param num The change number (e.g. if you put 2, it'll skip 2 a button and select the other one.)
     */
    private function changeSelection(num:Int = 0)
    {
        curSelected = FlxMath.wrap(curSelected + num, 0, buttons.length - 1);

        for(i in 0...buttons.length)
        {
            // change the color & graphic whether selected or not.
            final a = tempItemList[i];
            buttons[i].color = (i == curSelected) ? 0xFFffff00 : 0xFFff7f27;
            buttons[i].loadGraphic(Asset.image('darkworld/battle/UI/${(i == curSelected) ? a + '-selected' : a}'));
        }
    }

    @:noCompletion public function set_isOpen(isOpen:Bool):Bool 
    {
        this.isOpen = isOpen;

        // updates the panel graphic whether open or not
        panelFront.loadGraphic(Asset.image('darkworld/battle/UI/panels/${(isOpen) ? 'panelOpen' : 'panelClosed'}'));
        panelBack.loadGraphic(panelFront.graphic);

        return this.isOpen;
    }
}
