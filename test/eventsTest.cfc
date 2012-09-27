component name="eventsTests" extends="mxunit.framework.TestCase" {
  // public void function should_add_listeners() {
  //   var e = new core.emitter();
  //   var events_new_listener_emited = [];
  //   var listeners_new_listener_emited = [];
  //   var times_hello_emited = 0;

  //   e.on('newListener', function(event, listener) {
  //     console.log("newListener");
  //     events_new_listener_emited.add(event);
  //     listeners_new_listener_emited.add(listener);
  //   });

  //   var hello = function(a, b) {
  //     console.log('hello called');
  //     times_hello_emited++;
  //     assertEquals('a', a);
  //     assertEquals('b', b);
  //   }

  //   e.on('hello', hello);

  //   var foo = function() {};
  //   e.once('foo', foo);

  //   console.log('start');

  //   e.emit('hello', 'a', 'b');
        
  //   // just make sure that this doesn't throw:
  //   var f = new core.emitter();
  //   f.setMaxListeners(0);

  //   assertEquals(['hello', 'foo'], events_new_listener_emited);
  //   assertEquals([hello, foo], listeners_new_listener_emited);
  //   assertEquals(1, times_hello_emited);
  // }

  // public void function should_check_listener_leaks() {
  //   var e = new core.emitter();
      
  //   // default
  //   for (var i = 0; i < 10; i++) {
  //     console.log(i);
  //     e.on('default', function() {});
  //   }
  //   assertTrue(!e._events['default'].warned,"e._events['default'].warned = " & e._events['default'].warned);

  //   e.on('default', function() {});
  //   assertTrue(e._events['default'].warned,"e._events['default'].warned = " & e._events['default'].warned);

  //   // specific
  //   e.setMaxListeners(5);
  //   for (var i = 0; i < 5; i++) {
  //     console.log(i);
  //     e.on('specific', function() {});
  //   }

  //   assertTrue(!e._events['specific'].warned,"e._events['specific'].warned = " & e._events['specific'].warned);
  //   e.on('specific', function() {});

  //   assertTrue(e._events['specific'].warned,"e._events['specific'].warned = " & e._events['specific'].warned);
    
  //   // only one
  //   var i = 0;
  //   e.setMaxListeners(1);
  //   e.on('only one', function() {});
  //   console.log(i++);
  //   assertTrue(!e._events['only one'].warned,"e._events['only one'].warned = " & e._events['only one'].warned);
  //   e.on('only one', function() {});
  //   assertTrue(e._events['only one'].warned,"e._events['only one'].warned = " & e._events['only one'].warned);

  //   // unlimited
  //   e.setMaxListeners(0);
  //   for (var i = 0; i <= 1000; i++) {
  //     console.log(i);
  //     e.on('unlimited', function() {});
  //   }
  //   assertTrue(!e._events['unlimited'].warned);
  //   }
    

  // public void function e1_listener_should_work() {
  //   var listener = function() {}
  //   var listener2 = function() {}

  //   var e1 = new core.emitter();
    
  //   e1.on('foo', listener);
  //   var fooListeners = e1.listeners('foo');
  //   assertEquals(e1.listeners('foo'), [listener]);

  //   e1.removeAllListeners('foo');

  //   assertEquals(e1.listeners('foo'), []);
  //   assertEquals(fooListeners, [listener]);
  // }


  // public void function e2_listener_should_work() {
  //   var listener = function() {}
  //   var listener2 = function() {}
  //   var e2 = new core.emitter();
  //   e2.on('foo', listener);
  //   var e2ListenersCopy = duplicate(e2.listeners('foo'));
  //   assertEquals(e2ListenersCopy, [listener]);
  //   assertEquals(e2.listeners('foo'), [listener]);
  //   e2ListenersCopy.add(listener2);
  //   assertEquals(e2.listeners('foo'), [listener]);
  //   assertEquals(e2ListenersCopy, [listener, listener2]);
  // }


  // public void function e3_listener_should_work() {
  //   var listener = function() {}
  //   var listener2 = function() {}
  //   var e3 = new core.emitter();
  //   e3.on('foo', listener);
  //   var e3ListenersCopy = duplicate(e3.listeners('foo'));
  //   e3.on('foo', listener2);
  //   assertEquals(e3.listeners('foo'), [listener, listener2]);
  //   assertEquals(e3ListenersCopy, [listener]);
  // }

  // public void function gotevent_should_be_true() {
  //   var process = new core.emitter();
    
  //   process.on("exit",function(){
  //     console.log("exited");
  //   });
  //   var gotEvent = false;
  //   var e = new core.emitter();
    
  //   process.on("exit",function() {
  //     if(not gotEvent) {
  //       fail("failed");
  //     }
  //   });

  //   e.on('maxListeners', function() {
  //     gotEvent = true;
  //   });

  //   // Should not corrupt the 'maxListeners' queue.
  //   e.setMaxListeners(42);

  //   e.emit('maxListeners');

  //   process.emit("exit");
  // }

  // public void function should_not_have_sideeffects() {
  //   var e = new core.emitter();
  //   var fl = [];  // foo listeners

  //   fl = e.listeners('foo');
  //   assertTrue(isArray(fl));
  //   assertTrue(arrayLen(fl) EQ 0);
  //   assertTrue(!structKeyExists(e,'_events'));

  //   e.on('foo', fail);
    
  //   fl = e.listeners('foo');
  //   assert(structCompare(getMetaData(e._events.foo.arr[1]),getMetaData(fail)));
  //   assert(isArray(fl));
  //   assert(arrayLen(fl) EQ 1);
  //   assert(structCompare(getMetaData(fl[1]),getMetaData(fail)));

  //   e.listeners('bar');
  //   assert(!structKeyExists(e._events,'bar'));

  //   e.on('foo', assert);
    
  //   fl = e.listeners('foo');

  //   assert(isArray(e._events.foo.arr));
  //   assert(arrayLen(e._events.foo.arr) EQ 2);
  //   assert(structCompare(getMetaData(e._events.foo.arr[1]),getMetaData(fail)));
  //   assert(structCompare(getMetaData(e._events.foo.arr[2]),getMetaData(assert)));
    
  //   assert(isArray(fl));
  //   assert(arrayLen(fl) EQ 2);
  //   assert(structCompare(getMetaData(fl[1]),getMetaData(fail)));
  //   assert(structCompare(getMetaData(fl[2]),getMetaData(assert)));
    
  //   console.log('ok');
  // }



  // public void function should_modify_in_emit() {
  //   var callbacks_called = [];

  //   var e = new core.emitter();
    
  //   var callback1 = function() {
  //     var myself = getMetaData(callback1);
  //     console.log("callback1 = #myself.name#");
  //     callbacks_called.add('callback1');
  //     e.on('foo', callback2);
  //     e.on('foo', callback3);
  //     e.removeListener('foo', callback1);
  //   }

  //   var callback2 = function() {
  //     var myself = getMetaData(callback2);
  //     console.log("callback2 = #myself.name#");
  //     callbacks_called.add('callback2');
  //     e.removeListener('foo', callback2);
  //   }

  //   var callback3 = function() {
  //     var myself = getMetaData(callback3);
  //     console.log("callback3 = #myself.name#");
  //     callbacks_called.add('callback3');
  //     e.removeListener('foo', callback3);
  //   }

  //   e.on('foo', callback1);
    
  //   assertEquals(1, arrayLen(e.listeners('foo')));
  //   e.emit('foo');
  //   assertEquals(2, arrayLen(e.listeners('foo')));
  //   assertEquals(['callback1'], callbacks_called);

  //   e.emit('foo');
  //   assertEquals(0, arrayLen(e.listeners('foo')));
  //   assertEquals(['callback1', 'callback2', 'callback3'], callbacks_called);

  //   e.emit('foo');
  //   assertEquals(0, arrayLen(e.listeners('foo')));
  //   assertEquals(['callback1', 'callback2', 'callback3'], callbacks_called);

  //   e.on('foo', callback1);
  //   e.on('foo', callback2);
  //   assertEquals(2, arrayLen(e.listeners('foo')));
  //   e.removeAllListeners('foo');
  //   assertEquals(0, arrayLen(e.listeners('foo')));
    
  //   // Verify that removing callbacks while in emit allows emits to propagate to
  //   // all listeners
  //   callbacks_called = [];

  //   e.on('foo', callback2);
  //   e.on('foo', callback3);
  //   assertEquals(2, arrayLen(e.listeners('foo')));
  //   e.emit('foo');
  //   assertEquals(['callback2', 'callback3'], callbacks_called);
  //   assertEquals(0, arrayLen(e.listeners('foo')));
  // }

  // public void function should_num_args() {
  //   var e = new core.emitter();
  //   var num_args_emited = [];
  //   var process = new core.emitter();

  //   e.on('numArgs', function() {
  //     var numArgs = structCount(arguments);
  //     console.log('numArgs: ' & numArgs);
  //     num_args_emited.add(numArgs);
  //   });

  //   console.log('start');

  //   e.emit('numArgs');
  //   e.emit('numArgs', "");
  //   e.emit('numArgs', "", "");
  //   e.emit('numArgs', "", "", "");
  //   e.emit('numArgs', "", "", "", "");
  //   e.emit('numArgs', "", "", "", "", "");

  //   process.on('exit', function() {
  //     assertEquals([0, 1, 2, 3, 4, 5], num_args_emited);
  //   });
  // }

  // public any function should_test_once() {
  //   var e = new core.emitter();
  //   var times_hello_emited = 0;
  //   var process = new core.emitter();
    
  //   e.once('hello', function(a, b) {
  //     times_hello_emited++;
  //   });

  //   e.emit('hello', 'a', 'b');
  //   e.emit('hello', 'a', 'b');
  //   e.emit('hello', 'a', 'b');
  //   e.emit('hello', 'a', 'b');

  //   var remove = function() {
  //     fail(1, 0, 'once->foo should not be emitted', '!');
  //   };

  //   e.once('foo', remove);
  //   e.removeListener('foo', remove);
  //   e.emit('foo');

  //   process.on('exit', function() {
  //     assertEquals(1, times_hello_emited);
  //   });
  // }

  public void function should_pass_remove_listeners() {
   var count = 0;
   var process = new core.emitter();
    listener1 = function() {
      console.log('listener1');
      count++;
    }

    listener2 = function() {
      console.log('listener2');
      count++;
    }

    listener3 = function() {
      console.log('listener3');
      count++;
    }

    remove1 = function() {
      assert(0);
    }

    remove2 = function() {
      assert(0);
    }

    var e1 = new core.emitter();
    e1.on('hello', listener1);
    e1.on('removeListener',function(name,cb) {
      assertEquals(name, 'hello','#name# = hello');
      assert(structCompare(getMetaData(cb), getMetaData(listener1)), 'cb = listener1');
    });

    e1.removeListener('hello', listener1);
    assertEquals([], e1.listeners('hello'),'[] = #serialize(e1.listeners('hello'))#');

    var e2 = new core.emitter();
    e2.on('hello', listener1);
    e2.on('removeListener', fail);
    e2.removeListener('hello', listener2);
    assertEquals([listener1], e2.listeners('hello'));

    // var e3 = new core.emitter();
    // e3.on('hello', listener1);
    // e3.on('hello', listener2);
    // e3.on('removeListener', function(name,cb) {
    //   assertEquals(name, 'hello');
    //   assertEquals(cb, listener1);
    // });
    // e3.removeListener('hello', listener1);
    // assertEquals([listener2], e3.listeners('hello'));

    // var e4 = new core.emitter();
    // e4.on('removeListener', function(name,cb) {
    //   if (cb !== remove1) return;
    //   this.removeListener('quux', remove2);
    //   this.emit('quux');
    // }, 2);
    // e4.on('quux', remove1);
    // e4.on('quux', remove2);
    // e4.removeListener('quux', remove1);
  }
  
  public void function should_remove_all_listeners() {
    var e1 = new core.emitter();
    e1.on('foo', listener);
    e1.on('bar', listener);
    e1.on('baz', listener);
    e1.on('baz', listener);
    var fooListeners = e1.listeners('foo');
    var barListeners = e1.listeners('bar');
    var bazListeners = e1.listeners('baz');
    e1.on('removeListener', expect(['bar', 'baz', 'baz']));
    e1.removeAllListeners('bar');
    e1.removeAllListeners('baz');
    assertEquals(e1.listeners('foo'), [listener]);
    assertEquals(e1.listeners('bar'), []);
    assertEquals(e1.listeners('baz'), []);
    // after calling removeAllListeners,
    // the old listeners array should stay unchanged
    assertEquals(fooListeners, [listener]);
    assertEquals(barListeners, [listener]);
    assertEquals(bazListeners, [listener, listener]);
    // after calling removeAllListeners,
    // new listeners arrays are different from the old
    assert.notEqual(e1.listeners('bar'), barListeners);
    assert.notEqual(e1.listeners('baz'), bazListeners);

    var e2 = new core.emitter();
    e2.on('foo', listener);
    e2.on('bar', listener);
    // expect LIFO order
    e2.on('removeListener', expect(['foo', 'bar', 'removeListener']));
    e2.on('removeListener', expect(['foo', 'bar']));
    e2.removeAllListeners();
    console.error(e2);
    assertEquals([], e2.listeners('foo'));
    assertEquals([], e2.listeners('bar'));
  }

  public void function setUp() {
    variables.console = new core.console();
    
    console.log("========");
  }
  public void function tearDown() {
     
     console.log("========");
  }

  private any function structCompare(LeftStruct,RightStruct) {
   //WriteDump("aya1.......................", "console");
   var result = true;
   var LeftStructKeys = "";
   var RightStructKeys = "";
   var key = "";
    
   //Make sure both params are structures
   if (NOT (isStruct(LeftStruct) AND isStruct(RightStruct))) return false;
   
   //Make sure both structures have the same keys
   LeftStructKeys = ListSort(StructKeyList(LeftStruct),"TextNoCase","ASC");
   RightStructKeys = ListSort(StructKeyList(RightStruct),"TextNoCase","ASC");
   if(LeftStructKeys neq RightStructKeys) return false;
    
   // Loop through the keys and compare them one at a time
   for (key in LeftStruct) {
    //checking if elements are defined
    if(structKeyExists(LeftStruct,"key") and structKeyExists(RightStruct,"key"))
    {
     //Key is a structure, call structCompare()
     if (isStruct(LeftStruct[key])){
      result = structCompare(LeftStruct[key],RightStruct[key]);
      //WriteDump("aya1.......................", "console");
      if (NOT result) return false;
     //Key is an array, call arrayCompare()
     } else if (isArray(LeftStruct[key])){
      result = arrayCompare(LeftStruct[key],RightStruct[key]);
      //WriteDump("nahi fata..................", "console");
      if (NOT result) return false;
     //Key is a query, call queryCompare()
     } else if (isQuery(LeftStruct[key])){
      result = queryCompare(LeftStruct[key],RightStruct[key]);
      if (NOT result) return false;
     // A simple type comparison here
     } else {
      if(LeftStruct[key] IS NOT RightStruct[key]) return false;
     }
    } else if((structKeyExists(LeftStruct,"key") and (not structKeyExists(RightStruct,"key"))) or ((not structKeyExists(LeftStruct,"key")) and structKeyExists(RightStruct,"key"))) return false;
   }
   return true;
  }

  
  private any function listener() {}
  private any function expect(expected) {
    var actual = [];
    var process = new core.emitter();
    process.on('exit', function() {
      assertEquals(actual.sort(), expected.sort());
    });
    listener = function (name) {
      actual.push(name)
    }
    return common.mustCall(listener, expected.length);
  }
}
