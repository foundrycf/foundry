component name="events" {
	// Bind one or more space separated events, events, to a callback function. Passing "all" will bind the callback to all events fired.
	this['on'] = function(required string eventName, callback, context = {}) {
		if (!_.has(arguments, 'callback')) return this;

			// init _callbacks
			if (!_.has(this, '_callbacks')) {
				this._callbacks = {};
			}

			// handle multiple events
			var events = listToArray(eventName, " ");

			for (eventName in events) {
				if (!_.has(this._callbacks, eventName))
				this._callbacks[eventName] = [];

				var event = {
				callback: callback,
				ctx: function () { return context; }
			};

			ArrayAppend(this._callbacks[eventName], event);
		}

		return this;
	}

	// Remove one or many callbacks. If context is null, removes all callbacks with that function. If callback is null, removes all callbacks for the event. If events is null, removes all bound callbacks for all events.
	this['off'] = function(string eventName, callback, struct context) {

		// no callbacks defined
		if (!_.has(this, '_callbacks')) return this;

		// no arguments, delete all callbacks for this object
		if (!(_.has(arguments, 'eventName') || _.has(arguments, 'callback') || _.has(arguments, 'context'))) {
			structDelete(this, '_callbacks');
			return this;
		}

		// handle multiple events
		var events = _.has(arguments, 'eventName') ? listToArray(eventName, " ") : [];
		for (eventName in events) {
			if (_.has(this._callbacks, eventName)) {
				if (_.has(arguments, 'callback')) {
					// remove specific callback for event
					var args = arguments;
					var result = _.reject(this._callbacks[eventName], function (event) {
						if (_.has(args, 'context')) {
							var ctx = event.ctx();
							return event.callback.Equals(callback) && ctx.Equals(context);
						}
						else {
							return event.callback.Equals(callback);
						}
					});
					this._callbacks[eventName] = result;
				}
				else {
					// remove all callbacks for event
					structDelete(this._callbacks, eventName);
				}
			}
		}

		// remove all callbacks for context
		if (arrayLen(events) == 0 && _.has(arguments, 'context')) {
			var con = arguments.context;
			var result = _.map(this._callbacks, function(events) {
				return _.reject(events, function (event) {
					var ctx = event.ctx();
					return ctx.equals(con);
				});
			});
			this._callbacks = result;
		}

		// remove all matching callbacks
		if (arrayLen(events) == 0 && _.has(arguments, 'callback')) {
			var cb = arguments.callback;
			var result = _.map(this._callbacks, function(events) {
				return _.reject(events, function (event) {
					var callback = event.callback;
					return callback.equals(cb);
				});
			});
			this._callbacks = result;
		}

		return this;
	}

	// Trigger one or many events, firing all bound callbacks. Callbacks are passed the same arguments as trigger is, apart from the event name (unless you're listening on "all", which will cause your callback to receive the true name of the event as the first argument).
	this['trigger'] = function(required string eventName, struct model = this, val = '', struct changedAttributes = {}) {

		// no callbacks defined
		if (!_.has(this, '_callbacks')) return this;

		// handle multiple events
		var events = listToArray(eventName, " ");

		for (eventName in events) {
			var callbacks = duplicate(this._callbacks);

			if (_.has(callbacks, eventName) && eventName != 'all') {
				var evts = callbacks[eventName];
				_.each(evts, function (event) {
					var func = _.bind(event.callback, event.ctx());
					func(model, val, changedAttributes);
				});
			}
			if (_.has(callbacks, 'all') && eventName != 'all') {
				var evts = callbacks['all'];
				_.each(evts, function (event) {
					var func = _.bind(event.callback, event.ctx());
					func(eventName, model, val, changedAttributes);
				});
			}
		}

		return this;
	}
}