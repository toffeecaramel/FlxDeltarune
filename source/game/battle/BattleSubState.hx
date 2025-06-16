package game.battle;

import flixel.FlxSubState;
import game.battle.*;
import game.chars.*;

class BattleSubState extends FlxSubState
{
    var bg:Background;

    var kris:CharBase;
    public function new()
    {
        super();
        
        bg = new Background();
        add(bg);
        bg.toAlpha = 1;

        //TODO: somehow get the player position on screen, and then move it to the side
        kris = new CharBase(300, 300, "kris/kris-battle");
        add(kris);
        kris.animation.play('idle-loop');
    }

    override public function update(delta:Float)
    {
        super.update(delta);    
    }
}