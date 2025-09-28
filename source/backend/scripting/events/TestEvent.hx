package backend.scripting.events;

final class TestEvent extends DeltaEvent {
    public var coolVal:String = "What the heck?! A cool value?!";

    override public function toString():String
        return 'No, you must- $coolVal';
}