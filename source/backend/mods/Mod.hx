package backend.mods;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;

/**
 * A structure for informations related to an mod.
 */
typedef ModInfo = {
    /**
     * The name of the mod.
     */
    var modName:String;

    /**
     * The authors of this mod.
     */
    var authors:Array<String>;
    /**
     * The version of this mod.
     */
    var version:String;
    /**
     * The description of this mod.
     */
    var description:String;
    /**
     * The starting room of this mod.
     */
    var startingRoom:String;
    /**
     * The parameters given to the room script when entering the starting room of this mod.
     */
    var roomEnterParams:Array<String>;
    /**
     * The party the player starts with when playing this mod.
     */
    var startingParty:Array<String>;
    /**
     * Wether the scripts in this mod are run by the bytecode interpreter or not.
     * 
     * The Bytecode interpreter is faster, but the error messages are less detailed.
     * At the time of writing, the bytecode interpreter is also a little buggy aswell as it is
     * a more expierimental feature.
     * The normal interpreter is slower, but the error messages are more detailed.
     */
    var bytecodeInterp:Bool;
}

/**
 * A class for a single mod, but also has static functions for getting mods.
 */
class Mod {

    //-----Static-----//
    /**
     * The currently loaded mod.
     */
    public static var curMod:Mod = null;
    /**
     * A list of all mods in the mods folder.
     */
    public static var modList(get, null):Array<String>;

    static function get_modList():Array<String> return FileSystem.readDirectory('mods');

    /**
     * Gets the mod from its name.
     * @param name The name of the mod
     * @return Mod
     */
    public static function getModFromName(name:String):Mod 
    {
        var dataPath = 'mods/$name/data.json';
        if (!FileSystem.exists(dataPath)) return null;
        return new Mod(cast Json.parse(File.getContent('mods/$name/data.json')));
    }

    //-----Instanced-----//
    /**
     * The info about this mod.
     */
    public var info:ModInfo;

    /**
     * The global variables that are being used by this mod.
     */
    public var globals:Map<String, Dynamic> = new Map();

    /**
     * The script pack being used on this mod.
     */
    public var scripts:ScriptPack = new ScriptPack('ModScripts');
    
    /**
     * Creates a new mod instance.
     * @param info The info about this mod.
     */
    public function new(info:ModInfo) {
        this.info = info;
    }

    /**
     * Sets a global variable for this mod.
     * @param name The name of the variable.
     * @param value The value of the variable.
     */
    public function setGlobal(name:String, value:Dynamic):Void {
        globals.set(name, value);
    }

    /**
     * Gets a global variable stored for this mod.
     * **This function will return null if the variable does not exist or hasn't been set.**
     * @param name The name of the variable to get.
     * @return Dynamic
     */
    public function getGlobal(name:String):Dynamic return globals.get(name);
}