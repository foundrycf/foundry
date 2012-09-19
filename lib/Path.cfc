/**
* @name Path.cfc
* @hint A port of Node.js Path for Coldfusion
* @author Joshua F. Rountree (http://www.joshuairl.com/)
*/
component accessors=true {
	property name="sep"
	type="string";

	public function init() {
		variables._ = new cf_modules.UnderscoreCF.Underscore();
		
		variables.jPath = createObject("java","org.apache.commons.io.FilenameUtils");
		variables.jRegex = createObject("java","java.util.regex.Pattern");
		variables.jArrayUtils = createObject("java","org.apache.commons.lang.ArrayUtils");
		variables.isWindows = server.os.name EQ "Windows";
		//windows regex
		variables.splitDeviceRe = "^([\s\S]+[\\\/](?!$)|[\\\/])?((?:\.{1,2}$|[\s\S]+?)?(\.[^.\/\\]*)?)$";
		variables.splitTailRe = "^([\s\S]+[\\\/](?!$)|[\\\/])?((?:\.{1,2}$|[\s\S]+?)?(\.[^.\/\\]*)?)$";
		
		//posix regex
		variables.splitPathRe = "^(\/?)([\s\S]+\/(?!$)|\/)?((?:\.{1,2}$|[\s\S]+?)?(\.[^.\/]*)?)$";

		this.setSep(sep());
		return this;
	}

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
			var result = ReMatchGroups(thePath,splitDeviceRe);
			var device = (result[1] || '');
			var isUnc = (device && charAt(device,1) != ':');
			var isAbsolute = !_.isEmpty(result[2]) || isUnc;
	        var tail = result[3];
			var trailingSlash = (arrayLen(reMatch("[\\\/]$",tail)) GT 0);
			
			//Normalize the tail path
			tailSplit = listToArray(tail,"\");
			//filter array
			ArrayFilter(tailSplit,function(p) {
				return !_.isEmpty(arguments.p);
			});

			//normalize array
			tailSplit = normalizeArray(tailSplit, !isAbsolute);

			//convert it back to a string
			tail = arrayToList(tailSplit,"\");

			if (_.isEmpty("tail") AND !isAbsolute) {
				tail = ".";
			}

			if (!_.isEmpty("tail") AND trailingSlash) {
				tail &= "\";
			}

			device = rereplace("\/",device,'\\',"ALL");

			return device & (isAbsolute ? '\\' : '') & tail;

			// var result = splitDeviceRe.exec(path),
			//        device = result[1] || '',
			//        isUnc = device && device.charAt(1) !== ':',
			//        isAbsolute = !!result[2] || isUnc, // UNC paths are always absolute
			//        tail = result[3],
			//        trailingSlash = /[\\\/]$/.test(tail);

			//    // Normalize the tail path
			//    tail = normalizeArray(tail.split(/[\\\/]+/).filter(function(p) {
			//      return !!p;
			//    }), !isAbsolute).join('\\');

			//    if (!tail && !isAbsolute) {
			//      tail = '.';
			//    }
			//    if (tail && trailingSlash) {
			//      tail += '\\';
			//    }

			//    // Convert slashes to backslashes when `device` points to an UNC root.
			//    device = device.replace(/\//g, '\\');

			//    return device + (isAbsolute ? '\\' : '') + tail;
		//posix
		} else {
			// var isAbsolute = path.charAt(0) === '/',
			//     trailingSlash = path.substr(-1) === '/';

			//    // Normalize the path
			//    path = normalizeArray(path.split('/').filter(function(p) {
			//      return !!p;
			//    }), !isAbsolute).join('/');

			//    if (!path && !isAbsolute) {
			//      path = '.';
			//    }
			//    if (path && trailingSlash) {
			//      path += '/';
			//    }

			//    return (isAbsolute ? '/' : '') + path;

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
	* 	@header path.extname(p)
	*	@hint Return the extension of the path, from the last '.' to end of string in the last portion of the path. If there is no '.' in the last portion of the path or the first character of it is '.', then it returns an empty string. Examples: 
	* 	@example path.extname('index.html')<br />// returns<br />'.html'<br /><br />path.extname('index.')<br />// returns<br />'.'<br /><br />path.extname('index')<br />// returns<br />''
	* 	@author Alexander Sicular &amp; Raymond Camden
	*/
	public string function extname(p) {
		return splitPath(arguments.p)[4];
	}

	/**
	* 	@header path.resolve([from ...], to)
	*	@hint Resolves to <pre>to</pre> an absolute path.<br><br>If to isn't already absolute from arguments are prepended in right to left order, until an absolute path is found. If after using all from paths still no absolute path is found, the current working directory is used as well. The resulting path is normalized, and trailing slashes are removed unless the path gets resolved to the root directory. Non-string arguments are ignored.<br><br>Another way to think of it is as a sequence of cd commands in a shell. 
	* 	@example path.resolve('/foo/bar', './baz')<br />// returns<br />'/foo/bar/baz'<br /><br />path.resolve('/foo/bar', '/tmp/file/')<br />// returns<br />'/tmp/file'<br /><br />path.resolve('wwwroot', 'static_files/png/', '../gif/image.gif')<br />// if currently in /home/myself/node, it returns'/home/myself/node/wwwroot/static_files/gif/image.gif'
	*/
	public string function resolve() {
    	var resolvedDevice = '';
	    var resolvedTail = '';
	    var resolvedPath = "";
	    var resolvedAbsolute = false;
		var thePath = "";
	    if(isWindows) {
		    for (var i = listLen(structKeyList(arguments),","); i >= 1 && !resolvedAbsolute; i--) {
			  thePath = "";

		      if (i >= 0) {
		        thePath = arguments[i];
		      } else if (!resolvedDevice) {
		        thePath = expandPath("/");
		      } else {
		        // Windows has the concept of drive-specific current working
		        // directories. If we've resolved a drive letter but not yet an
		        // absolute thePath, get cwd for that drive. We're sure the device is not
		        // an unc thePath at this points, because unc thePaths are always absolute.
		        thePath = expandPath(resolvedDevice);
		        // Verify that a drive-local cwd was found and that it actually points
		        // to our drive. If not, default to the drive's root.
		        if (!thePath || LCase(left(thePath,3)) NEQ LCase(resolvedDevice & '\')) {
		          thePath = resolvedDevice + '\';
		        }
		      }

		      // Skip empty and invalid entries
		      if (!_.isString(thePath) || _.isEmpty(thePath)) {
		        continue;
		      }

		      //split the thePath to array
				var result = ReMatchGroups(thePath,splitDeviceRe);
				var device = (result[1] || '');
				var isUnc = (device && charAt(device,1) != ':');
				var isAbsolute = !_.isEmpty(result[2]) || isUnc;
		        var tail = result[3];
				
		      if (!_.isEmpty(device) &&
		          !_.isEmpty(resolvedDevice) &&
		          lcase(device) NEQ LCase(resolvedDevice)) {
		        // This thePath points to another device so it is not applicable
		        continue;
		      }	

		      if (_.isEmpty(resolvedDevice)) {
		        resolvedDevice = device;
		      }
		      if (_.isEmpty(resolvedAbsolute)) {
		        resolvedTail = tail & '\' & resolvedTail;
		        resolvedAbsolute = isAbsolute;
		      }

		      if (resolvedDevice && resolvedAbsolute) {
		        break;
		      }
		     }
	    } else {
	    		for (var i = listLen(structKeyList(arguments)); i >= 1 && !resolvedAbsolute; i--) {
			      thePath = (i >= 1) ? arguments[i] : expandPath("/");

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

			    return (len(trim(returnPath)) GT 0)? returnPath : '/';
	    	}
	}

	public any function join() {
		var argArr = structKeyArray(arguments);
		arraySort(argArr,"numeric","asc");
		var paths = [];

		if(isWindows) {

		} else {
			paths = [];
			for (arg in argArr) {
				paths.add(arguments[arg]);
			}
			//filter out empty strings
			paths = arrayFilter(paths,function(p) {
				return (_.isString(arguments.p) AND !_.isEmpty(arguments.p));
			});

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
		    writeDump(var=theFrom,label="theFrom");
		    writeDump(var=theTo,label="theTo");
		    var fromParts = listToArray(theFrom,"/");
		    var toParts = listToArray(theTo,"/");

		    writeDump(var=fromParts,label="fromParts");
		    writeDump(var=toParts,label="toParts");
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
		    writeDump(var=samePartsLength,label="samePartsLength");
		        
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
			result = ReMatchGroups(arguments.filename,splitDeviceRe);
				device = ((structKeyExists(result,'1') && !_.isEmpty(result['1']))? result['1'] : '') & ((structKeyExists(result,'2') && !_.isEmpty(result['2']))? result['2'] : '');
				tail = ((structKeyExists(result,'3') && !_.isEmpty(result['4']))? result['3'] : '');
			
			result2 = ReMatchGroups(tail);
				dir = ((structKeyExists(result2,'1') && !_.isEmpty(result2['1']))? result2['1'] : '');
				basename = ((structKeyExists(result2,'2') && !_.isEmpty(result2['2']))? result2['2'] : '');
				ext = ((structKeyExists(result2,'3') && !_.isEmpty(result2['3']))? result2['3'] : '');

		//posix only
		} else {

			result = ReMatchGroups(arguments.filename,splitPathRe);
			device = ((structKeyExists(result,'1') && !_.isEmpty(result['1']))? result['1'] : '');
			dir = ((structKeyExists(result,'2') && !_.isEmpty(result['2']))? result['2'] : '');
			basename = ((structKeyExists(result,'3') && !_.isEmpty(result['3']))? result['3'] : '');
			ext = ((structKeyExists(result,'4') && !_.isEmpty(result['4']))? result['4'] : '');
		};

		return [device,dir,basename,ext];
	}

	private array function arrtrim(arr) {
		var theArr = arguments.arr;
		var start = 1;
		for (; start LT arrayLen(theArr); start++) {
			writeDump(var=theArr[start],label="Start");
			if (!_.isEmpty(theArr[start])) break;
		}

		var end = arrayLen(theArr);
		for (; end GTE 0; end--) {
			writeDump(var=theArr[end],label="end");
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
			dir = left(dir,len(dir)-1);
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
	  	return true;
	  } else {
	  	return false;
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

	/**
	* REMatchGroups UDF
	* @Author Ben Nadel <http://bennadel.com/>
	*/
	private struct function REMatchGroups(text,pattern,scope = "all") {
		var local = structnew();
		local.results = {};
		local.pattern =createobject( "java", "java.util.regex.Pattern" ).compile( javacast( "string", arguments.pattern ) );
		
		local.matcher =local.pattern.matcher( javacast( "string", arguments.text ) );
		
		while (local.Matcher.Find()) {
			local.groups =structnew();
			
			for(local.GroupIndex=0; local.GroupIndex <= local.Matcher.GroupCount();LOCAL.GroupIndex++) {
				local.results[local.groupindex] = (local.matcher.group( javacast( "int", local.groupindex ) ));
			}
			
			//arrayappend( local.results, local.groups )
			
			if(arguments.scope EQ "one") {
				break;
			}
			
		}

		return local.results;
	}

	/**
	 * Slices an array.
	 * 
	 * @param ary      The array to slice. (Required)
	 * @param start      The index to start with. Defaults to 1. (Optional)
	 * @param finish      The index to end with. Defaults to the end of the array. (Optional)
	 * @return Returns an array. 
	 * @author Darrell Maples (drmaples@gmail.com) 
	 * @version 1, July 13, 2005 
	 */
	// function arraySlice(ary) {
	//     var start = 1;
	//     var finish = arrayLen(ary);
	//     var slice = arrayNew(1);
	//     var j = 1;

	//     if (len(arguments[2])) { start = arguments[2]; };
	//     if (len(arguments[3])) { finish = arguments[3]; };

	//     for (j=start; j LTE finish; j=j+1) {
	//         arrayAppend(slice, ary[j]);
	//     }
	//     return slice;
	// }
	
}