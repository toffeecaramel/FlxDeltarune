package game.battle;

// TODO: make this work with the mods system
import backend.game.BattleSystem;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.battle.*;
import game.chars.*;
import hscript.Expr.ModuleDecl;
import hscript.Printer;
import rulescript.*;
import rulescript.parsers.*;

class BattleSubState extends FlxSubState
{
    // Heads up! 
    // This battle substate is currently up on testing.
    // It'll be properly changed to handle battles more efficiently later!
    // So, basically, its currently on test phase, got it? :)
    var bg:Background;
    public var battleSystem:BattleSystem = new BattleSystem(null);
    public var bScript:RuleScript;

    public var tp(default, set):Float = 0;

    public var battleTheme = 'rudebuster.ogg';
    public function new()
    {
        super();
        add(battleSystem);

        bScript = new RuleScript(new HxParser());
        bScript.scriptName = 'BATTLE SCRIPT';
        bScript.tryExecute(Asset.getText('data/battles/TestBattle.hx'));
        bScript.variables.set('battle', this);
        
        (bScript.variables.exists('setup')) ? bScript.variables.get('setup')() : throw 'The battle script does not have a setup() function.';

        var awa = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(awa);
        
        bg = new Background();
        add(bg);
        bg.toAlpha = 1;
        
        addUI();

        (bScript.variables.exists('postCreate')) ? bScript.variables.get('postCreate')() : null;
        FlxG.sound.play(Asset.sound('sounds/battle/weaponpull.wav'));
    }

    var upperBox:FlxSprite;
    var box:FlxSprite;
    var testPanel:Panel;

    var tpBar:TPBar;
    var attBar:AttackBar;
    function addUI()
    {
        final p = 'battle/UI'; //just to shorten some code lol

        upperBox = new FlxSprite().loadGraphic(Asset.image('$p/panels/panelClosed')); //yea
        upperBox.scale.x = 8; // lol
        upperBox.screenCenter(X);
        add(upperBox);
        
        testPanel = new Panel(0, 0, 'kris');
        add(testPanel);
        testPanel.screenCenter(X);
        testPanel.origin.y = testPanel.height;

        testPanel.onAction.add((action)->{
            switch(action)
            {
                case 'fight': attBar.visible = attBar.active = true;
                    attBar.setPosition(box.x, box.y);
                    testPanel.selectable = false;
                    new FlxTimer().start(0.06, (_)-> attBar.canPress = true);
                case 'defend':
                    tp += 16;
            }
        });
        
        box = new FlxSprite().loadGraphic(Asset.image('$p/box'));
        add(box);

        attBar = new AttackBar(box.x, box.y);
        add(attBar);
        attBar.active = attBar.visible = false;
        attBar.onPress.add((damage)->
        {
            FlxG.sound.play(Asset.sound('sounds/battle/attack.wav'));
        });

        tpBar = new TPBar(38, 48);
        add(tpBar);
        
        box.y = upperBox.y = FlxG.height + (box.height * 2);
    }

    public function preStart()
    {
        FlxG.sound.play(Asset.sound('sounds/battle/weaponpull.wav'));
    }

    public function start()
    {
        FlxG.sound.playMusic(Asset.sound('music/$battleTheme'));

        FlxTween.tween(box, {y:FlxG.height - box.height}, 0.6, {ease: FlxEase.expoOut});
    }

    override public function update(delta:Float)
    {
        super.update(delta);    
        if(FlxG.keys.justPressed.P) testPanel.isOpen = !testPanel.isOpen;

        upperBox.y = box.y - upperBox.height + 2;
        testPanel.y = box.y - 36;
    }

    @:noCompletion public function set_tp(tp:Float):Float
    {
        // aghhh too many tp in one line!!!!
        this.tp = tpBar.tp = battleSystem.tp = tp;
        this.tp = FlxMath.bound(this.tp, 0, 100);
        trace(this.tp);
        return this.tp;
    }
}