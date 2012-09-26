component name="testAddListeners" extends="mxunit.framework.TestCase" {
	var EventEmitter = require('events').EventEmitter;
	var assert = require('assert');

	var e = new EventEmitter;
	var fl;  // foo listeners

	fl = e.listeners('foo');
	assert(Array.isArray(fl));
	assert(fl.length === 0);
	assert(typeof e._events == 'undefined');

	e.on('foo', assert.fail);
	fl = e.listeners('foo');
	assert(e._events.foo === assert.fail);
	assert(Array.isArray(fl));
	assert(fl.length === 1);
	assert(fl[0] === assert.fail);

	e.listeners('bar');
	assert(!e._events.hasOwnProperty('bar'));

	e.on('foo', assert.ok);
	fl = e.listeners('foo');

	assert(Array.isArray(e._events.foo));
	assert(e._events.foo.length === 2);
	assert(e._events.foo[0] === assert.fail);
	assert(e._events.foo[1] === assert.ok);

	assert(Array.isArray(fl));
	assert(fl.length === 2);
	assert(fl[0] === assert.fail);
	assert(fl[1] === assert.ok);

	console.log('ok');

}
