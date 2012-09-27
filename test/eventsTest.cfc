component name="eventsTests" extends="mxunit.framework.TestCase" {
  public void function should_add_listeners() {
    var e = new core.emitter();
    var events_new_listener_emited = [];
    var listeners_new_listener_emited = [];
    var times_hello_emited = 0;

    e.on('newListener', function(event, listener) {
      console.log("newListener");
      events_new_listener_emited.add(event);
      listeners_new_listener_emited.add(listener);
    });

    var hello = function(a, b) {
      console.log('hello called');
      times_hello_emited++;
      assertEquals('a', a);
      assertEquals('b', b);
    }

    e.on('hello', hello);

    var foo = function() {};
    e.once('foo', foo);

    console.log('start');

    e.emit('hello', 'a', 'b');
        
    // just make sure that this doesn't throw:
    var f = new core.emitter();
    f.setMaxListeners(0);

    assertEquals(['hello', 'foo'], events_new_listener_emited);
    assertEquals([hello, foo], listeners_new_listener_emited);
    assertEquals(1, times_hello_emited);
  }

  public void function should_check_listener_leaks() {
    var e = new core.emitter();
      
    // default
    for (var i = 0; i < 10; i++) {
      console.log(i);
      e.on('default', function() {});
    }
    assertTrue(!e._events['default'].warned,"e._events['default'].warned = " & e._events['default'].warned);

    e.on('default', function() {});
    assertTrue(e._events['default'].warned,"e._events['default'].warned = " & e._events['default'].warned);

    // specific
    e.setMaxListeners(5);
    for (var i = 0; i < 5; i++) {
      console.log(i);
      e.on('specific', function() {});
    }

    assertTrue(!e._events['specific'].warned,"e._events['specific'].warned = " & e._events['specific'].warned);
    e.on('specific', function() {});

    assertTrue(e._events['specific'].warned,"e._events['specific'].warned = " & e._events['specific'].warned);
    
    // only one
    var i = 0;
    e.setMaxListeners(1);
    e.on('only one', function() {});
    console.log(i++);
    assertTrue(!e._events['only one'].warned,"e._events['only one'].warned = " & e._events['only one'].warned);
    e.on('only one', function() {});
    assertTrue(e._events['only one'].warned,"e._events['only one'].warned = " & e._events['only one'].warned);

    // unlimited
    e.setMaxListeners(0);
    for (var i = 0; i <= 1000; i++) {
      console.log(i);
      e.on('unlimited', function() {});
    }
    assertTrue(!e._events['unlimited'].warned);
    }
    

  public void function e1_listener_should_work() {
    var listener = function() {}
    var listener2 = function() {}

    var e1 = new core.emitter();
    
    e1.on('foo', listener);
    var fooListeners = e1.listeners('foo');
    assertEquals(e1.listeners('foo'), [listener]);

    e1.removeAllListeners('foo');

    assertEquals(e1.listeners('foo'), []);
    assertEquals(fooListeners, [listener]);
  }


  public void function e2_listener_should_work() {
    var listener = function() {}
    var listener2 = function() {}
    var e2 = new core.emitter();
    e2.on('foo', listener);
    var e2ListenersCopy = duplicate(e2.listeners('foo'));
    assertEquals(e2ListenersCopy, [listener]);
    assertEquals(e2.listeners('foo'), [listener]);
    e2ListenersCopy.add(listener2);
    assertEquals(e2.listeners('foo'), [listener]);
    assertEquals(e2ListenersCopy, [listener, listener2]);
  }


  public void function e3_listener_should_work() {
    var listener = function() {}
    var listener2 = function() {}
    var e3 = new core.emitter();
    e3.on('foo', listener);
    var e3ListenersCopy = duplicate(e3.listeners('foo'));
    e3.on('foo', listener2);
    assertEquals(e3.listeners('foo'), [listener, listener2]);
    assertEquals(e3ListenersCopy, [listener]);
  }

  public void function setUp() {
    variables.console = new core.console();
    
     console.log("========");
  }
  public void function tearDown() {
     console.log("========");
  }

  public void function gotevent_should_be_true() {

    var gotEvent = false;

    thread name="assertIt" action="sleep" duration="50" {
      assertTrue(gotEvent);
    };

    var e = new core.emitter();

    e.on('maxListeners', function() {
      gotEvent = true;
    });

    // Should not corrupt the 'maxListeners' queue.
    e.setMaxListeners(42);

    e.emit('maxListeners');
  }
}
