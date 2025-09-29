// Credits to the Codename Crew for the original scripting and event system concepts,
// which have been adapted here for use with RuleScript.
// https://github.com/CodenameCrew/CodenameEngine/blob/main/source/funkin/backend/scripting/EventManager.hx

package backend.scripting;

import backend.scripting.events.*;
import flixel.FlxState;

final class EventManager {
    // map doesn't work for that
    public static var eventValues:Array<DeltaEvent> = [];
    public static var eventKeys:Array<Class<DeltaEvent>> = [];

    public static function get<T:DeltaEvent>(cl:Class<T>):T {
        var c:Class<DeltaEvent> = cast cl;

        var index = eventKeys.indexOf(c);
        if (index < 0) {
            eventKeys.push(c);
            var ret;
            eventValues.push(ret = Type.createInstance(c, []));
            return cast ret;
        }

        return cast eventValues[index];
    }

    public static function reset() {
        for(v in eventValues)
            v.destroy();
        eventValues = [];
        eventKeys = [];
    }

    public static function init() {
        FlxG.signals.preStateCreate.add(onStateSwitch);  //TODO: Adapt to Deltarune's state/room switch if needed
    }

    private static inline function onStateSwitch(newState:FlxState)
        reset();
}