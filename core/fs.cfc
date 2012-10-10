component name="fs" {
	variables.console = new Console();

	// public void function assertEncoding(encoding) {
	// 	if (structKeyExists(arguments, 'encoding' && !Buffer.isEncoding(encoding)) {
	// 		throw new Error('Unknown encoding: ' & encoding);
	// 	}
	// }

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

	public boolean function isSymLink(p) {
		var jFileUtil = createObject("java","org.apache.commons.io.FileUtils");
		var jFile = createObject("java", "java.io.File").init(expandPath("../temp-files"));

		return jFileUtil.isSymLink(jFile);
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
  		var err = {};

  		if(_.isFunction(mode)) cb = mode;
  		
  		try{
  			directoryCreate(path=path.resolve(expandPath('/'), p));
  			FileSetAccessMode(path.resolve(expandPath('/'), p), mode);
  		} catch(any err1) {
  			cb(err1);
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
		var err = {};
		var contents = {
				isFile: false,
				isDirectory: false,
				isSymLink: false,
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
			contents.isSymLink = isSymLink(p);

		} catch(any err) {
			cb(err, contents);
			return false;
		}
		
		cb(err, contents);
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
