package backend.utils;

import rulescript.RuleScript;

/**
 * Utilities for scripting-related stuff.
 */
class ScriptUtils
{
    /**
     * Calls a method on a script, also giving out warnings on the console if fails.
     * @param script The script.
     * @param methodName The name of the method.
     * @param warnOnFail Whether or not should it warn on the console if failed.
     */
    public static function callScriptMethod(script:RuleScript, methodName:String, warnOnFail:Bool = false):Dynamic{
        var method = getScriptVar(script, methodName, warnOnFail);
        if (method != null) return method();
        if (warnOnFail) trace('Could not call method: $methodName');
        return null;
    }

    /**
     * Returns a variable from a script, giving out warnings on the console if fails.
     * @param script The script.
     * @param variableName The name of the variable.
     * @param warnOnFail Whether or not should it warn on the console if failed.
     * @return script variable
     */
    public static function getScriptVar(script:RuleScript, variableName:String, warnOnFail:Bool = false):Dynamic {
        if (script == null){
            if (warnOnFail) trace('Could not call method $variableName on a null script.');
            return null;
        }
        if (script.variables.exists(variableName))
            return script.variables.get(variableName);
        if (warnOnFail) trace('Could not find variable: $variableName');
        return null;
    }

    /**
     * Sets a variable on a script.
     * @param script The script.
     * @param variableName The name of the variable.
     * @param value The value that'll be applied on it.
     */
    public static function setScriptVar(script:RuleScript, variableName:String, value:Dynamic):Int {
        if (script == null) return 1;
        script.variables.set(variableName, value);
        return 0;
    }
}