package backend;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.textures.Texture;
import openfl.media.Sound;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

@:publicFields
/**
 * Utility for loading assets exclusively from the game's directory.
 */
class Asset
{
    private static var graphicCache:Map<String, FlxGraphic> = [];
    private static var textureCache:Map<String, Texture> = [];
    private static var soundCache:Map<String, Sound> = [];

    /**
     * Load a graphic by key from `assets/images/<key>.png`.
     * @param key asset name without extension or path.
     * @param compress whether to upload to GPU texture.
     */
    static function image(key:String, ?compress:Bool = false):FlxGraphic
    {
        final path = getPath('images/${key}.png', IMAGE);
        if (graphicCache.exists(path)) return graphicCache.get(path);
        if (!exists(path, IMAGE))
        {
            trace('[Asset] Missing image: $path');
            return null;
        }
        var bmp = BitmapData.fromFile(path);
        if (bmp == null) return null;
        if (compress)
        {
            var tex = FlxG.stage.context3D.createTexture(
                bmp.width, bmp.height, BGRA, true
            );
            tex.uploadFromBitmapData(bmp);
            bmp.dispose();
            bmp = BitmapData.fromTexture(tex);
            textureCache.set(path, tex);
        }
        var gfx = FlxGraphic.fromBitmapData(bmp, false, path, false);
        gfx.persist = true;
        graphicCache.set(path, gfx);
        return gfx;
    }

    /**
     * Load a Sparrow atlas (JSON + PNG) from `assets/images/<key>.png` & `.xml`.
     */
    static function getAtlas(key:String):FlxAtlasFrames
    {
        final png = image(key, false);
        final xmlPath = getPath('images/$key.xml', TEXT);
        if (png == null || !exists(xmlPath, TEXT)) return null;
        final xml = getText('images/$key.xml');
        return FlxAtlasFrames.fromSparrow(png, xml);
    }

    /**
     * Load a sound from `assets/<from>/<key>`.
     */
    static function sound(key:String, from:String = 'sounds'):Sound
    {
        final path = getPath('$from/${key}', SOUND);
        if (soundCache.exists(path)) return soundCache.get(path);
        if (!exists(path, SOUND))
        {
            trace('[Asset] Missing sound: $path');
            return null;
        }
        var snd = Sound.fromFile(path);
        soundCache.set(path, snd);
        return snd;
    }

    /**
     * Check if file exists on sys or asset bundle.
     */
    static inline function exists(path:String, ?type:AssetType):Bool
    {
        #if sys
        return FileSystem.exists(path);
        #else
        return OpenFlAssets.exists(path, type);
        #end
    }

    /**
     * Get a text file content.
     */
    static inline function getText(path:String):String
    {
        #if sys
        return File.getContent(getPath(path, TEXT));
        #else
        return OpenFlAssets.getText(getPath(path, TEXT));
        #end
    }
    
    /**
     * Parse a JSON file.
     */
    static function loadJSON(path:String):Dynamic
        return Json.parse(getText('$path.json'));

    inline static function getPath(file:String, type:AssetType, ?library:Null<String>)
    {
        if (library != null)
            return getLibraryPath(file, library);

        var filePath = getPreloadPath(file);
        if (exists(filePath, type))
            return filePath;

        return getPreloadPath(file);
    }

    inline static function getPreloadPath(file:String)
    {
        var returnPath:String = 'assets/$file';
        if (!exists(returnPath, null))
            returnPath = swapSpaceDash(returnPath);
        return returnPath;
    }

    static function getLibraryPath(file:String, library = "preload")
        return (library == "preload" || library == "default") ? getPreloadPath(file) : getLibraryPathForce(file, library);

    inline static function getLibraryPathForce(file:String, library:String)
        return '$library/$file';

    static inline function spaceToDash(string:String):String
        return string.replace(" ", "-");

    static inline function dashToSpace(string:String):String
        return string.replace("-", " ");

    static inline function swapSpaceDash(string:String):String
        return string.contains('-') ? dashToSpace(string) : spaceToDash(string);

    /**
     * Clear all cached assets.
     */
    static function clearCache():Void
    {
        for (path in graphicCache.keys()) graphicCache.get(path).destroy();
        for (tex in textureCache.keys())cast(tex, BitmapData).dispose();
        for (snd in soundCache.keys()) cast(snd, Sound).close();
        graphicCache.clear();
        textureCache.clear();
        soundCache.clear();
        System.gc();
    }
}
