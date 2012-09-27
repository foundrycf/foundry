component name="testAddListeners" extends="mxunit.framework.TestCase" {
	public void function should_work() {
		var callbacks_called = [];

		var e = new core.emitter();

		callback1 = function() {
		  callbacks_called.push('callback1');
		  e.on('foo', callback2);
		  e.on('foo', callback3);
		  e.removeListener('foo', callback1);
		}

		callback2 = function() {
		  callbacks_called.push('callback2');
		  e.removeListener('foo', callback2);
		}

		callback3 = function() {
		  callbacks_called.push('callback3');
		  e.removeListener('foo', callback3);
		}

		e.on('foo', callback1);
		assertEquals(1, e.listeners('foo').length());

		e.emit('foo');
		assertEquals(2, e.listeners('foo').length());
		assert.deepEqual(['callback1'], callbacks_called);

		e.emit('foo');
		assertEquals(0, e.listeners('foo').length());
		assert.deepEqual(['callback1', 'callback2', 'callback3'], callbacks_called);

		e.emit('foo');
		assertEquals(0, e.listeners('foo').length());
		assert.deepEqual(['callback1', 'callback2', 'callback3'], callbacks_called);

		e.on('foo', callback1);
		e.on('foo', callback2);
		assertEquals(2, e.listeners('foo').length());
		e.removeAllListeners('foo');
		assertEquals(0, e.listeners('foo').length());

		// Verify that removing callbacks while in emit allows emits to propagate to
		// all listeners
		callbacks_called = [];

		e.on('foo', callback2);
		e.on('foo', callback3);
		assertEquals(2, e.listeners('foo').length());
		e.emit('foo');
		assert.deepEqual(['callback2', 'callback3'], callbacks_called);
		assertEquals(0, e.listeners('foo').length());
	}
	

}
