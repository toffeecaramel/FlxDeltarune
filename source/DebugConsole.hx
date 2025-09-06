package;

import flixel.FlxG;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;
import haxe.PosInfos;
import haxe.Log;

using StringTools;

class DebugConsole extends Sprite
{
    private var logText:TextField;
    private var scrollTrack:Sprite;
    private var scrollThumb:Sprite;
    private var consoleWidth:Float;
    private var consoleHeight:Float;
    private var thumbHeight:Float = 50;
    private var dragging:Bool = false;

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
        var format = new TextFormat("_sans", 16, 0xFFFFFF);
        logText.defaultTextFormat = format;
        logText.htmlText = ""; // Enable HTML mode
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

    public function addLog(level:String, text:String):Void {
        var color = getHtmlColor(level);
        var levelUpper = level.toUpperCase();
        var decoratedLevel = '<font color="' + color + '"><b>[' + levelUpper + ']</b></font>';
        var decoratedText = '<font color="' + color + '">' + StringTools.htmlEscape(text) + '</font>'; // Escape to prevent HTML issues
        logText.htmlText += decoratedLevel + ' ' + decoratedText + "<br/>";

        var wasAtBottom:Bool = (logText.scrollV >= logText.maxScrollV);

        if (wasAtBottom)
            logText.scrollV = logText.maxScrollV;

        updateThumb();
    }

    private function getHtmlColor(level:String):String {
        return switch (level.toUpperCase()) {
            case "INFO": "#0000FF";
            case "DEBUG": "#00FF00";
            case "WARNING": "#FFFF00";
            case "ERROR": "#FF0000";
            default: "#FFFFFF";
        }
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
        if (dragging)
            updateScrollFromThumb();
    }

    private function onEnterFrame(e:Event):Void {
        // maybe add some animation? idk
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

    public function toggleVisibility():Void {
        this.visible = !this.visible;
    }
}

class Logger {
    public static var console:DebugConsole;

    private static var originalTrace:Dynamic->?PosInfos->Void = haxe.Log.trace;

    public static function init(c:DebugConsole):Void {
        console = c;
        haxe.Log.trace = customTrace;
    }

    private static function customTrace(v:Dynamic, ?infos:PosInfos):Void
        log("TRACE", v, infos);

    public static function info(v:Dynamic, ?infos:PosInfos):Void
        log("INFO", v, infos);

    public static function debug(v:Dynamic, ?infos:PosInfos):Void
        log("DEBUG", v, infos);

    public static function warn(v:Dynamic, ?infos:PosInfos):Void
        log("WARNING", v, infos);

    public static function error(v:Dynamic, ?infos:PosInfos):Void
        log("ERROR", v, infos);

    private static function log(level:String, v:Dynamic, ?infos:PosInfos):Void {
        var prefix:String = "";
        if (infos != null) {
            prefix = infos.fileName + ":" + infos.lineNumber + ": ";
        }
        var message:String = Std.string(v);
        var line:String = "[" + level.toUpperCase() + "] " + prefix + message;

        // Output to default console with ANSI colors (where supported)
        var ansiColor:String = getAnsiColor(level);
        originalTrace(ansiColor + line + "\033[0m", null);
        if (console != null && console.visible)
            console.addLog(level, prefix + message);
    }

    private static function getAnsiColor(level:String):String {
        return switch (level.toUpperCase()) {
            case "INFO": "\033[34m";
            case "DEBUG": "\033[32m";
            case "WARNING": "\033[33m";
            case "ERROR": "\033[31m";
            default: "\033[37m";
        }
    }
}