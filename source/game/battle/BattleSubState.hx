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
import flixel.math.FlxPoint;

enum BattlePosition
{
    TOP_LEFT;
    MID_LEFT;
    BOTTOM_LEFT;
    TOP_MID;
    CENTER;
    BOTTOM_MID;
    TOP_RIGHT;
    MID_RIGHT;
    BOTTOM_RIGHT;
}

class BattleSubState extends FlxSubState
{
    var bg:Background;

    public var battleSystem:BattleSystem;
    public var bScript:RuleScript;
    public var tp(default, set):Float = 0;
    public var battleTheme = 'rudebuster.ogg';
    public var encounter:String;
    public var charPositions:Map<CharBase, FlxPoint> = []; 
    public var positions:Map<BattlePosition, FlxPoint> = [];

    public var battleGroup:FlxTypedGroup<CharBase>;
    public var oldGroup:FlxTypedGroup<FlxObject>;

    public function new(encounter:String, party:Party, camera:FlxCamera, oldGroup:FlxTypedGroup<FlxObject>)
    {
        super();
        this.encounter = encounter;
        this.camera = camera;
        this.oldGroup = oldGroup;

        battleSystem = new BattleSystem(party);
        add(battleSystem);

        bScript = Asset.script('mods/${currentMod.info.modName}/Encounters/$encounter', currentMod.info.bytecodeInterp);
        setScriptVar(bScript, 'battle', this);
        
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
            } else
                Logger.warn('Null party member at index $memberID');
        }

        addUI();
        setCoolPositions();
        callScriptMethod(bScript, 'setup', true);

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

    public function setAlliesDefaultPos()
    {
        Logger.info('Setting default positions for allies.');
        var allyPositions = [TOP_LEFT, MID_LEFT, BOTTOM_LEFT];
        for(i in 0...battleSystem.party.members.length)
        {
            var ally = battleSystem.party.members[i];
            final posEnum = (i < allyPositions.length) ? allyPositions[i] : null;
            if (posEnum == null) {
                Logger.warn('No default position for ally at index $i, skipping...');
                continue;
            }
            var pos = positions.get(posEnum);
            if (pos == null){
                Logger.warn('No position found for enum $posEnum, skipping...');
                continue;
            }
            charPositions.set(ally, pos.clone());
        }
    }

    public function preStart()
    {
        FlxG.sound.play(Asset.sound('sounds/battle/weaponpull.wav'));
        for(char in battleGroup.members)
        {
            if(char is CharBase)
            {
                final p = charPositions.get(char);
                if (p == null){
                    Logger.warn('No position found for char ${char.mainName}, skipping...');
                    continue;
                }
                FlxTween.tween(char, {x: p.x, y: p.y}, 0.4);
            }
        }
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
        Logger.debug(this.tp);
        return this.tp;
    }

    // ugly functions for the last, amirite :3
    function setCoolPositions()
    {
        final offset = 76;
        final leftX = offset;
        final midX = FlxG.width / 2 - offset;
        final rightX = FlxG.width - offset;

        final battleTop = -32;
        final battleHeight = FlxG.height - box.height + 80 - battleTop;

        final topY = battleTop + (battleHeight * (1 / 6));
        final midY = battleTop + (battleHeight * (3 / 6));
        final bottomY = battleTop + (battleHeight * (5 / 6)) - offset;

        positions.set(TOP_LEFT, FlxPoint.get(leftX, topY));
        positions.set(MID_LEFT, FlxPoint.get(leftX, midY));
        positions.set(BOTTOM_LEFT, FlxPoint.get(leftX, bottomY));
        positions.set(TOP_MID, FlxPoint.get(midX, topY));
        positions.set(CENTER, FlxPoint.get(midX, midY));
        positions.set(BOTTOM_MID, FlxPoint.get(midX, bottomY));
        positions.set(TOP_RIGHT, FlxPoint.get(rightX, topY));
        positions.set(MID_RIGHT, FlxPoint.get(rightX, midY));
        positions.set(BOTTOM_RIGHT, FlxPoint.get(rightX, bottomY));
    }
}