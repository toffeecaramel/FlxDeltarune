package game.editors;

import haxe.Timer;
import backend.Room;

class RoomEditor extends flixel.FlxState
{
    override public function create():Void
    {
        super.create();
        // testing out room stuff!

        final myTest:Room.RoomData = {
            tileset: 'sanctuary',
            music: '2nd_sanctuary',
            resetMusic: false,
            layers: ['background', 'foreground'],
            tiles: [
                {
                    layer: 'background',
                    pos: [20, 20],
                    size: [1, 1],
                    tag: ''
                },
                {
                    layer: 'foreground',
                    pos: [35, 35],
                    size: [2, 2],
                    tag: 'uwu'
                }
            ],
            events: [
                {
                    name: 'Trigger Dialogue',
                    tag: 'mom',
                    pos: [30, 30],
                    triggerArea: [20, 1],
                    triggerOnce: true,
                    values: {
                        speaker: 'me',
                        text: 'Ok, I seriously need some help.',
                        speed: 0.04
                    }
                },
                {
                    name: 'Delete System',
                    tag: 'WAIT WHAT?!',
                    pos: [30, 30],
                    triggerArea: [-3, 1],
                    triggerOnce: false,
                    values: {
                        what: 'do you mean',
                        istrue: false,
                        okay: 0.3,
                        shut: 'up',
                        iLike: ['cookies', 'music']
                    }
                }
            ]
        };

        Room.save(myTest, 'mods/fuckingtest.room');
        
        //
        final startTime = Timer.stamp();
        var loadedRoom = Room.load('mods/fuckingtest.room');
        final loadTimeMs = (Timer.stamp() - startTime) * 1000;
        
        Logger.debug('Loaded room in ${loadTimeMs} ms');
        Logger.debug(loadedRoom);
    }
}