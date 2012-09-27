component name="eventsTests" extends="mxunit.framework.TestCase" {
	public void function e1_should_work() {
	    variables.console = new core.console();
	    
	    listener = function() {}
		listener2 = function() {}

		var e1 = new core.emitter();
		e1.on('foo', listener);
		var fooListeners = e1.listeners('foo');
		assertEquals(e1.listeners('foo').arr, [listener]);

		e1.removeAllListeners('foo');

		assertEquals(e1.listeners('foo').arr, []);
		assertEquals(fooListeners.arr, [listener]);
	}
public void function e2_should_work() {
	  
	    listener = function() {}
		listener2 = function() {}
		var e2 = new core.emitter();
		e2.on('foo', listener);
		var e2ListenersCopy = duplicate(e2.listeners('foo'));
		assertEquals(e2ListenersCopy.arr, [listener]);
		assertEquals(e2.listeners('foo').arr, [listener]);
		e2ListenersCopy.add(listener2);
		assertEquals(e2.listeners('foo').arr, [listener]);
		assertEquals(e2ListenersCopy.arr, [listener, listener2]);
}
public void function e3_should_work() {
	    listener = function() {}
		listener2 = function() {}
		var e3 = new core.emitter();
		e3.on('foo', listener);
		var e3ListenersCopy = duplicate(e3.listeners('foo'));
		e3.on('foo', listener2);
		assertEquals(e3.listeners('foo').arr, [listener, listener2]);
		assertEquals(e3ListenersCopy.arr, [listener]);
	}
}
