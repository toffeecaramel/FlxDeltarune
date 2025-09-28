package backend.game;

/**
 * A Party represents all the 'Allies' in a single group.
 */
class Party {
    /**
     * The members in this Party.
     */
    public var members:Array<Ally> = [];
    /**
     * The leader of this Party.
     */
    public var leader(get, set):Ally;
    /**
     * The index of the leader of this Party.
     */
    public var leaderIndex:Int = -1;
    
    /**
     * Creates a party.
     * @param members The members in this Party.
     * @param leaderIndex The array index of the leader. E.G: [susie, kris, ralsei] The leader is kris, so leaderIndex = 1
     */
    public function new(members:Array<Ally>, leaderIndex:Int) {
        this.leaderIndex = leaderIndex;
        this.members = members;
    }

    function get_leader():Null<Ally> return members[leaderIndex];

    function set_leader(ally:Ally):Ally {
        members.push(ally);
        leaderIndex = members.indexOf(ally);
        return ally;
    }

    public function toString():String
        return 'Party members: $members, Leader: $leader (ID: $leaderIndex)';
}