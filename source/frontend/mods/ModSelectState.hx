package frontend.mods;

import backend.game.Ally;
import backend.game.Party;
import rulescript.RuleScript;
import backend.game.DeltaTypedText;
import flixel.util.FlxTimer;
import backend.mods.Mod;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class ModSelectState extends FlxState {
	public var modList = Mod.modList;
	public var mods(get, null):Array<Mod> = [];
	public var initialized:Bool = false;
	public var noModsText:DeltaTypedText;
	public var modCams:Array<FlxCamera> = [];
	public var modScripts:Array<RuleScript> = [];

	var selected:Int = 0;
	var cameraLerpSpeed:Float = 0.1;
	var switchCooldown:Float = 0;
	var modChosen:Bool = false;

	override public function create():Void {
		super.create();
        // Use FlxTween/Ease so that it gets compiled with the exe and mods can use it
        var e = new FlxObject(0, 0, 0, 0);
        FlxTween.tween(e, {x: 1}, 1, {ease: FlxEase.linear});
        FlxTween.cancelTweensOf(e);
        e.destroy();
        e = null;

		if (mods.length > 0) {
			initialize();
		} else {
			noModsText = new DeltaTypedText(0, 0, {
				text: 'No mods found. Install a mod, and unpack the mod into your mods folder!',
				speed: 0.09
			});
			add(noModsText);
		}
	}

	function get_mods():Array<Mod> {
		var mods = [];
		for (i in 0...modList.length) {
			var mod = Mod.getModFromName(modList[i]);
			if (mod != null)
				mods.push(mod);
		}
		return mods;
	}

	function initialize():Void {
		loadMods();
		prepCams();
		initialized = true;
		updateHoverStates();
	}

	function prepCams() {
		for (i in 0...modCams.length)
			modCams[i].x = i * FlxG.width;
	}

	function loadMods() {
		for (modID in 0...mods.length) {
			var mod = mods[modID];
			var script = Asset.script('mods/${mod.info.modName}/ModMenu/modMenu', mod.info.bytecodeInterp);
            setScriptVar(script, 'modSelect', this);
			callScriptMethod(script, 'initialize', true);

			var camera = getScriptVar(script, 'camera');
            if (camera != null){
			    modCams.push(camera);
			    FlxG.cameras.add(camera, false);
			    modScripts[modID] = script;
            }else{
                Logger.error('A null camera from "${mod.info.modName}" kept the mod from loading. Please check its ModMenu/ModMenu.mhx file.');
            }
		}
	}

	function updateHoverStates():Void {
		for (i in 0...modScripts.length) {
			var script = modScripts[i];
			if (i == selected)
				callScriptMethod(script, 'startHover', true);
			else
				callScriptMethod(script, 'stopHover', true);
		}
	}

	function modSelected() {
		Logger.info('Mod chosen: ' + mods[selected].info.modName);
        currentMod = mods[selected];
        for (modID in 0...mods.length)
        {
            var mod = mods[modID];
            var script = modScripts[modID];
            var camera = modCams[modID];
            callScriptMethod(script, 'destroy', true);
            FlxG.cameras.remove(camera, false); // Mod should've already destroyed their camera
            camera = null;
        }
        var chosenMod = mods[selected];
        var party:Party;
        var partyMembers = [];
        var leaderIdx = 0;
        for (char in 0...chosenMod.info.startingParty.length){
            if (char < 1)
                leaderIdx = char;
            partyMembers.push(new Ally(0, 0, '${chosenMod.info.startingParty[char]}/normal', chosenMod.info.modName, true));
        }
        party = new Party(partyMembers, leaderIdx);
        FlxG.switchState(()->new RoomState(chosenMod.info.startingRoom, party));
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (!initialized) {
			noModsText.textDisplay.screenCenter();
			return;
		}

		if (modChosen) return;

		if (switchCooldown > 0)
			switchCooldown -= elapsed;

		if (FlxG.keys.justPressed.RIGHT && selected < mods.length - 1 && switchCooldown <= 0) {
			selected++;
			switchCooldown = 0.15;
			updateHoverStates();
		}

		if (FlxG.keys.justPressed.LEFT && selected > 0 && switchCooldown <= 0) {
			selected--;
			switchCooldown = 0.05;
			updateHoverStates();
		}

		for (i in 0...modCams.length) {
            var cam = modCams[i];
            var targetX = (i - selected) * FlxG.width;
            cam.x = FlxMath.lerp(cam.x, targetX, cameraLerpSpeed);
        }


		if (FlxG.keys.justPressed.ENTER) {
			modChosen = true;
            callScriptMethod(modScripts[selected], 'onChosen');

            new FlxTimer().start(3, (_)->{
                modSelected();
            });
		}
	}
}
