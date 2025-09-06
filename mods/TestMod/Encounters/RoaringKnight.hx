package;

import flixel.util.FlxTimer;
import DebugConsole.Logger;

function setup()
{
    battle.battleSystem.acts = [
        {
            name: 'Check', 
            description: 'Useless Analysys.',
            target: 'kris'
        },
        {
            name: 'Beg', 
            description: 'Beg for mercy.',
            target: 'kris',
            partyMembers: ['susie', 'ralsei']
        }
    ];

    Logger.debug(battle.battleSystem.acts);
}

function postCreate()
{
    battle.preStart();

    new FlxTimer().start(2, (_)->battle.start());
}   