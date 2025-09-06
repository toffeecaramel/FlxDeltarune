package game.battle;

import backend.game.BattleSystem;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.battle.*;
import game.chars.*;
import backend.game.*;
import hscript.Expr.ModuleDecl;
import hscript.Printer;
import rulescript.*;
import rulescript.parsers.*;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera;

class BattleSubState extends FlxSubState
{
    var bg:Background;
    public var battleSystem:BattleSystem;
    public var bScript:RuleScript;
    public var tp(default, set):Float = 0;
    public var battleTheme = 'rudebuster.ogg';
    public var encounter:String;
    var battleGroup:FlxTypedGroup<CharBase>;
    var oldGroup:FlxTypedGroup<FlxObject>;

    public function new(encounter:String, party:Party, camera:FlxCamera, zSortableGroup:FlxTypedGroup<FlxObject>)
    {
        super();
        this.encounter = encounter;
        this.camera = camera;
        this.oldGroup = zSortableGroup;

        battleSystem = new BattleSystem(party);
        add(battleSystem);

        bScript = Asset.script('mods/${currentMod.info.modName}/Encounters/$encounter', currentMod.info.bytecodeInterp);
        setScriptVar(bScript, 'battle', this);
        
        callScriptMethod(bScript, 'setup', true);
        
        bg = new Background();
        add(bg);
        bg.toAlpha = 1;

        battleGroup = new FlxTypedGroup<CharBase>();
        add(battleGroup);

        for (memberID in 0...party.members.length)
        {
            var member = party.members[memberID];
            if (member != null) {
                member.setPosition(member.getScreenPosition().x, member.getScreenPosition().y);
                member.scrollFactor.set();
                member.variant = 'battle'; // Todo :3
                battleGroup.add(member);
            } else {
                trace('Warning: Null party member at index $memberID');
            }
        }

        addUI();

        callScriptMethod(bScript, 'postCreate', true);
        FlxG.sound.play(Asset.sound('sounds/battle/weaponpull.wav'));
    }

    var upperBox:FlxSprite;
    var box:FlxSprite;
    var testPanel:Panel;
    var tpBar:TPBar;
    var attBar:AttackBar;

    function addUI()
    {
        final p = 'battle/UI';

        upperBox = new FlxSprite().loadGraphic(Asset.image('$p/panels/panelClosed'));
        upperBox.scale.x = 8;
        upperBox.screenCenter(X);
        add(upperBox);
        
        testPanel = new Panel(0, 0, 'kris');
        add(testPanel);
        testPanel.screenCenter(X);
        testPanel.origin.y = testPanel.height;

        testPanel.onAction.add((action) -> {
            switch (action)
            {
                case 'fight':
                    attBar.visible = attBar.active = true;
                    attBar.setPosition(box.x, box.y);
                    testPanel.selectable = false;
                    new FlxTimer().start(0.06, (_) -> attBar.canPress = true);
                case 'defend':
                    tp += 16;
            }
        });
        
        box = new FlxSprite().loadGraphic(Asset.image('$p/box'));
        add(box);

        attBar = new AttackBar(box.x, box.y);
        add(attBar);
        attBar.active = attBar.visible = false;
        attBar.onPress.add((damage) -> {
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

        FlxTween.tween(box, {y: FlxG.height - box.height}, 0.6, {ease: FlxEase.expoOut});
    }

    override public function update(delta:Float)
    {
        super.update(delta);    
        if (FlxG.keys.justPressed.P) testPanel.isOpen = !testPanel.isOpen;

        upperBox.y = box.y - upperBox.height + 2;
        testPanel.y = box.y - 36;
    }

    override public function close()
    {
        for (member in battleGroup.members) {
            if (member != null) {
                //member.variant = 'normal';
                oldGroup.add(member);
            }
        }
        battleGroup.clear();
        super.close();
    }

    @:noCompletion public function set_tp(tp:Float):Float
    {
        this.tp = tpBar.tp = battleSystem.tp = FlxMath.bound(tp, 0, 100);
        trace(this.tp);
        return this.tp;
    }
}