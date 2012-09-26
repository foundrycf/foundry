component name="testAddListeners" extends="mxunit.framework.TestCase" {
	var common = require('../common');
	var assert = require('assert');
	var events = require('events');

	var gotEvent = false;

	process.on('exit', function() {
	  assert(gotEvent);
	});

	var e = new events.EventEmitter();

	e.on('maxListeners', function() {
	  gotEvent = true;
	});

	// Should not corrupt the 'maxListeners' queue.
	e.setMaxListeners(42);

	e.emit('maxListeners');

}
