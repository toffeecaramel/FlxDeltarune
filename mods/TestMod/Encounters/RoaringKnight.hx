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
    battle.setAlliesDefaultPos(); 
}

function postCreate()
{
    battle.preStart();
    var party = battle.battleSystem.party;
    for(p in party.members)
        p.animation.play((p.mainName != 'ralsei') ? 'attack' : 'fight-engage', true);
    
    new FlxTimer().start(1, (_)->battle.start());
}   