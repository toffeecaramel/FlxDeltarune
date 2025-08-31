package game.battle;

import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;

/**
 * Background used on the battle scene.
 */
class Background extends FlxSpriteGroup
{
    public var toAlpha:Float = 0.0001;
    private var loops:Array<FlxBackdrop> = [];
    public function new()
    {
        super();

        var awa = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        awa.alpha = 0.0001;
        add(awa);

        for(i in 0...2)
        {
            final graphic = Asset.image('battle/bg/squareloop_${(i == 0) ? 'one' : 'two'}');
            var okay = new FlxBackdrop();
            okay.loadGraphic(graphic);
            okay.alpha = 0.0001;
            add(okay);
            loops.push(okay);
        }

        for(i in 0...loops.length)
            loops[i].velocity.set((i == 0) ? -60 : 40, (i == 0) ? -60 : 35);
    }

    override function update(delta:Float):Void
    {
        super.update(delta);

        for(i in 0...this.members.length)
            this.members[i].alpha = FlxMath.lerp(this.members[i].alpha, toAlpha, delta * 3);
    }
}