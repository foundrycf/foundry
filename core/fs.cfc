component name="fs" {
	variables.console = new Console();

	public any function exists(p,cb) {
		if(fileExists(arguments.p)) {
			exists = true;
		} else {
			exists = false;
		}

		cb(exists);
	}

	public any function readFile(p,charset = 'utf8',cb) {
		var err = {};
		var contents = "";
		try {
			contents = fileRead(p);
		} catch(any err) {
			cb(err, contents);
			return false;
		}

		cb(err, contents);
	}

	public any function mkdir(path, mode = 0777, cb) {
		var _ = new util();
  		if(_.isFunction(mode)) cb = mode;
  		
  		try{
  			console.log(path.resolve(expandPath('/'), path));
  			directoryCreate(path.resolve(expandPath('/'), path));
  		} catch(any err) {
  			cb(err);
  			return false;
  		}

  	    cb(err, contents);
	}

	// Ensure that callbacks run in the global context. Only use this function
	// for callbacks that are passed to the binding layer, callbacks that are
	// invoked from JS already run in the proper scope.
	private any function makeCallback(cb) {
		if (!isFunction(cb)) {
		    // faster than returning a ref to a global no-op function
		    return function() {};
		}

		return function() {
			return cb.apply(null, arguments);
		};
	}

	public any function stat(path, cb) {
		try {
			getFileInfo(path.resolve(expandPath('/'), path));
		} catch(any err) {
			cb(err, contents);
			return false;
		}

		cb(err, contents);
	}

	public any function statSync(path) {
		return stat(path);
	}
}