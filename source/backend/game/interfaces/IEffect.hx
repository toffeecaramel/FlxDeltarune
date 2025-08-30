package backend.game.interfaces;

interface IEffect {
    public var target:FlxSprite;
    public function stop():Void;
    public function restart():Void;
    public function update(elapsed:Float):Void;
}