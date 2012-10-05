/**
* @name Path.cfc
* @hint A port of Node.js Path for Coldfusion
* @author Joshua F. Rountree (http://www.joshuairl.com/)
*/
component accessors=true {
	property name="sep"
	type="string";
	
	variables.isWindows = (server.os.name CONTAINS "windows");
	variables._ = new util();
	variables.jPath = createObject("java","org.apache.commons.io.FilenameUtils");
	variables.jRegex = createObject("java","java.util.regex.Pattern");
	variables.jArrayUtils = createObject("java","org.apache.commons.lang.ArrayUtils");
	variables.system = CreateObject("java", "java.lang.System");
	variables.env = system.getenv();
	variables.console = new console();
	//windows regex
	variables.splitDeviceRe = new RegExp("^([a-zA-Z]:|[\\/]{2}[^\\\/]+[\\\/][^\\\/]+)?([\\\/])?([\s\S]*?)$");
	variables.splitTailRe = new RegExp("^([\s\S]+[\\\/](?!$)|[\\\/])?((?:\.{1,2}$|[\s\S]+?)?(\.[^.\/\\]*)?)$");
	
	//posix regex
	variables.splitPathRe = new RegExp("^(\/?)([\s\S]+\/(?!$)|\/)?((?:\.{1,2}$|[\s\S]+?)?(\.[^.\/]*)?)$");
	
	this.setSep(sep());
	return this;

	/**
	* 	@header path.normalize(p)
	*	@hint Normalize a string path, taking care of '..' and '.' parts.<br /><br />When multiple slashes are found, they're replaced by a single one; when the path contains a trailing slash, it is preserved. On windows backslashes are used. 
	* 	@example path.normalize('/foo/bar//baz/asdf/quux/..')<br />// returns<br />'/foo/bar/baz/asdf'
	*   @author S. Isaac Dealey (info@turnkey.to) 
	*/
	public string function normalize(p) {
		var thePath = jpath.separatorsToSystem(arguments.p);
			
		//windows
		if(isWindows) {
	       	//split the path to array
			var result = splitDeviceRe.match(thePath);
			var device = (!isNull(result[1]) && !_.isEmpty(result[1])? result[1] : '');
			var isUnc = (!_.isEmpty(device) && charAt(device,1) NEQ ':');
			var isAbsolute = (!isNull(result[2]) && !_.isEmpty(result[2]))? true : isUnc;
	        var tail = result[3];
	        var tester = new RegExp("[\\\/]$");
			var trailingSlash = tester.test(tail);

			
			//Normalize the tail path
			tailSplit = listToArray(tail,"\");

			//filter array
			ArrayFilter(tailSplit,function(p) {
				return !_.isEmpty(p);
			});
			
			tailSplit = normalizeArray(tailSplit,(!isAbsolute));

			//convert it back to a string
			tail = arrayToList(tailSplit,"\");
			if (_.isEmpty(tail) AND !isAbsolute) {
				tail = ".";
			}

			if (!_.isEmpty(tail) AND trailingSlash) {
				tail &= "\";
			}
			//convert slashes to backslashes when 'device' points to a UNC root.
			device = rereplace(device,"\/",'\\',"ALL");

			//writeDump(var=device,abort=true);
			return device & (isAbsolute ? '\' : '') & tail;

		//posix
		} else {
			
		    var isAbsolute = left(thePath,1) EQ "/";
	        var trailingSlash = right(thePath,1) EQ "/";
			
	       	//split the path to array
			var splitPaths = listToArray(thePath,"/");
			
			//filter out empty strings
			splitPaths = arrayFilter(splitPaths,function(p) {
				return !_.isEmpty(arguments.p);
			});
			//normalize array
			splitPaths = normalizeArray(splitPaths,(!isAbsolute));
			
			//return path back to it's string
			thePath = ArrayToList(splitPaths,"/");

	        if(_.isEmpty(thePath) && !isAbsolute) {
	        	thePath = ".";
	        }
	        if(!_.isEmpty(thePath) && trailingSlash) {
	        	thePath &= "/";
	        }
	        return (isAbsolute ? "/" : '') & thePath;
		}
		
	}

	/**
	* 	@header path.resolve([from ...], to)
	*	@hint Resolves to <pre>to</pre> an absolute path.<br><br>If to isn't already absolute from arguments are prepended in right to left order, until an absolute path is found. If after using all from paths still no absolute path is found, the current working directory is used as well. The resulting path is normalized, and trailing slashes are removed unless the path gets resolved to the root directory. Non-string arguments are ignored.<br><br>Another way to think of it is as a sequence of cd commands in a shell. 
	* 	@example path.resolve('/foo/bar', './baz')<br />// returns<br />'/foo/bar/baz'<br /><br />path.resolve('/foo/bar', '/tmp/file/')<br />// returns<br />'/tmp/file'<br /><br />path.resolve('wwwroot', 'static_files/png/', '../gif/image.gif')<br />// if currently in /home/myself/node, it returns'/home/myself/node/wwwroot/static_files/gif/image.gif'
	*/
	public string function resolve() {
		var argsArr = structKeyArray(arguments);
    	var resolvedDevice = '';
	    var resolvedTail = '';
	    var resolvedPath = "";
	    var resolvedAbsolute = false;
		var thePath = "";

		if(isWindows) {
			for (var i = arrayLen(argsArr); i >= 0 && !resolvedAbsolute; i--) {
				thePath = "";
				
				if (i >= 1) {
					thePath = arguments[i];
					console.print("firstif path: " & serialize(thePath));
				} else if (_.isEmpty(resolvedDevice)) {
					thePath = expandPath('/');
					console.print("secondif path: " & serialize(thePath));
				} else {
					// Windows has the concept of drive-specific current working
					// directories. If we've resolved a drive letter but not yet an
					// absolute path, get cwd for that drive. We're sure the device is not
					// an unc path at this points, because unc paths are always absolute.
					thePath = env.get('=' & resolvedDevice);
					// Verify that a drive-local cwd was found and that it actually points
					// to our drive. If not, default to the drive's root.
					if (_.isEmpty(thePath) || mid(lcase(thePath),1,4) NEQ
						lcase(resolvedDevice) & '\') {
						thePath = resolvedDevice & '\';
					}
					console.print("thirdif path: " & serialize(thePath));
				}

				// Skip empty and invalid entries
				if (!_.isString(thePath) || _.isEmpty(thePath)) {
					continue;
				}

				//split the path to array
				var result = splitDeviceRe.match(thePath);
				var device = (!isNull(result[1]) && !_.isEmpty(result[1])? result[1] : '');
				var isUnc = (!_.isEmpty(device) && device.charAt(1) NEQ ':');
				var isAbsolute = (!isNull(result[2]) && !_.isEmpty(result[2]))? true : isUnc;
				var tail = result[3];

				if (!_.isEmpty(device) &&
				!_.isEmpty(resolvedDevice) &&
				lcase(device) NEQ lcase(resolvedDevice)) {
					// This path points to another device so it is not applicable
					continue;
				}

				if (_.isEmpty(resolvedDevice)) {
					resolvedDevice = device;
				}

				if (!resolvedAbsolute) {
					resolvedTail = tail & '\' & resolvedTail;
					resolvedAbsolute = isAbsolute;
				}

				if (!_.isEmpty(resolvedDevice) && resolvedAbsolute) {
					break;
				}
			}
			// Replace slashes (in UNC share name) by backslashes
			resolvedDevice = rereplace(resolvedDevice,"\/",'\',"ALL");
			// At this point the path should be resolved to a full absolute path,
			// but handle relative paths to be safe (might happen when process.cwd()
			// fails)

			//Normalize the tail path
			resolvedTail = listToArray(fixSeps(resolvedTail),"\");
			//filter array
			ArrayFilter(resolvedTail,function(p) {
				return !_.isEmpty(p);
			});

			resolvedTail = normalizeArray(resolvedTail,(!isAbsolute));
			//writeDump(var=resolvedTail,abort=true);
			//convert it back to a string
			resolvedTail = arrayToList(resolvedTail,"\");
			finalPath = resolvedDevice & ((  resolvedAbsolute)? '\' : '') & resolvedTail;
			return (!_.isEmpty(finalPath))? finalPath : '.';
	    } else {
    		for (var i = structCount(arguments); i >= 0 && !resolvedAbsolute; i--) {
				thePath = (i >= 1) ? arguments[i] : expandPath('/');
				// Skip empty and invalid entries
				if (!_.isString(thePath) || _.isEmpty(thePath)) {
					continue;
				}
				resolvedPath = thePath & '/' & resolvedPath;
				resolvedAbsolute = left(thePath,1) EQ '/';
		    }

		    // At this point the thePath should be resolved to a full absolute thePath, but
		    // handle relative thePaths to be safe (might happen when process.cwd() fails)
		    //split the path to array
		    
			var pathsSplit = listToArray(resolvedPath,"/");
			
			
			//filter out empty strings
			pathsSplit = arrayFilter(pathsSplit,function(p) {
				return !_.isEmpty(arguments.p);
			});

			//normalize array
			pathsSplit = normalizeArray(pathsSplit,!resolvedAbsolute);
			//return path back to it's string
			resolvedPath = ArrayToList(pathsSplit,"/");

			returnPath = ((resolvedAbsolute ? '/' : '') & resolvedPath);
			return (len(trim(returnPath)) GT 0)? returnPath : '.';
	    }
	}

	public any function join() {
		var argArr = structKeyArray(arguments);
		arraySort(argArr,"numeric","asc");
		var paths = [];
		for (arg in argArr) {
			paths.add(arguments[arg]);
		}
		//filter out empty strings
		paths = arrayFilter(paths,function(p) {
			return (_.isString(arguments.p) AND !_.isEmpty(arguments.p));
		});

		if(isWindows) {
		    var joined = arrayToList(paths,'\');
		    var tester = new RegExp("^[\\/]{2}");
		    // Make sure that the joined path doesn't start with two slashes
		    // - it will be mistaken for an unc path by normalize() -
		    // unless the paths[0] also starts with two slashes
		    if (tester.test(joined) && !tester.test(paths[1])) {
		      joined = right(joined,len(joined)-1);
		    }

		    //thePath = arrayToList(paths,"/");
		    joined = normalize(joined);

		    return joined;
		} else {
			thePath = ArrayToList(paths,"/");

			//normalize]
			thePath = normalize(thePath);
			//return path back to it's string

		    return thePath;
		}
	}

	public any function relative(from, to) {
	    // if(isWindows) {
	    // 	var theFrom = exports.resolve(arguments.from);
		   //  var theTo = exports.resolve(arguments.to);

		   //  // windows is not case sensitive
		   //  var lowerFrom = LCase(theFrom);
		   //  var lowerTo = LCase(theTo);

		   //  function trim(arr) {
		   //    var start = 0;
		   //    for (; start < arr.length; start++) {
		   //      if (arr[start] !== '') break;
		   //    }

		   //    var end = arr.length - 1;
		   //    for (; end >= 0; end--) {
		   //      if (arr[end] !== '') break;
		   //    }

		   //    if (start > end) return [];
		   //    return arr.slice(start, end - start + 1);
		   //  }

		   //  var toParts = trim(listToArray(theTo,'\'));

		   //  var lowerFromParts = trim(listToArray(lowerFrom,'\'));
		   //  var lowerToParts = trim(listToArray(lowerTo,'\'));

		   //  var length = Math.min(arrayLen(lowerFromParts), arrayLen(lowerToParts));
		   //  var samePartsLength = length;
		    
		   //  for (var i = 1; i < length; i++) {
		   //    if (lowerFromParts[i] !== lowerToParts[i]) {
		   //      samePartsLength = i;
		   //      break;
		   //    }
		   //  }

		   //  if (samePartsLength == 0) {
		   //    return theTo;
		   //  }

		   //  var outputParts = [];
		   //  for (var i = samePartsLength; i < arrayLen(lowerFromParts); i++) {
		   //    outputParts.add('..');
		   //  }

		   //  outputParts = _.concat(outputParts,arraySlice(toParts,samePartsLength));

		   //  return arrayToList(outputParts,'\\');
    	// } else {
    		var resolveFrom = resolve(arguments.from);
    		var resolveTo = resolve(arguments.to);

    		//remove first slash
    		var theFrom = mid(resolveFrom,2,len(resolveFrom));
		    var theTo = mid(resolveTo,2,len(resolveTo));
		    
		    var fromParts = listToArray(theFrom,"/");
		    var toParts = listToArray(theTo,"/");

		   
		    //run array trim
		    // var fromParts = arrtrim(listToArray(from,'/'));
		    // var toParts = arrtrim(listToArray(to,'/'));
		    
		    var length = Min(arrayLen(fromParts), arrayLen(toParts));
		    
		    var samePartsLength = length;
		    
		    for (var i = 0; i LT length; i++) {
		      if (fromParts[i+1] NEQ toParts[i+1]) {
		    	samePartsLength = i;
		        break;
		      }
		    }
		      
		    var outputParts = [];
		    for (var e = samePartsLength; e LT arrayLen(fromParts); e++) {
		      outputParts.add('..');
		    }
		   
		    // if(arrayLen(toParts) EQ 1 AND samePartsLength EQ 1) {
		    // 	arrayDeleteAt(toParts,1);
		    // }
		    outputParts.addAll(jArrayUtils.subarray(toParts,samePartsLength,arrayLen(toParts)));
		    return ArrayToList(outputParts,'/');
    	// }
	}

	//HELPERS
	function splitPath(filename) {
		var result = [];
		var result2 = [];
		var device = "";
		var dir = "";
		var ext = "";
		var basename = "";
		var tail = "";

		//windows only
		if (isWindows) {
			result = splitDeviceRe.match(arguments.filename);
			//console.print("result: " & serialize(result));
				device = (!isNull(result[1])? result[1] : '') & ((!isNull(result[2]))? result[2] : '');
				tail = ((!isNull(result[3]))? result[3] : '');
			// console.print("device: " & serialize(device));
			// console.print("tail: " & serialize(tail));
			
			result2 = splitTailRe.match(tail);
			// console.print("result2: " & serialize(result2));
			
				dir = ((!isNull(result2[1]))? result2[1] : '');

				// console.print("dir: " & serialize(dir));
			
				basename = ((!isNull(result2[2]))? result2[2] : '');
				// console.print("basename: " & serialize(basename));
			
				ext = ((!isNull(result2[3]))? result2[3] : '');
				// console.print("ext: " & serialize(ext));
			

			//writeDump(var=result,abort=true);
		//posix only
		} else {
			result = splitPathRe.match(arguments.filename);
			device = (!isNull(result[1])? result[1] : '');
			dir = ((!isNull(result[2]))? result[2] : '');
			basename = ((!isNull(result[3]))? result[3] : '');
			ext = ((!isNull(result[4]))? result[4] : '');
		};
		return [device,dir,basename,ext];
	}

	private array function arrtrim(arr) {
		var theArr = arguments.arr;
		var start = 1;
		for (; start LT arrayLen(theArr); start++) {
			if (!_.isEmpty(theArr[start])) break;
		}

		var end = arrayLen(theArr);
		for (; end GTE 0; end--) {
			if (!_.isEmpty(theArr[end])) break;
		}

		if (start GT end) return [];
		return arraySlice(theArr,start,end - start + 1);
    }

	// resolves . and .. elements in a path array with directory names there
	// must be no slashes, empty elements, or device names (c:\) in the array
	// (so also no leading and trailing slashes - it does not distinguish
	// relative and absolute paths)
	function normalizeArray(parts, allowAboveRoot) {
	  // if the path tries to go above the root, `up` ends up > 0
	  var up = 0;
	  var theParts = arguments.parts;

	  for (var i = arrayLen(theParts); i >= 1; i--) {
	    var last = theParts[i];
	    if (last EQ '.') {
	      theParts = _.splice(theParts,i,1);
	    } else if (last EQ '..') {
	      theParts = _.splice(theParts,i,1);
	      up++;
	    } else if (up) {
	      theParts = _.splice(theParts,i,1);
	      up--;
	    }
	  }
	  // if the path is allowed to go above the root, restore leading ..s
	 if (allowAboveRoot) {
	    for (; up--; up) {
	    	unshift(theParts,'..');
	    }
	  }
	  
	  return theParts;
	}

	/**
	* 	@header path.extname(p)
	*/
	public string function extname(p) {
		return splitPath(arguments.p)[4];
	}

	public any function dirname(path) {
		var result = splitPath(path);
		var root = result[1];
		var dir = result[2];
		
		if (_.isEmpty(root) && _.isEmpty(dir)) {
			// No dirname whatsoever
			return '.';
		}

		if (!_.isEmpty(dir)) {
			// It has a dirname, strip trailing slash
			if(len(dir) GT 1) {
			dir = left(dir,len(dir)-1);
			}
		}
		
		return root & dir;
	};

	public any function basename(path, ext = "") {
		var f = splitPath(arguments.path)[3];
		var theExt = arguments.ext;
		if(!_.isEmpty(theext) AND right(f,len(theExt)) EQ theExt) {
			f = left(f,len(f) - len(theExt));
		}

		return f;
	};

	public any function exists(path, callback) {
	  if(fileExists(path) || directoryExists(path)) {
	  	callback(true);
	  } else {
	  	callback(false);
	  };
	};

	public any function existsSync(path, callback) {
	  if(fileExists(path) || directoryExists(path)) {
	  	callback();
	  };
	};

	public any function unshift(obj = this.obj) {
		var elements = _.slice(arguments, 2);
		for (var i = arrayLen(elements); i > 0; i--) {
			arrayPrepend(obj, elements[i]);
		}
		return obj;
	}

	function isAbsolute(str) {
		return (reFindNoCase("[a-zA-Z]:\\",str) GT 0 || left(str,1) EQ "/");
	}

	function CharAt(str,pos) {
	    return Mid(str,pos,1);
	}

	public any function sep() {
		return toString(jpath.separatorsToSystem("/"));
	}


	public any function fixSeps(x) {
		return toString(jpath.separatorsToSystem(x));
	}
	/**
	* reSplit UDF
	* @Author Ben Nadel <http://bennadel.com/>
	*/
	private array function reSplit(regex,value) {
		var local = {};
		local.result = [];
		local.parts = javaCast( "string", arguments.value ).split(
			javaCast( "string", arguments.regex ),
			javaCast( "int", -1 )
		);

		for (local.part in local.parts) {
			arrayAppend(local.result,local.part );
		};

		return local.result;
	}

	
}