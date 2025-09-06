package;

import flixel.FlxG;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;

class DebugConsole extends Sprite
{
    private var logText:TextField;
    private var scrollTrack:Sprite;
    private var scrollThumb:Sprite;
    private var consoleWidth:Float;
    private var consoleHeight:Float;
    private var thumbHeight:Float = 50;
    private var dragging:Bool = false;
    private var originalTrace:Dynamic->?haxe.PosInfos->Void;

    public function new(width:Float = 800, height:Float = 400)
    {
        super();

        consoleWidth = width;
        consoleHeight = height;

        // Background
        graphics.beginFill(0x000000, 0.8);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();

        // Log text field
        logText = new TextField();
        var format = new TextFormat("_sans", 12, 0xFFFFFF);
        logText.defaultTextFormat = format;
        logText.width = width - 20;
        logText.height = height;
        logText.multiline = true;
        logText.wordWrap = true;
        logText.selectable = true;
        logText.background = false;
        logText.border = false;
        addChild(logText);

        // Scroll track
        scrollTrack = new Sprite();
        scrollTrack.graphics.beginFill(0x333333);
        scrollTrack.graphics.drawRect(0, 0, 20, height);
        scrollTrack.graphics.endFill();
        scrollTrack.x = width - 20;
        addChild(scrollTrack);

        // Scroll thumb
        scrollThumb = new Sprite();
        updateThumbGraphics(50); // Initial
        scrollThumb.x = width - 20;
        scrollThumb.y = 0;
        scrollThumb.buttonMode = true;
        addChild(scrollThumb);

        // Events
        scrollThumb.addEventListener(MouseEvent.MOUSE_DOWN, onThumbDown);
        logText.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);

        // Override trace (save original)
        originalTrace = haxe.Log.trace;
        haxe.Log.trace = customTrace;
    }

    private function onAddedToStage(_):Void {
        stage.addEventListener(MouseEvent.MOUSE_UP, onThumbUp);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onThumbMove);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onRemovedFromStage(_):Void {
        stage.removeEventListener(MouseEvent.MOUSE_UP, onThumbUp);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, onThumbMove);
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function customTrace(v:Dynamic, ?infos:haxe.PosInfos):Void {
        // Call original trace
        originalTrace(v, infos);

        // Add to console if visible
        if (this.visible) {
            var line = Std.string(v);
            if (infos != null) {
                line += ' ${infos.fileName}:${infos.lineNumber}';
            }
            addLine(line);
        }
    }

    public function addLine(text:String):Void {
        var wasAtBottom:Bool = (logText.scrollV >= logText.maxScrollV);

        logText.appendText(text + "\n");

        if (wasAtBottom) {
            logText.scrollV = logText.maxScrollV;
        }

        updateThumb();
    }

    private function updateThumb():Void {
        if (logText.maxScrollV <= 1) {
            scrollThumb.visible = false;
            return;
        }

        scrollThumb.visible = true;

        // Approximate line height (using font size as estimate)
        var approxLineHeight:Float = logText.defaultTextFormat.size;
        var totalContentHeight:Float = logText.numLines * approxLineHeight;
        thumbHeight = Math.max(20, (consoleHeight / totalContentHeight) * consoleHeight);

        updateThumbGraphics(thumbHeight);

        var ratio:Float = (logText.scrollV - 1) / (logText.maxScrollV - 1);
        scrollThumb.y = ratio * (consoleHeight - thumbHeight);
    }

    private function updateThumbGraphics(height:Float):Void {
        scrollThumb.graphics.clear();
        scrollThumb.graphics.beginFill(0x666666);
        scrollThumb.graphics.drawRect(0, 0, 20, height);
        scrollThumb.graphics.endFill();
    }

    private function onThumbDown(e:MouseEvent):Void {
        dragging = true;
        scrollThumb.startDrag(false, new Rectangle(scrollThumb.x, 0, 0, consoleHeight - thumbHeight));
    }

    private function onThumbUp(e:MouseEvent):Void {
        if (dragging) {
            scrollThumb.stopDrag();
            dragging = false;
        }
    }

    private function onThumbMove(e:MouseEvent):Void {
        if (dragging) {
            updateScrollFromThumb();
        }
    }

    private function onEnterFrame(e:Event):Void {
        // Optional: Can add smoothing or other frame-based logic if needed
    }

    private function updateScrollFromThumb():Void {
        var ratio:Float = scrollThumb.y / (consoleHeight - thumbHeight);
        logText.scrollV = 1 + Math.round(ratio * (logText.maxScrollV - 1));
    }

    private function onMouseWheel(e:MouseEvent):Void {
        logText.scrollV -= e.delta * 3; // Adjust scroll speed
        if (logText.scrollV < 1) logText.scrollV = 1;
        if (logText.scrollV > logText.maxScrollV) logText.scrollV = logText.maxScrollV;
        updateThumb();
    }

    // Method to toggle visibility (or just set this.visible = true/false externally)
    public function toggleVisibility():Void {
        this.visible = !this.visible;
    }
}