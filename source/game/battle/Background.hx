package game.battle;

import flixel.FlxSprite;
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
            final graphic = (i == 0) ? AssetPaths.squareloop_one__png : AssetPaths.squareloop_two__png;
            var okay = new FlxBackdrop();
            okay.loadGraphic(graphic);
            okay.alpha = toAlpha;
            add(okay);
            loops.push(okay);
        }

        for(i in 0...loops.length)
            loops[i].velocity.set((i == 0) ? -30 : 30, (i == 0) ? -30 : 15);
    }

    override function update(delta:Float):Void
    {
        super.update(delta);

        for(i in 0...loops.length)
            loops[i].alpha = FlxMath.lerp(loops[i].alpha, toAlpha, delta * 3);
    }
}