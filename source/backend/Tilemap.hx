package backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import haxe.Json;

/**
 * A utility class for managing texture atlases, including frame parsing, animation setup,
 * and sprite creation.
 * 
 * Atlases are stored globally and can be accessed by name. This class handles verification of assets,
 * error logging, and animation data.
 * 
 * @author Toffee
 */
class Tilemap
{
    /**
     * Global map of loaded atlas graphics, keyed by atlas name.
     */
    public static var atlasGraphics:Map<String, FlxGraphic> = [];

    /**
     * Global map of atlas frame collections, keyed by atlas name.
     */
    public static var atlasFrameMap:Map<String, FlxAtlasFrames> = [];

    /**
     * Global map of animation data arrays for each atlas, keyed by atlas name.
     * Each animation entry is a dynamic object with 'name', 'frames',
     * 'fps', and 'loop'.
     */
    public static var atlasAnimationData:Map<String, Array<Dynamic>> = [];

    /**
     * Loads a texture atlas from a PNG image and accompanying JSON metadata.
     * 
     * The JSON should contain:
     * - "frames": Array of objects with 'name' (string), 'pos' (array [x, y]), 'size' (array [w, h]).
     * - Optional "animations": Array of objects with 'name' (string), 'frames' (array of strings),
     *   'fps' (int), and optional 'loop' (bool, defaults to true if omitted).
     * 
     * @param atlasName The unique name to assign to this atlas.
     * @param folder The subfolder within the current mod's directory where the assets are located.
     */
    public static function addAtlas(atlasName:String, folder:String):Void
    {
        if (atlasFrameMap.exists(atlasName))
            Logger.warn('Atlas "$atlasName" already exists. Overriding previous data.');

        final modFolder = 'mods/${curMod.info.modName}/$folder';
        final imgPath = '$modFolder/$atlasName.png';
        final imgKey = '$modFolder/$atlasName';
        final jsonPath = '$modFolder/$atlasName.json';
        if (!Asset.exists(imgPath))
        {
            Logger.error('Missing image asset at path: $imgPath. Atlas loading aborted.');
            return;
        }
        if (!Asset.exists(jsonPath))
        {
            Logger.error('Missing JSON metadata at path: $jsonPath. Atlas loading aborted.');
            return;
        }

        final graphic:FlxGraphic = Asset.outSourcedImage(imgKey);
        if (graphic == null)
        {
            Logger.error('Failed to load FlxGraphic from image at $imgPath. Check file integrity or permissions.');
            return;
        }

        atlasGraphics.set(atlasName, graphic);
        var frames:FlxAtlasFrames = new FlxAtlasFrames(graphic);
        try
        {
            final parsedData = Asset.loadJSON(jsonPath);
            
            // Validate frames array existence and type
            if (!Reflect.hasField(parsedData, 'frames') || !Std.isOfType(parsedData.frames, Array))
            {
                Logger.error('JSON at $jsonPath lacks a valid "frames" array. Expected Array<Dynamic>.');
                return;
            }
            
            final jsonArr:Array<Dynamic> = parsedData.frames;
            var frameCount:Int = 0;
            var skippedFrames:Int = 0;

            for (frameData in jsonArr)
            {
                // lol I kinda hate this lmfao
                if (!Reflect.hasField(frameData, 'name') || !Std.isOfType(frameData.name, String) ||
                    !Reflect.hasField(frameData, 'pos') || !Std.isOfType(frameData.pos, Array) || frameData.pos.length != 2 ||
                    !Reflect.hasField(frameData, 'size') || !Std.isOfType(frameData.size, Array) || frameData.size.length != 2)
                {
                    Logger.warn('Skipping invalid frame data (missing or malformed name/pos/size): ${Json.stringify(frameData)}');
                    skippedFrames++;
                    continue;
                }

                // and this too
                if (!Std.isOfType(frameData.pos[0], Float) || !Std.isOfType(frameData.pos[1], Float) ||
                    !Std.isOfType(frameData.size[0], Float) || !Std.isOfType(frameData.size[1], Float))
                {
                    Logger.warn('Skipping frame "${frameData.name}" due to non-numeric pos/size values.');
                    skippedFrames++;
                    continue;
                }

                final rect = new FlxRect(frameData.pos[0], frameData.pos[1], frameData.size[0], frameData.size[1]);
                final size = FlxPoint.get(frameData.size[0], frameData.size[1]);
                final offset = FlxPoint.get();
                frames.addAtlasFrame(rect, size, offset, frameData.name);
                frameCount++;
            }

            atlasAnimationData.set(atlasName, []);
            var animCount:Int = 0;
            var skippedAnims:Int = 0;

            if (Reflect.hasField(parsedData, 'animations') && Std.isOfType(parsedData.animations, Array))
            {
                final animArr:Array<Dynamic> = parsedData.animations;

                for (animData in animArr)
                {
                    // ... and this too
                    if (!Reflect.hasField(animData, 'name') || !Std.isOfType(animData.name, String) ||
                        !Reflect.hasField(animData, 'frames') || !Std.isOfType(animData.frames, Array) ||
                        !Reflect.hasField(animData, 'fps') || !Std.isOfType(animData.fps, Int))
                    {
                        Logger.warn('Skipping invalid animation data (missing or malformed name/frames/fps): ${Json.stringify(animData)}');
                        skippedAnims++;
                        continue;
                    }

                    // loop is optional!
                    var loop:Bool = true;
                    if (Reflect.hasField(animData, 'loop') && Std.isOfType(animData.loop, Bool))
                        loop = animData.loop;
                    else if (Reflect.hasField(animData, 'loop'))
                        Logger.warn('Animation "${animData.name}" has invalid "loop" type (expected Bool). Defaulting to true.');

                    final enhancedAnim = {
                        name: animData.name,
                        frames: animData.frames,
                        fps: animData.fps,
                        loop: loop
                    };
                    atlasAnimationData.get(atlasName).push(enhancedAnim);
                    animCount++;
                }
            }

            var logMessage = 'Atlas "$atlasName" loaded successfully:\n' +
                             '- Image: $imgPath (dimensions: ${graphic.width}x${graphic.height})\n' +
                             '- Frames: $frameCount loaded (${jsonArr.length - skippedFrames} valid, $skippedFrames skipped)\n' +
                             '- Animations: $animCount loaded ($skippedAnims skipped)';
            Logger.info(logMessage);
        }
        catch (e:Dynamic)
        {
            Logger.error('JSON parsing error for atlas "$atlasName" at $jsonPath: $e\nStack trace: ${e.stack}');
            return;
        }

        atlasFrameMap.set(atlasName, frames);
    }

    /**
     * Retrieves a specific frame from a loaded atlas by name.
     * 
     * @param name The name of the frame as defined in the JSON.
     * @param atlasName The name of the loaded atlas.
     * @return The FlxFrame if found, or null with an error log.
     */
    public static function getFrame(name:String, atlasName:String):FlxFrame
    {
        final frames:FlxAtlasFrames = atlasFrameMap.get(atlasName);
        if (frames == null)
        {
            Logger.error('Atlas "$atlasName" not loaded. Call addAtlas() first.');
            return null;
        }

        final frame:FlxFrame = frames.getByName(name);
        if (frame == null)
            Logger.error('Frame "$name" not found in atlas "$atlasName". Available frames: ${frames.frames.map(f -> f.name).join(", ")}');
        return frame;
    }

    /**
     * Retrieves the full FlxAtlasFrames collection for a loaded atlas.
     * 
     * @param atlasName The name of the loaded atlas.
     * @return The FlxAtlasFrames if loaded, or null with an error log.
     */
    public static function getAtlasFrames(atlasName:String):FlxAtlasFrames
    {
        var frames:FlxAtlasFrames = atlasFrameMap.get(atlasName);
        if (frames == null)
            Logger.error('Atlas "$atlasName" not loaded. Available atlases: ${[for (k in atlasFrameMap.keys()) k].join(", ")}');
        
        return frames;
    }

    /**
     * Creates a new FlxSprite using the frames from a loaded atlas and sets up its animations.
     * 
     * Animations are added based on the metadata, with per-animation looping control.
     * 
     * @param atlasName The name of the loaded atlas.
     * @return A configured FlxSprite, or null if the atlas is not loaded.
     */
    public static function createAnimatedSprite(atlasName:String):FlxSprite
    {
        var frames = getAtlasFrames(atlasName);
        if (frames == null) return null;

        var sprite = new FlxSprite();
        sprite.frames = frames;

        var animData = atlasAnimationData.get(atlasName);
        if (animData != null)
        {
            for (anim in animData)
            {
                var names:Array<String> = anim.frames;
                var fps:Int = anim.fps;
                var loop:Bool = anim.loop;
                sprite.animation.addByNames(anim.name, names, fps, loop);
                Logger.debug('Added animation "${anim.name}" to sprite (FPS: $fps, Loop: $loop, Frames: ${names.length})');
            }
        }

        return sprite;
    }

    public static function removeAtlas(atlasName:String):Void
    {
        if (atlasFrameMap.exists(atlasName))
        {
            var graphic = atlasGraphics.get(atlasName);
            if (graphic != null) graphic.destroy();
            
            atlasGraphics.remove(atlasName);
            atlasFrameMap.remove(atlasName);
            atlasAnimationData.remove(atlasName);
            Logger.info('Atlas "$atlasName" removed.');
        }
        else
        {
            Logger.warn('Atlas "$atlasName" not found for removal.');
        }
    }

    public static function listLoadedAtlases():String
    {
        if (atlasFrameMap.keys().hasNext() == false) return "No atlases currently loaded.";

        var summary = "Loaded Atlases:\n";
        for (key in atlasFrameMap.keys())
        {
            var frames = atlasFrameMap.get(key);
            var anims = atlasAnimationData.get(key);
            var graphic = atlasGraphics.get(key);
            summary += '- $key: ${frames.frames.length} frames, ${anims != null ? anims.length : 0} animations, ' +
                       'Image size: ${graphic != null ? '${graphic.width}x${graphic.height}' : 'N/A'}\n';
        }
        return summary;
    }
}