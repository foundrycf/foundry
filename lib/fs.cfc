component name="fs" {
	public any function init() {
		// variables._ = new Util();
		// variables.path = new Path();
		variables.futil = createObject("java","org.apache.commons.io.FileUtils");

		return this;
	}

	public any function exists(p,cb) {
		if(fileExists(arguments.p)) {
			exists = true;
		} else {
			exists = false;
		}

		cb(exists);
	}

	public any function existsSync(p) {
		if(fileExists(arguments.p)) {
			return true;
		}

		return false;
	}

	public any function readFile(p,charset = 'utf8',cb) {
		var contents = "";
		try {
			contents = fileRead(p);
		} catch(any errs) {
			cb(errs, contents);
			return false;
		}

		cb(errs, contents);
	}

	public any function mkdir(p, mode = 0777, cb) {
		var _ = new util();
		var path = new path();

  		if(_.isFunction(mode)) cb = mode;
  		
  		try{
  			dirPath = path.resolve(expandPath('/'), p);
  			directoryCreate(dirPath);
  			FileSetAccessMode(path.resolve(expandPath('/'), p), mode);
  		} catch(any errs) {
  			cb(errs);
  			return false;
  		}

  		cb({});
	}

	public any function rmdir(path,callback) {
		thread name="foundry-rmdir-#createUUID#" action="run" p=arguments.path cb=arguments.callback {
			deleteDirectory(path);
			makeCallback(callback);
		}
	}

	public any function rmdirSync(path,callback) {
		deleteDirectory(path);
	}

	// Ensure that callbacks run in the global context. Only use this function
	// for callbacks that are passed to the binding layer, callbacks that are
	// invoked from JS already run in the proper scope.
	private any function makeCallback(cb) {
		var _ = new util().init();

		if (!_.isFunction(cb)) {
		    // faster than returning a ref to a global no-op function
		    return function() {};
		}

		return function() {
			return cb(argumentCollection=arguments);
		};
	}

	private any function modeNum(m, def) {
		var _ = new util().init();

		if(isNumeric(m)) {
			return m;
		} else if(_.isString(m)) {
			return FormatBaseN(LSParseNumber(mode), 8);
		} else {
			if(def) {
				return modeNum(def);
			} else {
				return 'undefined';
			}
		}
	}

	public any function open(p, flags, mode, callback) {
		callback = makeCallback(callback);
		//mode = modeNum(mode, '438 /*=0666*/');
		path = new path();
		openedFile = fileOpen(path.resolve(expandPath('/'), p), 'readwrite');
		
		callback("", openedFile);
	}

	public any function stat(p, cb) {
		var path = new path();
		var errs = {};
		var contents = {
				isFile: false,
				isDirectory: false,
				mode: '',
				size: 0 };

		try {
			tmpContents = getFileInfo(path.resolve(expandPath('/'), p));

			if(tmpContents.canRead && tmpContents.canWrite) {
				contents.mode = 'rw';
			} else if(tmpContents.canRead && !tmpContents.canWrite) {
				contents.mode = 'r';
			} else if(tmpContents.canRead && tmpContents.canWrite) {
				contents.mode = 'w';
			} else {
				contents.mode = '';
			}

			if(tmpContents.type EQ 'file') {
				contents.size = createObject("java","java.io.File").init(path.resolve(expandPath('/'), p)).length();
			}

			contents.isFile = (tmpContents.type EQ 'file') ? true : false;
			contents.isDirectory = (tmpContents.type EQ 'directory') ? true : false;

		} catch(any err) {
			cb(err, contents);
			return false;
		}
		
		cb(errs, contents);
	}

	public any function statSync(path) {
		return stat(path);
	}

	// public any function writeAll(fd, buffer, offset, length, position, cb) {
	// 	var _ = new util().init();
	// 	var noop = function() {};
	// 	var callback_ = (_.isFunction(cb)) ? cb : noop;

	// 	fs.write(fd, buffer, offset, length, position, function(writeErr, written) {
	// 		if (structKeyExists(arguments, 'writeErr')) {
	// 			fs.close(fd, function() {
	// 				if (_.isEmpty(callback_)) callback_(writeErr);
	// 			});

	// 		} else {
	// 			if (structKeyExists(arguments, 'written') && written === length) {
	// 				fs.close(fd, callback);
	
	// 			} else {
	// 				offset += written;
	// 				length -= written;
	// 				position += written;
					
	// 				writeAll(fd, buffer, offset, length, position, callback);
	// 			}
	// 		}
	// 	});
	// }

	public any function writeFile(p, data, encoding_, cb) {
		var _ = new util().init();
		var path = new path();
  		var encoding = (structKeyExists(arguments,'encoding_') && _.isString(encoding_)) ? encoding_ : 'utf8';
  		//assertEncoding(encoding);
	    var noop = function() {};
  		var callback_ = (structKeyExists(arguments, 'cb') && _.isFunction(cb)) ? cb : noop;
  		
  		open(p, 'w', 438 /*=0666*/, function(openErr, fd) {
    		if (structKeyExists(arguments, 'openErr') && !_.isEmpty(openErr)) {
      			if(_.isFunction(callback_)) callback_(openErr);
			} else {
				if(directoryExists(fd.path)) {
  					fileWrite(fd, data, encoding);
  				} else {
  					mkdir(fd.path, 0777, function(er) {
				        if (!structKeyExists(arguments, 'er') || _.isEmpty(arguments.er)) {
  							fileWrite(fd, data, encoding);
				        }
  					});
				}
    		}
  		});

	}
	
	public any function createWriteStream(path) {
		var File = createObject("java","java.io.File").init(path);
		var FileWriter = createObject("java","java.io.FileWriter").init(File);

		return FileWriter;
	}

	public void function copyDir(required source,required destination) {
		var src = createObject("java","java.io.File").init(arguments.source);
		var dest = createObject("java","java.io.File").init(arguments.destination);
		
		if(directoryExists(source)) {
			futil.copyDirectory(src,dest);		
		}
	}

	// public any function writeFileSync(path, data, encoding) {
 //  		assertEncoding(encoding);

 //  		var fd = fs.openSync(path, 'w');
	// 	if (!Buffer.isBuffer(data)) {
	// 		data = new Buffer('' + data, encoding || 'utf8');
	// 	}

	// 	var written = 0;
	// 	var length = data.length;
	// 	try {
	// 		while (written < length) {
	// 			written += fs.writeSync(fd, data, written, length - written, written);
	// 		}
	// 	} finally {
	// 		fs.closeSync(fd);
	// 	}
	// };
}
