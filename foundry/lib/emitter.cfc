component name="emitter" extends="foundry.lib.module" {
	property name="maxListeners" type="numeric";

	//variables.domain = {};
	include "../core/util.cfm";
	include "../core/console.cfm";
	
	public any function init() {
		// By default EventEmitters will print a warning if more than
		// 10 listeners are added to it. This is a useful default which
		// helps finding memory leaks.
		//
		// Obviously not all Emitters should be limited to 10. This function allows
		// that to be increased. Set to zero for unlimited.
		variables.defaultMaxListeners = 10;
		this.maxListeners = variables.defaultMaxListeners;

		// if (this.usingDomains) {
		//   // if there is an active domain, then attach to it.
		//   domain = domain || require('domain');

		//   if (domain.active && !(IsInstanceOf(this,"domain.Domain")) {
		//     this.domain = domain.active;
		//   }
		// }

		return this;
	}

	public any function setMaxListeners(n) {
	  if(!structKeyExists(this,'_events')) this['_events'] = {};
	  this._maxListeners = n;
	};

	public any function emit() {
		var type = arguments[1];
		//	If there is no 'error' event listener then throw.
		if (type EQ 'error') {
			if (!structKeyExists(this,'_events') || !structKeyExists(this._events,'error') || (_.isArray(this._events.error) && !arrayLen(this._events.error)))
			{
				//Maybe we can use the "domain" logic for "application" scoped events?
				// if (this.domain) {
				//   var er = arguments[1];
				//   er.domain_emitter = this;
				//   er.domain = this.domain;
				//   er.domain_thrown = false;
				//   this.domain.emit('error', er);
				//   return false;
				// }

			if (structKeyExists(arguments,1)) {
				//throw (""); // Unhandled 'error' event
			} else {
				throw("Uncaught, unspecified 'error' event.");
			}

			return false;
			}
		}

	  if (!structKeyExists(this,'_events')) return false;

	  if(!structKeyExists(this._events,type)) return console.error("No event type [#type#] bound.");
	  var handler = this._events[type];

	  if (!isDefined("handler") AND !_.isFunction(handler)) return false;
	  //IS HANDLER A FUNCTION?
	  if (_.isFunction(handler)) {
	    // if (this.domain) {
	    //   this.domain.enter();
	    // }

	    switch (structCount(arguments)) {
	      // fast cases
	      case 1:
	        handler();
	        break;
	      case 2:
	        handler(arguments[2]);
	        break;
	      case 3:
	        handler(arguments[2], arguments[3]);
	        break;
	      // slower
	      default:
	        var l = structCount(arguments);
	        var args = new Array(l - 1);
	        for (var i = 1; i < l; i++) args[i - 1] = arguments[i];
	        handler(argumentCollection=args);
	    }

	    // if (this.domain) {
	    //   this.domain.exit();
	    // }
	    return true;

	  //IS HANDLER AN ARRAY?
	  } else if (_.isArray(handler.arr)) {
	    // if (this.domain) {
	    //   this.domain.enter();
	    // }
	    
	    var argLen = structCount(arguments);
	    var listeners = handler.arr;

	    listenerLen = arrayLen(listeners);
	    args = structCopy(arguments);
	    structDelete(args,1);
	    for (var i = 1; i <= listenerLen; i++) {
	    	//seems dumb that you have to convert it to 
	    	//a simple var to use the closure...
	    	//possible Railo 4.0.0.013 bug?
	    	var func = listeners[i];
	    	func(argumentCollection=args);
	    }

	    // if (this.domain) {
	    //   this.domain.exit();
	    // }
	    return true;

	  //HANDLER IS NOTHING...
	  } else {
	    return false;
	  }
	};

	public any function addListener(type, listener) {
	  if (!_.isFunction(listener)) {
	    throw ('addListener only accepts a function');
	  }

	  if(!structKeyExists(this,'_events')) this['_events'] = {};
		// To avoid recursion in the case that type == "newListeners"! Before
		// adding it to the listeners, first emit "newListeners".
	  if (structKeyExists(this._events,"newListener")) {
	    this.emit('newListener', type, (structKeyExists(listener,'listener') && _.isFunction(listener.listener)) ?
	              listener.listener : listener);
	  }

	  if (!structKeyExists(this._events,type)) {
	  	this._events[type] = new Event(type);
	  	this._events[type].add(listener);
	  } else {
	    this._events[type].add(listener);
	  }

	  // Check for listener leak
	  if (_.isArray(this._events[type].arr) && !this._events[type].warned) {
	    var m = 0;
	    
	    if (structKeyExists(this,"_maxListeners")) {
	      m = this._maxListeners;
	    } else {
	      m = defaultMaxListeners;
	    }
	    
	    if (m > 0 && this._events[type].length() > m) {
	      this._events[type].warned = true;
	      console.error('(foundry) warning: possible EventEmitter memory ' &
	                    'leak detected. %d listeners added. ' &
	                    'Use emitter.setMaxListeners() to increase limit.',
	                    this._events[type].length);
	      //console.trace();
	    }
	  }

	  return this;
	};

	public any function on(type, listener) {
		this.addListener(argumentCollection=arguments);
	}

	public any function once(type, listener) {
	  if (!_.isFunction(listener)) {
	    throw('.once() only accepts a function');
	  }

	  var self = this;
	  var listnr = arguments.listener;
	  var args = structCopy(arguments);
	  
	  var g = function() {
	    self.removeListener(type, g);
	    listnr(argumentCollection=args);
	  };

	  //g.listener = listener;
	  self.on(type, g);

	  return this;
	};

	// emits a 'removeListener' event iff the listener was removed
	public any function removeListener(type, listener) {
	  if (!_.isFunction(listener)) {
	    throw ('removeListener only accepts a function');
	  }

	  // does not use listeners(), so no side effect of creating _events[type]
	  if (!structKeyExists(this,'_events') || !structKeyExists(this._events,type)) return this;
		var list = this._events[type];
		
		if (isArray(list.arr)) {
		    var position = 0;
			var length = list.length();
		    for (var i = 1; i <= length; i++) {
		    	var listItem = list.arr[i];
				var listMetaData = getMetaData(listItem);
				var listenerMetaData = getMetaData(listener);

				if ((listMetaData.name EQ listenerMetaData.name) || (structKeyExists(listItem,'listener') AND listItem.listener EQ listener)) {
					position = i;
					break;
				}
		    }

	    	if (position < 0) return this;
	    	var removedItem = list.splice(position,1).arr[1];
	    	
	    	if (arrayLen(list.arr) EQ 0) {
				structDelete(this._events,type);

				if (structKeyExists(this._events,'removeListener')) {
					this.emit('removeListener', type, listener);
				}
			}
		} else if (list EQ listener || (list.listener && list.listener EQ listener)) {
			structDelete(this._events,type);

			if (structKeyExists(this._events,'removeListener')) {
				this.emit('removeListener', type, listener);
			}
		}

	  return this;
	};

	public any function removeAllListeners(type) {
	  if (!structKeyExists(this,'_events')) return this;

	  // fast path
	  if (!structKeyExists(this._events,'removeListener')) {
	    if (structCount(arguments) EQ 0) {
	      this._events = {};
	    } else if (structKeyExists(arguments,'type') && structKeyExists(this,'_events') && structKeyExists(this._events,type)) {
	      structDelete(this._events,type);
	    }
	    return this;
	  }

	  // slow(ish) path, emit 'removeListener' events for all removals
	  if (structCount(arguments) EQ 0) {
	    for (var key in this._events) {
	      if (key EQ 'removeListener') continue;
	      this.removeAllListeners(key);
	    }
	    this.removeAllListeners('removeListener');
	    this._events = {};
	    return this;
	  }

	  var listeners = this._events[type].arr;
	  if (isArray(listeners)) {
	    while (listeners.length) {
	      // LIFO order
	      this.removeListener(type, listeners[listeners.length - 1]);
	    }
	  } else if (listeners) {
	    this.removeListener(type, listeners);
	  }
	  this._events[type] = null;

	  return this;
	};

	public any function listeners(type) {
	  if (!structKeyExists(this,'_events') || !structKeyExists(this._events,type)) return [];
	  if (!_.isArray(this._events[type].arr)) {
	    return new Event(this._events[type]).arr;
	  }
	  return this._events[type].arr;
	};
	//udf from cflib
	function structCompare(LeftStruct,RightStruct) {
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
}