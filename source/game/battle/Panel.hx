package game.battle;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;

/**
 * A panel that shows a character info on the battle (such as HP, buttons to fight, act, etc.)
 */
class Panel extends FlxSpriteContainer
{
    var panelBack = new FlxSprite().loadGraphic(Asset.image('darkworld/battle/UI/panels/panelClosed')); 
    var panelFront = new FlxSprite().loadGraphic(Asset.image('darkworld/battle/UI/panels/panelClosed'));
    var icon = new FlxSprite();
    var label = new FlxSprite();
    private var mainCol:FlxColor = FlxColor.WHITE;

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

    /**
     * Whether or not should the player be able to select the options.
     */
    public var selectable(default, set):Bool = true;

    /**
     * This panel's character. If changed by here, it won't be updated unless new() is called again
     */
    public var character:String = 'kris';

    /**
     * A neat typedef containing some data, such as colors and acts.
     */
    public var data:BattleData;

    /**
     * Signal dispatched when player selectes an action.
     */
    public final onAction = new FlxTypedSignal<(action:String)->Void>();

    /**
     * Creates a panel and updates the data.
     * @param x X Position.
     * @param y Y Position.
     * @param character The character's name. Note that it must match the file name!
     */
    public function new(?x:Float = 0, ?y:Float = 0, character:String = 'kris')
    {
        super(x, y);
        this.character = character;

        data = Asset.loadJSON('data/battle/$character');
        mainCol = FlxColor.fromRGB(data.mainColor[0], data.mainColor[1], data.mainColor[2]);
        add(panelBack);
        for(i in 0...8)
        {
            var bar = new FlxSprite().makeGraphic(2, Std.int(panelBack.height), mainCol);
            add(bar);
            coolBars.push(bar);
            bar.x = (i < 4) ? panelBack.x : panelBack.x + panelBack.width - bar.width;

            var group = i % 4;
            bDelay.push((group + 1) * 0.1);
            bTimer.push(0);
        }

        final spacing = 4;
        var totalWidth:Float = 0;

        for (item in data.acts)
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

        panelFront.color = mainCol;
        add(panelFront);

        icon.loadGraphic(Asset.image('chars/$character/icons/normal'));
        add(icon);

        label.loadGraphic(Asset.image('chars/$character/icons/displayName'));
        add(label);
        
        changeSelection();
        isOpen = false;
    }

    private var curSelected:Int = 0;
    private var coolBars:Array<FlxSprite> = [];
    private var bDelay:Array<Float> = [];
    private var bTimer:Array<Float> = [];
    private var globalBTimer:Float = 0;
    private var loopDur:Float = 0.4;

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        panelFront.y = FlxMath.lerp(panelFront.y, (isOpen) ? Std.int(panelBack.y - (panelBack.height - 2)) : panelBack.y, elapsed * 16);
        icon.setPosition((panelFront.x + icon.width) - 16, panelFront.y + (panelFront.height - icon.height) / 2);
        label.setPosition(icon.x + icon.width + 6, icon.y + 6);

        if(isOpen)
        {
            //TODO: Keybinds.

            if(selectable)
            {
                if(FlxG.keys.justPressed.LEFT) changeSelection(-1);
                if(FlxG.keys.justPressed.RIGHT) changeSelection(1);
                if(FlxG.keys.justPressed.ENTER)
                {
                    FlxG.sound.play(Asset.sound('player/select.wav'));
                    onAction.dispatch(data.acts[curSelected]);
                }
            }

            globalBTimer = (globalBTimer + (elapsed / 7)) % loopDur;

            // animation for the bars
            for (i in 0...coolBars.length)
            {
                final bar = coolBars[i];
                final delay = bDelay[i];
                var t = (globalBTimer - delay + loopDur) % loopDur;

                if (t < 0.5)
                {
                    bar.alpha = 1 - (t / 0.3);
                    bar.x = (i < 4 ? panelBack.x : panelBack.x + panelBack.width - bar.width) + (i < 4 ? 1 : -1) * (t / 0.5) * panelBack.width / 2;
                }
                else
                {
                    bar.alpha = 1;
                    bar.x = (i < 4) ? panelBack.x : panelBack.x + panelBack.width - bar.width;
                }

                bar.y = panelBack.y;
            }
        }
        for (bar in coolBars) bar.active = isOpen;
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
            final a = data.acts[i];
            buttons[i].color = (i == curSelected) ? 0xFFffff00 : 0xFFff7f27;
            buttons[i].loadGraphic(Asset.image('darkworld/battle/UI/${(i == curSelected) ? a + '-selected' : a}'));
        }

        if(num != 0)
            FlxG.sound.play(Asset.sound('player/menumove.wav'));
    }

    @:noCompletion public function set_isOpen(isOpen:Bool):Bool 
    {
        this.isOpen = isOpen;

        // updates the panel graphic whether open or not
        panelFront.loadGraphic(Asset.image('darkworld/battle/UI/panels/${(isOpen) ? 'panelOpen' : 'panelClosed'}'));
        panelBack.loadGraphic(panelFront.graphic);

        panelFront.color = panelBack.color = (isOpen) ? mainCol : FlxColor.WHITE;

        return this.isOpen;
    }

    @:noCompletion public function set_selectable(selectable:Bool):Bool 
    {
        this.selectable = selectable;

        for(button in buttons)
            button.color = 0xFFff7f27;

        return this.selectable;
    }
}

typedef BattleData = {
    var mainColor:Array<Int>;
    var acts:Array<String>;
}
