package game.battle;

import game.battle.*;
import flixel.FlxSubState;

class BattleSubState extends FlxSubState
{
    var bg:Background;
    public function new()
    {
        super();
        
        bg = new Background();
        add(bg);
        bg.toAlpha = 1;

    }

    override public function update(delta:Float)
    {
        super.update(delta);    
    }
}