package;

import backend.effects.*;
import backend.game.DeltaText;
import backend.game.DeltaTypedText;
import backend.utils.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.FlxTrail;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.battle.*;
import game.chars.*;
import game.ui.UIBox;
import zero.flixel.ui.RichText;

class PlayState extends FlxState
{
	var lilGroup:FlxGroup;
	var player:FlxSprite;
    var richText:RichText;
    override public function create():Void
	{
        super.create();

        richText = new RichText({
            graphic_options: {
                graphic: Asset.image('ui/fonts/determination'),
                frame_width: 16,
                frame_height: 33,
                charset: 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz' +
                '0123456789!@#$%&*()-_+=[]{}^~.,<>:;?/|\\"\'`'
            },
            position: FlxPoint.get(100, 200),
            text_field_options: {
                field_width: 400,
                field_height: 300,
                line_spacing: 2,
                letter_spacing: 1
            },
            animations: {
                /*build_in: {
                    effect: FADE_IN,
                    ease: LINEAR,
                    speed: 0.1,
                    amount: 10
                },
                build_out: {
                    effect: FADE_OUT,
                    ease: LINEAR,
                    speed: 0.1,
                    amount: 10
                },*/
                type_effect: {
                    effect: TYPEWRITER,
                    rate: 0.05
                },
                wiggle_options: {
                    amount: 2,
                    speed: 0.25,
                    frequency: 128
                },
                shake_options: {
                    amount: 3,
                    speed: 0.05
                }
            },
            start_delay: 0.5,
            separators_pause: true
        });

        
        add(richText);
        richText.queue("Hello, <w=16,0.5,264>wiggling</w> world!\nThis is <s=5,0.02>shaking</s> and <c#00FF00>green</c>."+
            "\nFast <t=3>s<t=1.5>l<t=1>o<t=0.5>w <t=0.3>text\n<t=0.02> WAIT! <t=3>\n<t=0.03>thanks :3" +
            '\n Test. of. those, yeah? Oh luv! I know!');
        richText.invoke();
    }

    override public function update(elapsed:Float):Void
	{
        super.update(elapsed);
    }
}