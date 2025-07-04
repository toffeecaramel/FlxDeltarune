package;

import flixel.util.FlxTimer;

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

    trace(battle.battleSystem.acts);
}

function postCreate()
{
    battle.preStart();

    new FlxTimer().start(2, (_)->battle.start());
}