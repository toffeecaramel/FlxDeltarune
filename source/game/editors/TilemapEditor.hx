package game.editors;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import openfl.display.Shape;
#if sys
import sys.io.File;
#end

// TODO: (maybe) documment this class :3
typedef FrameData = {
    name:String,
    pos:FlxPoint,
    size:FlxPoint
}

typedef AnimData = {
    name:String,
    frames:Array<String>,
    fps:Int,
    loop:Bool
}

class TilemapEditor extends FlxState
{
    var atlasName:String;
    var folder:String;
    var modFolder:String;
    var imgPath:String;
    var jsonPath:String;

    var worldCamera:FlxCamera;
    var uiCamera:FlxCamera;

    var image:FlxSprite;
    var overlay:FlxSprite;
    var frames:Array<FrameData> = [];
    var animations:Array<AnimData> = [];

    var gridSize:Float = 16;
    var showGrid:Bool = true;
    var snapEnabled:Bool = true;
    var animationMode:Bool = false;

    var statusText:FlxText;
    var hoverText:FlxText;
    var animListText:FlxText;
    var previewSprite:FlxSprite; 
    var previewAnimIndex:Int = -1;

    var selecting:Bool = false;
    var startPos:FlxPoint;
    var selectRect:FlxRect;

    var panning:Bool = false;
    var panStart:FlxPoint;

    var inputActive:FlxInputText;
    var promptLabel:FlxText;
    var selectedFrames:Array<Int> = [];

    var star:FlxSprite;
    public function new(atlasName:String = 'testTilemap', folder:String = 'Tilemaps')
    {
        super();
        this.atlasName = atlasName;
        this.folder = folder;
        modFolder = 'mods/${currentMod.info.modName}/$folder';
        imgPath = '$modFolder/$atlasName.png';
        jsonPath = '$modFolder/$atlasName.json';
    }

    override public function create():Void
    {
        super.create();

        worldCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        worldCamera.bgColor = FlxColor.BLACK;
        FlxG.cameras.reset(worldCamera);
        FlxG.camera = worldCamera;

        uiCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        uiCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(uiCamera, false);

        var graphic = Asset.outSourcedImage(modFolder + '/' + atlasName);
        if (graphic == null)
        {
            Logger.error('Failed to load image for atlas $atlasName');
            return;
        }

        image = new FlxSprite(0, 0, graphic);
        image.camera = worldCamera;
        add(image);

        overlay = new FlxSprite(0, 0).makeGraphic(Std.int(image.width), Std.int(image.height), FlxColor.TRANSPARENT, true);
        overlay.camera = worldCamera;
        add(overlay);

        previewSprite = new FlxSprite(FlxG.width - 200, FlxG.height - 200);
        previewSprite.scrollFactor.set(0, 0);
        previewSprite.camera = uiCamera;
        previewSprite.visible = false;
        add(previewSprite);

        loadJSON();

        statusText = new FlxText(10, 10, 0, "");
        statusText.scrollFactor.set(0, 0);
        statusText.camera = uiCamera;
        add(statusText);

        hoverText = new FlxText(0, 0, 300, "");
        hoverText.scrollFactor.set(0, 0);
        hoverText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
        hoverText.camera = uiCamera;
        add(hoverText);

        animListText = new FlxText(FlxG.width - 300, 10, 280, "");
        animListText.scrollFactor.set(0, 0);
        animListText.camera = uiCamera;
        add(animListText);

        star = new FlxSprite().loadGraphic(Asset.image('ui/save'), true, 20, 19);
        star.camera = uiCamera;
        star.animation.add('loop', [0,1,2,3,4,5], 5, true);
        star.animation.play('loop');
        star.scale.set(3, 3);
        star.updateHitbox();
        add(star);
       	star.setPosition(FlxG.width - star.width, FlxG.height - star.height);
       	star.alpha = 0.0001;

        updateOverlay();
        updateAnimList();
    }

    function loadJSON():Void
    {
        if (Asset.exists(jsonPath))
        {
            try
            {
                var parsedData = Json.parse(Asset.getText(jsonPath));
                var jsonArr:Array<Dynamic> = parsedData.frames;
                if (jsonArr != null)
                {
                    for (frameData in jsonArr)
                    {
                        if (Reflect.hasField(frameData, 'name') && Reflect.hasField(frameData, 'pos') && Reflect.hasField(frameData, 'size'))
                        {
                            frames.push({
                                name: frameData.name,
                                pos: FlxPoint.get(frameData.pos[0], frameData.pos[1]),
                                size: FlxPoint.get(frameData.size[0], frameData.size[1])
                            });
                        }
                    }
                }
                if (Reflect.hasField(parsedData, 'animations'))
                {
                    var animArr:Array<Dynamic> = parsedData.animations;
                    if (animArr != null)
                    {
                        for (anim in animArr)
                        {
                            if (Reflect.hasField(anim, 'name') && Reflect.hasField(anim, 'frames') && Reflect.hasField(anim, 'fps'))
                            {
                                var loop:Bool = true;
                                if (Reflect.hasField(anim, 'loop')) loop = anim.loop;
                                animations.push({
                                    name: anim.name,
                                    frames: anim.frames,
                                    fps: anim.fps,
                                    loop: loop
                                });
                            }
                        }
                    }
                }
            }
            catch (e:Dynamic)
            {
                Logger.error('Error loading existing JSON: $e');
            }
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (inputActive != null && inputActive.exists && inputActive.hasFocus)
            return;
        else if (inputActive != null)
            cleanupInput();

        updateStatusText();
        handleKeyInputs();
        handleMouseInteractions();
        updateHoverInfo();
        if (previewAnimIndex >= 0 && previewAnimIndex < animations.length)
        {
            previewSprite.visible = true;
            if (previewSprite.animation.curAnim == null || previewSprite.animation.curAnim.name != animations[previewAnimIndex].name)
                setupPreviewSprite(previewAnimIndex);
        }
        else if (animationMode && selectedFrames.length > 0)
        {
            previewSprite.visible = true;
            setupSelectedPreview();
        }
        else
        {
            previewSprite.visible = false;
            previewSprite.animation.destroyAnimations();
        }

        if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
            saveJSON();
    }

    function updateStatusText():Void
    {
        var mouseWorld = FlxG.mouse.getWorldPosition();
        var mouseInfo = '\nMouse: ${Std.int(mouseWorld.x)}, ${Std.int(mouseWorld.y)}';
        var controlsText = animationMode ? '\nA: tog mode\nClick: tog select\nENTER: create anim\nD/ESC: clear sel\nDEL: del anim (if sel)\nP: preview anim\nUP/DOWN: cycle anim\nRMB: del/pan\nCtrl+S: save' : '\nQ/E: grid size\nG: tog grid\nS: tog snap\nA: anim mode\nZ/X: zoom\nRMB: pan/del tile\nLMB: select\nCtrl+S: save';
        var modeText = animationMode ? '\nAnim mode: on (${selectedFrames.length} selected)' : '\nAnim mode: off';
        statusText.text = 'Grid: $gridSize\nZoom: ${FlxG.camera.zoom}\nSnap: ${snapEnabled ? "on" : "off"}\nGrid: ${showGrid ? "on" : "off"}$modeText$mouseInfo$controlsText';
    }

    function handleKeyInputs():Void
    {
        if (FlxG.keys.justPressed.A)
        {
            animationMode = !animationMode;
            if (animationMode)
            {
                selecting = false;
                selectRect = null;
                previewAnimIndex = -1;
            }
            updateOverlay();
            updateAnimList();
        }

        if (FlxG.keys.justPressed.D || FlxG.keys.justPressed.ESCAPE)
        {
            if (animationMode)
            {
                selectedFrames = [];
                previewAnimIndex = -1;
                updateOverlay();
                updateAnimList();
            }
        }

        if (animationMode && FlxG.keys.justPressed.ENTER && selectedFrames.length > 0)
            promptAnimName();
        
        if (animationMode && FlxG.keys.justPressed.DELETE && previewAnimIndex >= 0)
        {
            animations.splice(previewAnimIndex, 1);
            previewAnimIndex = -1;
            updateAnimList();
            updateOverlay();
        }

        if (animationMode && FlxG.keys.justPressed.P)
        {
            if (previewAnimIndex >= 0) previewAnimIndex = -1;
            else if (animations.length > 0) previewAnimIndex = animations.length - 1;
        }

        if (animationMode && (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN))
        {
            if (animations.length > 0)
            {
            	if(FlxG.keys.justPressed.UP)
            	{
            		if (previewAnimIndex == -1) previewAnimIndex = animations.length - 1;
                	else previewAnimIndex = (previewAnimIndex - 1 + animations.length) % animations.length;
            	}
            	else
            	{
            		if (previewAnimIndex == -1) previewAnimIndex = 0;
                	else previewAnimIndex = (previewAnimIndex + 1) % animations.length;
            	}

            	if(previewSprite.visible) framesFromAnim();
            }
        }

        if (!animationMode)
        {
            if (FlxG.keys.justPressed.Q)
            {
                gridSize = Math.max(1, (!FlxG.keys.pressed.SHIFT) ? gridSize / 2 : gridSize - 1);
                updateOverlay();
            }
            if (FlxG.keys.justPressed.E)
            {
                (!FlxG.keys.pressed.SHIFT) ? gridSize *= 2 : gridSize += 1;
                updateOverlay();
            }

            if (FlxG.keys.justPressed.G)
            {
                showGrid = !showGrid;
                updateOverlay();
            }

            if (FlxG.keys.justPressed.S)
                snapEnabled = !snapEnabled;
        }

        if (FlxG.keys.justPressed.Z)
            zoomAtMouse(1.1);
        if (FlxG.keys.justPressed.X)
            zoomAtMouse(1 / 1.1);
    }

    function framesFromAnim():Void
    {
        selectedFrames = [];
        if (previewAnimIndex >= 0)
        {
            for (frameName in animations[previewAnimIndex].frames)
            {
                var frameIndex = -1;
                for (j in 0...frames.length)
                {
                    if (frames[j].name == frameName)
                    {
                        frameIndex = j;
                        break;
                    }
                }
                if (frameIndex != -1) selectedFrames.push(frameIndex);
            }
        }
        updateOverlay();
        updateAnimList();
    }

    function handleMouseInteractions():Void
    {
        final mouseWorld = FlxG.mouse.getWorldPosition();

        if (FlxG.mouse.wheel != 0)
            zoomAtMouse((FlxG.mouse.wheel > 0) ? 1.1 : (1 / 1.1));
        if (FlxG.mouse.justPressedRight)
        {
            var hitTile = deleteHoveredFrame(mouseWorld);
            if (!hitTile)
            {
                if (selecting)
                {
                    selecting = false;
                    updateOverlay();
                }
                else if (animationMode)
                {
                    selectedFrames = [];
                    previewAnimIndex = -1;
                    updateOverlay();
                    updateAnimList();
                }
                else
                {
                    panning = true;
                    panStart = FlxG.mouse.getViewPosition().clone();
                }
            }
        }

        if (panning && FlxG.mouse.pressedRight)
        {
            var curr = FlxG.mouse.getViewPosition();
            FlxG.camera.scroll.x += panStart.x - curr.x;
            FlxG.camera.scroll.y += panStart.y - curr.y;
            panStart = curr.clone();
        }
        if (FlxG.mouse.justReleasedRight)
            panning = false;

        if (animationMode && FlxG.mouse.justPressed && !FlxG.mouse.pressedRight)
        {
            toggleSelectedFrame(mouseWorld);
            updateAnimList();
        }

        if (!animationMode)
        {
            if (FlxG.mouse.justPressed && !FlxG.mouse.pressedRight)
            {
                var mx = snapEnabled ? Math.round(mouseWorld.x / gridSize) * gridSize : mouseWorld.x;
                var my = snapEnabled ? Math.round(mouseWorld.y / gridSize) * gridSize : mouseWorld.y;
                startPos = FlxPoint.get(mx, my);
                selecting = true;
                selectRect = null;
            }

            if (selecting && FlxG.mouse.pressed && !FlxG.mouse.pressedRight)
            {
                final mx = snapEnabled ? Math.round(mouseWorld.x / gridSize) * gridSize : mouseWorld.x;
                final my = snapEnabled ? Math.round(mouseWorld.y / gridSize) * gridSize : mouseWorld.y;
                final w = Math.abs(startPos.x - mx);
                final h = Math.abs(startPos.y - my);
                if (w > 0 && h > 0)
                {
                    selectRect = new FlxRect(Math.min(startPos.x, mx), Math.min(startPos.y, my), w, h);
                    updateOverlay();
                }
            }

            if (FlxG.mouse.justReleased && selecting)
                onSelRelease(mouseWorld);
        }
    }

    function deleteHoveredFrame(mouseWorld:FlxPoint):Bool
    {
        var hitTile = false;
        for (i in 0...frames.length)
        {
            var frame = frames[i];
            var r = new FlxRect(frame.pos.x, frame.pos.y, frame.size.x, frame.size.y);
            if (r.containsPoint(mouseWorld))
            {
                frames.splice(i, 1);
                frame.pos.put();
                frame.size.put();
                var selIndex = selectedFrames.indexOf(i);
                if (selIndex != -1) selectedFrames.splice(selIndex, 1);
                for (j in 0...selectedFrames.length)
                    if (selectedFrames[j] > i) selectedFrames[j]--;
                updateOverlay();
                updateAnimList();

                FlxG.sound.play(Asset.sound('sounds/battle/damage.wav'));
                showTempText(frame.pos.x, frame.pos.y, "Deleted!", FlxColor.RED);
                hitTile = true;
                break;
            }
        }
        return hitTile;
    }

    function toggleSelectedFrame(mouseWorld:FlxPoint):Void
    {
        var hitFrameIndex = -1;
        for (i in 0...frames.length)
        {
            final frame = frames[i];
            var r = new FlxRect(frame.pos.x, frame.pos.y, frame.size.x, frame.size.y);
            if (r.containsPoint(mouseWorld))
            {
                hitFrameIndex = i;
                break;
            }
        }
        if (hitFrameIndex != -1)
        {
            var selIndex = selectedFrames.indexOf(hitFrameIndex);
            if (selIndex != -1)
                selectedFrames.splice(selIndex, 1);
            else
            {
                selectedFrames.push(hitFrameIndex);
                selectedFrames.sort(Reflect.compare);
            }
            updateOverlay();
        }
    }

    function onSelRelease(mouseWorld:FlxPoint):Void
    {
        selecting = false;
        var finalRect:FlxRect = null;
        if (selectRect != null && selectRect.width > 0 && selectRect.height > 0)
        {
            final endX = snapEnabled ? Math.round(mouseWorld.x / gridSize) * gridSize : mouseWorld.x;
            final endY = snapEnabled ? Math.round(mouseWorld.y / gridSize) * gridSize : mouseWorld.y;
            final x = Math.min(startPos.x, endX);
            final y = Math.min(startPos.y, endY);
            final w = Math.abs(startPos.x - endX);
            final h = Math.abs(startPos.y - endY);
            finalRect = new FlxRect(x, y, w, h);
            finalRect = finalRect.intersection(new FlxRect(0, 0, image.width, image.height));
            if (finalRect.width <= 0 || finalRect.height <= 0)
            {
                finalRect = null;
            }
        }
        startPos.put();
        updateOverlay();

        if (finalRect != null)
        {
            var overlaps = false;
            for (frame in frames)
            {
                // fr
                var fr = new FlxRect(frame.pos.x, frame.pos.y, frame.size.x, frame.size.y);
                if (finalRect.overlaps(fr))
                {
                    overlaps = true;
                    break;
                }
            }

            if (overlaps)
            {
                showTempText(finalRect.x, finalRect.y, "Space occupied!", FlxColor.RED);
                FlxG.sound.play(Asset.sound('sounds/battle/hurt.wav'));
            }
            else
                promptName(finalRect);
        }
    }

    var check:Bool = false;
    function updateHoverInfo():Void
    {
        hoverText.visible = false;
        for (frame in frames)
        {
            var r = new FlxRect(frame.pos.x, frame.pos.y, frame.size.x, frame.size.y);
            if (r.containsPoint(FlxG.mouse.getWorldPosition()))
            {
            	final oldTxt = frame.name + "\nPos: " + Std.int(frame.pos.x) + ", " + Std.int(frame.pos.y) + "\nSize: " + Std.int(frame.size.x) + ", " + Std.int(frame.size.y);
            	if(hoverText.text != oldTxt) FlxG.sound.play(Asset.sound('sounds/player/menumove.wav'));
                hoverText.text = oldTxt;
                hoverText.setPosition(0, FlxG.height - hoverText.height);
                hoverText.visible = true;
                break;
            }
        }
    }

    function zoomAtMouse(factor:Float):Void
    {
        final mouseWorld = FlxG.mouse.getWorldPosition();
        FlxG.camera.zoom *= factor;
        final newMouseWorld = FlxG.mouse.getWorldPosition();
        FlxG.camera.scroll.x += mouseWorld.x - newMouseWorld.x;
        FlxG.camera.scroll.y += mouseWorld.y - newMouseWorld.y;
    }

    function updateOverlay():Void
    {
        // honestly? these rock
        // openfl's shape is awesome
        overlay.pixels.fillRect(overlay.pixels.rect, FlxColor.TRANSPARENT);

        var shape = new Shape();

        if (showGrid)
        {
            shape.graphics.lineStyle(1, FlxColor.GRAY, 0.3);
            final w = image.width;
            final h = image.height;
            for (i in 0...Std.int(w / gridSize) + 1)
            {
                shape.graphics.moveTo(i * gridSize, 0);
                shape.graphics.lineTo(i * gridSize, h);
            }
            for (i in 0...Std.int(h / gridSize) + 1)
            {
                shape.graphics.moveTo(0, i * gridSize);
                shape.graphics.lineTo(w, i * gridSize);
            }
        }

        shape.graphics.lineStyle(1, FlxColor.RED);
        for (frame in frames)
            shape.graphics.drawRect(frame.pos.x, frame.pos.y, frame.size.x, frame.size.y);

        if (animationMode)
        {
            shape.graphics.lineStyle(2, FlxColor.BLUE);
            for (i in selectedFrames)
            {
                if (i >= 0 && i < frames.length)
                {
                    var frame = frames[i];
                    shape.graphics.drawRect(frame.pos.x, frame.pos.y, frame.size.x, frame.size.y);
                }
            }
        }

        if (!animationMode && selecting && selectRect != null)
        {
            shape.graphics.lineStyle(2, FlxColor.GREEN);
            shape.graphics.drawRect(selectRect.x, selectRect.y, selectRect.width, selectRect.height);
        }

        overlay.pixels.draw(shape);
        overlay.dirty = true;
    }

    function updateAnimList():Void
    {
        if(animations != null && animations.length > 0)
        {
            var listStr = "Animations:\n";
            for (i in 0...animations.length)
            {
                final sel = (i == previewAnimIndex) ? " <-" : "";
                final anim = animations[i];
                listStr += '$i: ${anim.name} (${anim.frames.length} frames, ${anim.fps} FPS, Loop: ${anim.loop})$sel\n';
            }
            animListText.text = listStr;
        }
        else animListText.text = '';
    }

    function setupPreviewSprite(animIndex:Int):Void
    {
        previewSprite.animation.destroyAnimations();
        previewSprite.frames = null;

        var anim = animations[animIndex];
        if (anim.frames.length == 0) return;

        var atlasFrames = new FlxAtlasFrames(image.graphic);
        var maxWidth:Float = 0;
        var maxHeight:Float = 0;

        for (frameName in anim.frames)
        {
            var fData = [for (f in frames) if (f.name == frameName) f][0];
            if (fData != null)
            {
                var rect = new FlxRect(fData.pos.x, fData.pos.y, fData.size.x, fData.size.y);
                var size = FlxPoint.get(fData.size.x, fData.size.y);
                var offset = FlxPoint.get();
                atlasFrames.addAtlasFrame(rect, size, offset, fData.name);
                maxWidth = Math.max(maxWidth, fData.size.x);
                maxHeight = Math.max(maxHeight, fData.size.y);
                offset.put();
                size.put();
            }
        }

        previewSprite.frames = atlasFrames;
        previewSprite.animation.addByNames(anim.name, anim.frames, anim.fps, anim.loop);
        previewSprite.animation.play(anim.name);

        previewSprite.setPosition(FlxG.width - maxWidth - 10, FlxG.height - maxHeight - 10);
    }

    function setupSelectedPreview():Void
    {
        previewSprite.animation.destroyAnimations();
        previewSprite.frames = null;

        if (selectedFrames.length == 0) return;

        var atlasFrames = new FlxAtlasFrames(image.graphic);
        var maxWidth:Float = 0;
        var maxHeight:Float = 0;
        var tempNames:Array<String> = [];

        for (i in selectedFrames)
        {
            var fData = frames[i];
            var rect = new FlxRect(fData.pos.x, fData.pos.y, fData.size.x, fData.size.y);
            var size = FlxPoint.get(fData.size.x, fData.size.y);
            var offset = FlxPoint.get();
            atlasFrames.addAtlasFrame(rect, size, offset, fData.name);
            tempNames.push(fData.name);
            maxWidth = Math.max(maxWidth, fData.size.x);
            maxHeight = Math.max(maxHeight, fData.size.y);
            offset.put();
            size.put();
        }

        previewSprite.frames = atlasFrames;
        previewSprite.animation.addByNames("preview", tempNames, 10, true);  // Default 10 FPS, loop true
        previewSprite.animation.play("preview");
        
        previewSprite.setPosition(FlxG.width - maxWidth - 10, FlxG.height - maxHeight - 10);
    }

    function promptName(rect:FlxRect):Void
    {
        createPromptLabel("Enter tile name:");
        var input = createInputText("");
        input.callback = function(text:String, action:String):Void
        {
        	FlxG.sound.play(Asset.sound('sounds/battle/graze.wav'));
            if (action == 'enter')
            {
                var trimmed = text.trim();
                if (trimmed != "")
                {
                    frames.push({name: trimmed, pos: FlxPoint.get(rect.x, rect.y), size: FlxPoint.get(rect.width, rect.height)});
                    updateOverlay();
                }
                cleanupInput();
            }
        };
        input.hasFocus = true;
    }

    function promptAnimName():Void
    {
        createPromptLabel("Enter animation name:");
        var input = createInputText("");
        input.callback = function(text:String, action:String):Void
        {
        	FlxG.sound.play(Asset.sound('sounds/battle/graze.wav'));
            if (action == 'enter')
            {
                var trimmed = text.trim();
                if (trimmed != "")
                {
                    cleanupInput();
                    promptAnimFps(trimmed);
                }
                else
                    cleanupInput();
            }
        };
        input.hasFocus = true;
    }

    function promptAnimFps(animName:String):Void
    {
        createPromptLabel("Enter FPS (default 10):");
        var input = createInputText("10");
        input.callback = function(text:String, action:String):Void
        {
        	FlxG.sound.play(Asset.sound('sounds/battle/graze.wav'));
            if (action == 'enter')
            {
                var fps = 10;
                var parsed = Std.parseInt(text.trim());
                if (parsed != null && parsed > 0) fps = parsed;
                cleanupInput();
                promptAnimLoop(animName, fps);
            }
        };
        input.hasFocus = true;
    }

    function promptAnimLoop(animName:String, fps:Int):Void
    {
        createPromptLabel("Loop? (Y/N, default Y):");
        var input = createInputText("Y");
        input.callback = function(text:String, action:String):Void
        {
            if (action == 'enter')
            {
                var loop = text.trim().toUpperCase() != "N";
                var frameNames = [];
                for (i in selectedFrames)
                {
                    if (i >= 0 && i < frames.length)
                        frameNames.push(frames[i].name);
                }
                if (frameNames.length > 0)
                {
                    animations.push({name: animName, frames: frameNames, fps: fps, loop: loop});
                    selectedFrames = [];
                    updateOverlay();
                    updateAnimList();
                }
                cleanupInput();
            }
        };
        input.hasFocus = true;
    }

    function createPromptLabel(text:String):Void
    {
        promptLabel = new FlxText(FlxG.width / 2 - 100, FlxG.height / 2 - 50, 400, text, 16);
        promptLabel.scrollFactor.set(0, 0);
        promptLabel.camera = uiCamera;
        promptLabel.color = FlxColor.WHITE;
        add(promptLabel);
    }

    function createInputText(defaultText:String):FlxInputText
    {
        var input = new FlxInputText(FlxG.width / 2 - 100, FlxG.height / 2 - 20, 200, defaultText, 20);
        inputActive = input;
        input.scrollFactor.set(0, 0);
        input.camera = uiCamera;
        input.background = true;
        input.backgroundColor = FlxColor.BLACK;
        input.borderStyle = OUTLINE;
        input.borderColor = FlxColor.WHITE;
        add(input);
        return input;
    }

    function cleanupInput():Void
    {
        if (inputActive != null)
        {
            remove(inputActive, true);
            inputActive.destroy();
            inputActive = null;
        }
        if (promptLabel != null)
        {
            remove(promptLabel, true);
            promptLabel.destroy();
            promptLabel = null;
        }
    }

    function showTempText(x:Float, y:Float, text:String, color:FlxColor):Void
    {
        var tempText = new FlxText(x, y, 200, text, 16);
        tempText.color = color;
        tempText.camera = worldCamera;
        add(tempText);
        FlxTween.tween(tempText, {alpha: 0}, 1.5, {onComplete: function(_) { remove(tempText, true); tempText.destroy(); }});
    }

    var ok:FlxTween;
    function saveJSON():Void
    {
        var data:Dynamic = {frames: []};
        for (frame in frames)
        {
            data.frames.push({
                name: frame.name,
                pos: [frame.pos.x, frame.pos.y],
                size: [frame.size.x, frame.size.y]
            });
        }
        data.animations = [];
        for (anim in animations)
        {
            data.animations.push({
                name: anim.name,
                frames: anim.frames,
                fps: anim.fps,
                loop: anim.loop
            });
        }
        var jsonStr = Json.stringify(data, null, "  ");
        #if sys
        File.saveContent(jsonPath, jsonStr);
        Logger.info('Saved tilemap JSON to $jsonPath');
        #end

        // had a better idea
        /*var saveText = new FlxText(FlxG.width / 2 - 100, FlxG.height / 2 - 50, 200, "Saved!", 16);
        saveText.scrollFactor.set(0, 0);
        saveText.camera = uiCamera;
        saveText.color = FlxColor.LIME;
        add(saveText);
        FlxTween.tween(saveText, {alpha: 0}, 2, {onComplete: function(_) { remove(saveText, true); saveText.destroy(); }});*/

        FlxG.sound.play(Asset.sound('sounds/player/save.wav'));
        if(ok != null && ok.active)
        	ok.cancel();

        star.alpha = 1;
        ok = FlxTween.tween(star, {alpha: 0}, 2, {startDelay: 0.5});
    }
}