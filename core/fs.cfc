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

	public any function mkdir(p, mode = 0777, cb) {
		var _ = new util();
		var path = new path();
  		if(_.isFunction(mode)) cb = mode;
  		
  		try{
  			directoryCreate(path.resolve(expandPath('/'), p));
  		} catch(any err) {
  			cb(err);
  			return false;
  		}
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

	public any function stat(p, cb) {
		var path = new path();
		var err = {};
		var contents = {};

		try {
			currisDir = false;
			currIsFile = false;
			fileSize = 0;
			modePerms = '';
			tmpContents = getFileInfo(path.resolve(expandPath('/'), p));

			if(tmpContents.canRead && tmpContents.canWrite) {
				modePerms = 'rw';
			} else if(tmpContents.canRead && !tmpContents.canWrite) {
				modePerms = 'r';
			} else if(tmpContents.canRead && tmpContents.canWrite) {
				modePerms = 'w';
			} else {
				modePerms = '';
			}

			if(tmpContents.type EQ 'file') {
				fileSize = createObject("java","java.io.File").init(path.resolve(expandPath('/'), p)).length();
			}

			contents = {
				isFile: (tmpContents.type EQ 'file') ? true : false,
				isDirectory: (tmpContents.type EQ 'directory') ? true : false,
				mode: modePerms,
				size: fileSize
			};

		} catch(any err) {
			cb(err);
		}
		
		cb(err, contents);
	}

	public any function statSync(path) {
		return stat(path);
	}

	public any function createWriteStream(path) {
		var File = createObject("java","java.io.File").init(path);
		var FileWriter = createObject("java","java.io.FileWriter").init(File);
	}
}