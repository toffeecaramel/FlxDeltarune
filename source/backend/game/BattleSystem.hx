package source.backend.game;

import flixel.FlxBasic;
import flixel.math.FlxMath;

@:publicFields
class BattleSystem extends FlxBasic
{
    /**
     * Time since the battle started
     */
    var time:Float = 0;

    /**
     * The current turn. (wow, nice documentation)
     */
    var currentTurn:Turn = PLAYER;

    /**
     * Time left until the current turn ends. (ONLY WORKS ON OPPONENT'S TURN!)
     */
    var timeLeft:Float = 0;

    /**
     * The amount of TP the player has.
     */
    var tp:Float = 0;

    /**
     * (TODO) An array containing all the enemies in the battle.
     */
    //var enemies:Array<Enemy> = [];

    /**
     * (TODO) An array containing all the player's allies.
     */
    //var party:Array<Ally> = [];

    /**
     * An array containing all acts a party member can have.
     * @param name the act's name. E.G: "Check"
     * @param description the act's description. E.G: "Useless Analysys."
     * @param target the party member that'll have the act as a option. E.G: "kris"
     * @param partyMembers the party members that'll be used for the action, leave empty for the `target` only.
     * 
     */
    var acts:Array<{name:String, description:String, target:String, ?partyMembers:Array<String>}> = [];
    
    function new()
    {
        super();
    }

    override function update(delta:Float)
    {
        super.update(delta);
        time += delta;
        if(currentTurn == OPPONENT) timeLeft -= delta;

        tp = FlxMath.bound(tp, 0, 100);
        
    }
}

enum Turn {
    OPPONENT;
    PLAYER;
}