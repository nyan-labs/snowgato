package core;

import flixel.util.FlxSignal.FlxTypedSignal;

typedef EventName = String;
typedef EventDetails<T> = {
  value: T,
};
typedef EventSignalFunc<T> = EventDetails<T>->Void;

// todo: add events for spriteExt, but prob do like ass.on(event, func() {}) or ass.onevent.add(func() {})  (do enum for `event`)

class EventEmitter<T> {
  var event_signal: FlxTypedSignal<EventSignalFunc<T>>;
  public function new(event_name: EventName) {
    event_signal = new FlxTypedSignal<EventSignalFunc<T>>();
  } 

  public inline function dispatch(value: T) {
    event_signal.dispatch({
      value: value
    });
  }

  public inline function add(listener: EventSignalFunc<T>) {
    event_signal.add(listener);
  }

	public inline function add_once(listener: EventSignalFunc<T>) {
    event_signal.addOnce(listener);
  }
  
  public inline function remove(listener: EventSignalFunc<T>) {
    event_signal.remove(listener);
  }
  
  public inline function has(listener: EventSignalFunc<T>) {
    return event_signal.has(listener);
  }
  
  public inline function remove_all() {
    event_signal.removeAll();
  }
  
  public inline function destroy() {
    event_signal.destroy();
  }
  
}

