package backend.utils;

import rulescript.RuleScript;

class ScriptUtils {
    public static function callScriptMethod(script:RuleScript, methodName:String, warnOnFail:Bool = false):Dynamic{
        var method = getScriptVar(script, methodName, warnOnFail);
        if (method != null) return method();
        if (warnOnFail) trace('Could not call method: $methodName');
        return null;
    }

    public static function getScriptVar(script:RuleScript, variableName:String, warnOnFail:Bool = false):Dynamic {
        if (script == null){
            if (warnOnFail) trace('Could not call method $variableName on a null script.');
            return null;
        }
        if (script.variables.exists(variableName))
            return script.variables.get(variableName);
        if (warnOnFail) trace('Could not find variable: ' + variableName);
        return null;
    }

    public static function setScriptVar(script:RuleScript, variableName:String, value:Dynamic):Int {
        if (script == null) return 1;
        script.variables.set(variableName, value);
        return 0;
    }
}