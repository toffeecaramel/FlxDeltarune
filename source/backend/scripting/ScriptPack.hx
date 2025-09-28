// Credits to the Codename Crew for the original scripting and event system concepts,
// which have been adapted here for use with RuleScript.
// https://github.com/CodenameCrew/CodenameEngine/blob/main/source/funkin/backend/scripting/ScriptPack.hx

package backend.scripting;

import backend.scripting.events.DeltaEvent;
import flixel.util.FlxStringUtil;
import rulescript.RuleScript;

/**
 * Used to group multiple scripts together, and easily be able to call them.
**/
@:access(DeltaEvent)
class ScriptPack {
    public var scripts:Array<RuleScript> = [];
    public var additionalDefaultVariables:Map<String, Dynamic> = [];
    public var publicVariables:Map<String, Dynamic> = [];
    public var parent:Dynamic = null;
    public var name:String;

    /**
     * Loads all scripts in the pack.
    **/
    public function load() {
        for(e in scripts) {
            //TODO
        }
    }

    /**
     * Checks if the script pack contains a script with a specific path.
     * @param path Path to check
     */
    public function contains(path:String) {
        for(e in scripts)
            if (Reflect.field(e, "path") == path)  // Assuming RuleScript has no built-in path; add if needed
                return true;
        return false;
    }

    public function new(name:String) {
        this.name = name;
        additionalDefaultVariables["importScript"] = importScript;
    }

    /**
     * Gets a script by path.
     * @param name Path to the script
    **/
    public function getByPath(name:String) {
        for(s in scripts)
            if (Reflect.field(s, "path") == name)  // Assuming path field; customize as needed
                return s;
        return null;
    }

    /**
     * Gets a script by name.
     * @param name Name of the script
    **/
    public function getByName(name:String) {
        for(s in scripts)
            if (Reflect.field(s, "fileName") == name)  // Assuming fileName; customize
                return s;
        return null;
    }

    /**
     * Imports a script by path.
     * @param path Path to the script
     * @throws Error if the script does not exist
    **/
    public function importScript(path:String):RuleScript {
        var script = Asset.script(path);
        if (script == null) {
            throw 'Script at ${path} does not exist.';
            return null;
        }
        add(script);
        return script;
    }

    /**
     * Calls a function on every single script.
     * Only calls on scripts that are active (assume all active unless added flag).
     * @param func Function to call
     * @param parameters Parameters to pass to the function
    **/
    public function call(func:String, ?parameters:Array<Dynamic>):Dynamic {
        for(e in scripts) {
            // if (!e.active) continue;  // Add active flag to RuleScript? ifk
            var method = getScriptVar(e, func);
            if (method != null) {
                Reflect.callMethod(null, method, parameters); 
            }
        }
        return null;
    }

    /**
     * Sends an event to every single script, and returns the event.
     * @param func Function to call
     * @param event Event (will be the first parameter of the function)
     * @return (modified by scripts)
     */
    public inline function event<T:DeltaEvent>(func:String, event:T):T {
        for(e in scripts) {
            // if(!e.active) continue; 
            call(func, [event]);
            if (event.cancelled && !event.__continueCalls) break;
        }
        return event;
    }

    /**
     * Gets the first script that has a variable with a specific name.
     * @param val Name of the variable
    **/
    public function get(val:String):Dynamic {
        for(e in scripts) {
            var v = getScriptVar(e, val, false);
            if (v != null) return v;
        }
        return null;
    }

    /**
     * Reloads all scripts in the pack.
    **/
    public function reload() {
        for(e in scripts) {
            //TODO
        }
    }

    /**
     * Sets a variable in every script.
    **/
    public function set(val:String, value:Dynamic) {
        for(e in scripts) setScriptVar(e, val, value);
    }

    /**
     * Sets the parent/this of every script in the pack.
     */
    public function setParent(parent:Dynamic) {
        this.parent = parent;
        for(e in scripts) setScriptVar(e, "this", parent);  // Set 'this' in variables
    }

    /**
     * Destroys all scripts in the pack.
    **/
    public function destroy() {
        for(e in scripts) {
            // TODO?
        }
        scripts = [];
    }

    /**
     * Adds a script to the pack, and sets the parent/this of the script.
    **/
    public function add(script:RuleScript) {
        scripts.push(script);
        __configureNewScript(script);
    }

    /**
     * Removes a script from the pack.
     * Does not reset the parent/this.
    **/
    public function remove(script:RuleScript) {
        scripts.remove(script);
    }

    /**
     * Inserts a script into the pack, and sets the parent/this of the script.
    **/
    public function insert(pos:Int, script:RuleScript) {
        scripts.insert(pos, script);
        __configureNewScript(script);
    }

    /**
     * Configures a new script.
     * @param script Script to configure
    **/
    private function __configureNewScript(script:RuleScript) {
        if (parent != null) setScriptVar(script, "this", parent);
        // maybe todo: set publicVariables if shared, like, script.variables.set("public", publicVariables);
        for(k=>e in additionalDefaultVariables) setScriptVar(script, k, e);
    }

    public function toString():String {
        return FlxStringUtil.getDebugString([
            LabelValuePair.weak("parent", FlxStringUtil.getClassName(parent, true)),
            LabelValuePair.weak("total", scripts.length),
        ]);
    }
}