component name="eventsTests" extends="mxunit.framework.TestCase" {
	public void function should_work() {
	    var e = new core.emitter();
	    variables.console = new core.console();
	    
	    // default
		for (var i = 1; i <= 10; i++) {
		  e.on('default', function() {});
		}

		assertTrue(!e._events['default'].warned,"e._events['default'].warned = " & e._events['default'].warned);
		
		e.on('default', function() {});

		assertTrue(e._events['default'].warned,"e._events['default'].warned = " & e._events['default'].warned);

		// specific
		e.setMaxListeners(5);
		for (var i = 0; i < 5; i++) {
		  e.on('specific', function() {});
		}

		assertTrue(!e._events['specific'].warned,"e._events['specific'].warned = " & e._events['specific'].warned);
		e.on('specific', function() {});
		assertTrue(e._events['specific'].warned,"e._events['specific'].warned = " & e._events['specific'].warned);

		// only one
		e.setMaxListeners(1);
		e.on('only one', function() {});
		assertTrue(!e._events['only one'].warned);
		e.on('only one', function() {});
		assertTrue(e._events['only one'].warned);

		// unlimited
		e.setMaxListeners(0);
		for (var i = 0; i < 1000; i++) {
		  e.on('unlimited', function() {});
		}
		assertTrue(!e._events['unlimited'].warned);
	  }
}
