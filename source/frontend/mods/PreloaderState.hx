package frontend.mods;

import backend.game.Ally;
import backend.game.Party;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;

using StringTools;
class PreloaderState extends FlxState
{
    override public function create()
    {
        super.create();
        //Logger.info(Asset.readDirectory('mods/${currentMod.info.modName}/Tilemaps'));
        final info = currentMod.info.modName;

        //TODO: Finish the preloader;
        for (tile in Asset.readDirectory(Asset.getPath('mods/$info/Tilemaps', null)))
            if(tile.endsWith('.json'))
                Tilemap.addAtlas(tile.split('.')[0], 'Tilemaps');

        FlxG.switchState(()->new RoomState(currentMod.info.startingRoom, currentMod.getGlobal('curParty')));
        Logger.debug(currentMod.getGlobal('curParty'));
    }
}