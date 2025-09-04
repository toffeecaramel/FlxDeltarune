package;

import flixel.FlxState;
import flixel.text.FlxText;

class Debugger extends FlxState
{
    override public function create():Void
    {
        super.create();
        var text = new FlxText(0, 0, FlxG.width, "Debug Mode Active!\nRedirecting to TestMod");
        text.setFormat(null, 32, flixel.util.FlxColor.LIME);
        add(text);

        // lazy to import everything.
        new flixel.util.FlxTimer().start(1, _ -> {
            currentMod = backend.mods.Mod.getModFromName('TestMod');
            var party = new backend.game.Party([
                new backend.game.Ally(0, 0, 'kris/normal', currentMod.info.modName, true),
                new backend.game.Ally(0, 0, 'ralsei/normal', currentMod.info.modName, true)
            ], 0);
            FlxG.switchState(new frontend.mods.RoomState('skyworld/room1', party));
        });
    }
}