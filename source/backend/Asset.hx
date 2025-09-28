package backend;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import haxe.PosInfos;
import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.textures.Texture;
import openfl.media.Sound;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import rulescript.RuleScript;
import rulescript.interps.BytecodeInterp;
import rulescript.interps.RuleScriptInterp;
import rulescript.parsers.HxParser;

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
    static function image(key:String, ?compress:Bool = false, ?_:PosInfos):FlxGraphic
        return outSourcedImage('assets/images/$key');

    /**
     * Load a graphic by key from `any/path/here/<key>.png`.
     * @param key asset name without extension.
     * @param compress whether to upload to GPU texture.
     */
    static function outSourcedImage(key:String, ?compress:Bool = false, ?_:PosInfos):FlxGraphic
    {
        final path = '$key.png';
        if (graphicCache.exists(path)) return graphicCache.get(path);
        if (!exists(path, IMAGE))
        {
            Logger.error('Missing image: $path');
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
     * Loads a animated atlas. (FROM THE ASSETS FOLDER!)
     * @param key The path to said atlas.
     * @param type The atlas type. Check `AtlasType` for available types.
     */
    static function getAtlas(key:String, type:AtlasType = ANIMATE_ATLAS):FlxAtlasFrames
        return getOutSourcedAtlas('assets/images/$key', type);

    /**
     * Loads a animated atlas.
     * @param key The path to said atlas.
     * @param type The atlas type. Check `AtlasType` for available types.
     */
    static function getOutSourcedAtlas(key:String, type:AtlasType = ANIMATE_ATLAS):FlxAtlasFrames
    {
        final png = outSourcedImage(key, false);
        final atlasFile = '$key.${type}';
        if (png == null || !exists(atlasFile, TEXT)) return null;
        final atlas = getText(atlasFile);
        return switch(type){
            case ANIMATE_ATLAS: FlxAtlasFrames.fromSparrow(png, atlas);
            case ASEPRITE_ATLAS: FlxAtlasFrames.fromAseprite(png, atlas);
        }
    }

    /**
     * Load a sound from `assets/<from>/<key>`.
     */
    static function sound(key:String):Sound
        return outSourcedSound('assets/$key');

    /**
     * Load a sound from `any/path/here/<key>.ogg`.
     */
    static function outSourcedSound(key:String):Sound
    {
        final path = '$key';
        if (soundCache.exists(path)) return soundCache.get(path);
        if (!exists(path, SOUND))
        {
            Logger.error('Missing sound: $path');
            return null;
        }
        var snd = Sound.fromFile(path);
        soundCache.set(path, snd);
        return snd;
    }

    /**
     * Load a script from `any/path/here/<key>.hx/mhx`.
     * @param key 
     * @return RuleScript
     */
    static function script(key:String, bytecodeInterp:Bool = false):RuleScript
    {
        var mhx = FileSystem.exists('$key.mhx');
        var path:String = mhx ? '$key.mhx' : '$key.hx';
        var script:RuleScript;
        script = new RuleScript(bytecodeInterp ? new BytecodeInterp() : new RuleScriptInterp(), new HxParser());
        script.getParser(HxParser).setParameters({allowTypes: true});
        if (mhx) script.getParser(HxParser).mode = MODULE;
		script.execute(File.getContent(path));
        return script;
    }

    /**
     * Gets the path to a room from the room id(world/room).
     * @param key 
     * @return String
     */
    static function room(key:String):String
        return 'mods/${curMod.info.modName}/Worlds/$key';

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
        var returnPath:String = '${file.startsWith('mods') ? '' : 'assets/'}$file';
        if (!exists(returnPath, null))
            returnPath = swapSpaceDash(returnPath);
        return returnPath;
    }

    static function getLibraryPath(file:String, library = "preload")
        return (library == "preload" || library == "default") ? getPreloadPath(file) : getLibraryPathForce(file, library);

    inline static function getLibraryPathForce(file:String, library:String)
        return '$library/$file';

    /**
     * Reads all files in a directory.
     * @param dir Directory path.
     * @return Array of file names inside.
     */
    static function readDirectory(dir:String):Array<String>
    {
        #if sys
        if (!exists(dir)) {
            Logger.error('Directory not found: $dir');
            return [];
        }
        return FileSystem.readDirectory(dir);
        #else
        Logger.warn('readDirectory is not available on this target');
        return [];
        #end
    }


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

enum abstract AtlasType(String) {
    var ANIMATE_ATLAS = 'xml';
    var ASEPRITE_ATLAS = 'json';
}