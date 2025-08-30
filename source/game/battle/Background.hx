package game.battle;

import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;

class Background extends FlxSpriteGroup
{
    public var toAlpha:Float = 0.0001;

    private var loops:Array<FlxBackdrop> = [];
    public function new()
    {
        super();

        for(i in 0...2)
        {
            final graphic = Asset.image('battle/bg/squareloop_${(i == 0) ? 'one' : 'two'}');
            var okay = new FlxBackdrop();
            okay.loadGraphic(graphic);
            okay.alpha = toAlpha;
            add(okay);
            loops.push(okay);
        }

        for(i in 0...loops.length)
            loops[i].velocity.set((i == 0) ? -60 : 40, (i == 0) ? -60 : 35);
    }

    override function update(delta:Float):Void
    {
        super.update(delta);

        for(i in 0...loops.length)
            loops[i].alpha = FlxMath.lerp(loops[i].alpha, toAlpha, delta * 3);
    }
}