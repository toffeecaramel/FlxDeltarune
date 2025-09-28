package game.editors;

import flixel.FlxG;
import flixel.FlxCamera;
import haxe.Timer;
import game.ui.*;

class RoomEditor extends flixel.FlxState
{
    public var gameCAM:FlxCamera;
    public var hudCAM:FlxCamera = new FlxCamera();

    var leftPanel:UIBox;
    override public function create():Void
    {
        super.create();
        //DeltaUtils.changeResolution(1280, 720);

        gameCAM = FlxG.camera;
        FlxG.cameras.add(hudCAM, false);
        hudCAM.bgColor = 0x00000000;

        leftPanel = new UIBox(0, 0, 'regular');
        leftPanel.resize(FlxG.width / 3, FlxG.height);
        add(leftPanel);
    }

    override public function update(delta:Float)
    {
        super.update(delta);
    }
}