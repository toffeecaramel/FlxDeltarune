package backend.game;

import flixel.math.FlxPoint;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;

class DeltaText extends FlxBitmapText
{
    public function new()
    {
        final fontLetters = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz' +
        '0123456789!@#$%&*()-_+=[]{}^~.,<>:;?/|\\"\'`';
        final cSize = FlxPoint.get(16, 33);
        super(FlxBitmapFont.fromMonospace(Asset.image('ui/fonts/determination'), 
        fontLetters, cSize));
    }
}