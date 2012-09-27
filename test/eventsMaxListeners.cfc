component name="testAddListeners" extends="mxunit.framework.TestCase" {
  public void function should_work() {

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
