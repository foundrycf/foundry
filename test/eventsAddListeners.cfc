component name="eventsTests" extends="mxunit.framework.TestCase" {
  public void function should_work() {
    var e = new core.events();
    variables.console = new core.console();
    var events_new_listener_emited = [];
    var listeners_new_listener_emited = [];
    var times_hello_emited = 0;

    e.on('newListener', function(event, listener) {
      console.log("newListener");
      events_new_listener_emited.add(event);
      listeners_new_listener_emited.add(listener);
    });

    hello = function(a, b) {
      console.log('hello');
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
    var f = new core.events();
    f.setMaxListeners(0);

    assertEquals(['hello', 'foo'], events_new_listener_emited);
    assertEquals([hello, foo], listeners_new_listener_emited);
    assertEquals(1, times_hello_emited);
  }
  
}
