# Emitter

<!--type=module-->

<!--Many objects in Node emit events: a `net.Server` emits an event each time
a peer connects to it, a `fs.readStream` emits an event when the file is
opened. All objects which emit events are instances of `events.EventEmitter`.-->

One thing you rarely hear about in ColdFusion really is events.  Not because it's not possible, but because for the most part, events happen in the background and you don't really need them to write CF web apps.  We wanted to change that with the `event` class and `emitter` component.
It's a work in progress and may or may not truly reflect real event driven development at these early stages.  We plan to use thread's to somehow make a nice clean async interface for defining and triggering events.

You can access this module by doing: `new foundry.core.emitter()` or `require("events");` if you're extending `foundry.core`

Typically, event names are represented by a camel-cased string, however,
there aren't any strict restrictions on that, as any string will be accepted.

Functions can then be attached to objects, to be executed when an event
is emitted. These functions are called _listeners_.


## Class: Emitter

To access the Emitter class, `require('emitter')`.

When an `Emitter` instance experiences an error, the typical action is
to emit an `'error'` event.  Error events are treated as a special case in Foundry.
If there is no listener for it, then the default action is to print a stack
trace and throw the request.

All Emitters emit the event `'newListener'` when new listeners are
added and `'removeListener'` when a listener is removed.

### emitter.addListener(event, listener)
### emitter.on(event, listener)

Adds a listener to the end of the listeners array for the specified event.

    obj.on('connection', function (stream) {
      console.log('someone connected!');
    });

### emitter.once(event, listener)

Adds a **one time** listener for the event. This listener is
invoked only the next time the event is fired, after which
it is removed.

    obj.once('connection', function (stream) {
      console.log('Ah, we have our first user!');
    });

### emitter.removeListener(event, listener)

Remove a listener from the listener array for the specified event.
**Caution**: changes array indices in the listener array behind the listener.

    var callback = function(stream) {
      console.log('someone connected!');
    };
    obj.on('connection', callback);
    // ...
    obj.removeListener('connection', callback);


### emitter.removeAllListeners([event])

Removes all listeners, or those of the specified event.


### emitter.setMaxListeners(n)

By default Emitters will print a warning if more than 10 listeners are
added for a particular event. This is a useful default which helps finding memory leaks.
Obviously not all Emitters should be limited to 10. This function allows
that to be increased. Set to zero for unlimited.


### emitter.listeners(event)

Returns an array of listeners for the specified event.

    obj.on('connection', function (stream) {
      console.log('someone connected!');
    });
    //following requires the foundry.core.console() module
    console.log(util.inspect(obj.listeners('connection'))); // [ [Function] ]


### emitter.emit(event, [arg1], [arg2], [...])

Execute each of the listeners in order with the supplied arguments.

### Event: 'newListener'

* `event` {String} The event name
* `listener` {Function} The event handler function

This event is emitted any time someone adds a new listener.
