/**
* @name core
* @author Joshua F. Rountree <http://www.joshuairl.com/>
* 
* This is the primary module to extend in your components.
* It contains the primary functions needed to include other 
* Foundry modules into your applications.
*/
component {
	property name="foundry_paths" type="array";

	//persist & cache
	request['foundry'] = (structKeyExists(request,'foundry'))? request.foundry : {};
	request.foundry['cache'] = (structKeyExists(request.foundry,'cache'))? request.foundry.cache : {};
	
	variables.core_modules = "path,regexp,console,process,struct,arrayobj,util,url,fs,childprocess,emitter,event";
	//variables.process = createObject("component","foundry.core.process").init();
	private any function _requireCore(moduleid) {
		return createObject("core.#moduleid#").init();
	}

	this.path = createObject("component","core.path").init();
	this.regexp = createObject("component","core.regexp");
	this.console = createObject("component","core.console");
	this.process = createObject("component","core.process");
	this.util = createObject("component","core.util");

	public any function require(x/*,args*/){
		variables.path = this.path;
		//writeDump(var=path,abort=true);
		//variables._ = _requireCore("util");
		var debug = false;
		//var metaData = getComponentMetaData(this);
		var cleanPath = path.normalize(x);
		var parts = Path.splitPath(x);
		var isRelative = !Path.isAbsolute(x);
		var pathSep = Path.getSep();
		var isPath = (path.fixSeps(x) CONTAINS pathSep);
		var y = getCurrentTemplatePath();
		var yRel = replace(y,expandPath('/'),'');
		//writeDump(var=yRel,abort=true);
		var fullPath = Path.join(Path.dirname(y),x);
		var module = {};
		var modules_path = path.join(expandPath('/'),'foundry_modules');

		var baseName = path.basename(x);
		var cacheKey = getCacheKey(baseName,arguments);
		var rargs = duplicate(arguments);

		if(structKeyExists(variables,baseName) AND structKeyExists(request.foundry.cache,cacheKey)) return request.cache[cacheKey];

		structDelete(rargs,'x');

		if(isCoreModule(x)) {
			return _requireCore(x);
		} else if (isPath) {
			var thePath = path.resolve(path.dirname(y),x);
			module = load_as_file(thePath,rargs,cacheKey);
			if(!isDefined("module")) {
				module = load_as_directory(thePath,rargs,cacheKey);
			}
		} else {
			// writeDump(var=x);
			// writeDump(var=path.dirname(y));
			// writeDump(var=path.relative(path.join(expandPath('/foundry_modules/'),x),path.dirname(y)),abort=true);
			module = load_foundry_modules(x,Path.dirname(y),rargs,cacheKey);
		}

		if(!isDefined("module")) {
			throw(errorCode="fdry001",type="foundry.no_module",message="Foundry module '#x#' not found.");	
		}

		return module;
	}

	private any function isCoreModule(x) {
		if(listFindNoCase(core_modules,x)) return true;

		return false;
	}

	private any function isCached(x) {
		if(structKeyExists(request.foundry.cache,x)) {
			return true;
		}

		return false;
	}

	private any function load_as_file(x,rargs = {},cacheKey = "") {
		var compPath = getCompPath(x);
		var xWithCFC = (right(x,4) EQ ".cfc")? x : x & ".cfc";
		var xWithCFM = (right(x,4) EQ ".cfm" AND right(x,4) EQ ".cfc")? x : replace(x,'.cfc','') & ".cfm";

		if(isFile(x)) {
			return createObj("component",x,rargs,cacheKey);
		} else if (isFile(xWithCFC)) {
			return createObj("component",x,rargs,cacheKey);
		} else if (isFile(xWithCFM)) {
			return fileRead(x);
		}
	}

	private any function load_as_directory(x,rargs = {},cacheKey = "") {
		var configFile = Path.join(x,"foundry.json");
		
		var indexCFCPath = Path.join(x, "/index.cfc");
		var indexCfmPath = Path.join(x, "/index.cfm");

		if(isFile(configFile)) {
			var configContent = deserializeJson(fileRead(configFile));

			var config = new core.config(configContent);
			var m = Path.resolve(Path.dirname(configFile), config.main);
			
			return load_as_file(m,rargs,cacheKey);
		} else if (isFile(indexCFCPath)) {
			return createObj("component",indexCFCPath,rargs,cacheKey);
		} else if (isFile(indexCFMPath)) {
			return fileRead(indexCfmPath);
		} else {
			return false;
		}
	}

	private any function load_foundry_modules(x,start,rargs,cacheKey) {
		var fullPath = "";
		var module_path = foundry_modules_paths(start);

		fullPath = Path.join(module_path,x);
		if(isDir(fullPath)) {
			return load_as_directory(fullPath,rargs,cacheKey);
		} else if (isFile(fullPath)) {
			return load_as_file(fullPath,rargs,cacheKey);
		}
	}

	private any function foundry_modules_paths(start) {
		var currPath = start;
		var nextPath = path.resolve(currPath,'../');
		var root = false;
		var rootPath = rereplace(path.fixSeps(expandPath("/")),"[\\\/]{1}$","");
		var xdirs = directoryList(currPath);
		var foundryPaths = [];

		if(rootPath EQ currPath) {
			root = true;
		};

		foundryPaths = arrayFilter(xdirs,function(x) {
			if(x CONTAINS "foundry_modules") {
				return true;
			} else {
				return false;
			}
		});

		if(arrayLen(foundryPaths) EQ 0 AND NOT root) {
			return foundry_modules_paths(nextPath);
		} else {
			return path.join(currPath,'foundry_modules',foundryPaths);
		}
	}

	private string function getCompPath(x) {
		var cleanPath = replace(Path.normalize(x),".cfc","");
		var sep = Path.sep();

		return replace(Path.relative(expandPath("/"),cleanPath),sep,".","ALL");
	}

	private any function createObj(objType,objPath,rargs = {},ckey = "") {
		var obj = {};
		var cacheKey = (len(trim(ckey)) GT 0)? ckey : getCacheKey(path.basename(objPath),rargs);
		if(structCount(rargs) GT 0) {
			new_rargs = {};
			for(var i = 1; i <= structCount(rargs)+1; i++) {
				if(structKeyExists(rargs,i)) {
					new_rargs['#i-1#'] = rargs[i];
				}
			}
			rargs = new_rargs;
		}

		if(len(trim(cacheKey)) GT 0 AND isCached(cacheKey)) {
			//console.warning("Loading From Cache: #cacheKey#");
			obj = request.foundry['cache'][cacheKey];
		} else {
			//console.error("Not Cached: #objPath#");
			obj = createObject(objType,getCompPath(objPath));
			
			if(compHasInit(getCompPath(objPath))) {
				obj = obj.init(argumentCollection=rargs);
			}

			if(len(trim(cacheKey)) GT 0 AND isDefined("obj")) {
				request.foundry['cache'][cacheKey] = obj;
			}
		}

		return isDefined("obj")? obj : {};
	}

	private boolean function compHasInit(objPath) {
		var hasInit = false;

		var objInfo = getComponentMetaData(objPath);

		if(structKeyExists(objInfo,'functions')) {
			for(func in objInfo.functions) {
				if(func.name EQ "init") {
					hasInit = true;
					break;
				}
			}
		}

		return hasInit;
	}

	private string function getCacheKey(moduleid,args) {
		return moduleid & "_" & LCase(HASH("#moduleid#_" & serializeJson(args),"MD5","UTF-8"));
	}

	private string function checkForInit(x) {
		var data = getMetaData(x);
		var constructorNames = "init";
		for (func in data.functions) {
			if(listFindNoCase(constructorNames,func.name)) {
				return true;
			}
		}

		return false;
	}

	private boolean function isFile(x) {
		if(fileExists(x)) {
			var fileInfo = getFileInfo(x);

			if(fileInfo.type EQ "file") return true;
		}

		return false;
	}

	private boolean function isDir(x) {
		if(directoryExists(x)) {
			var fileInfo = getFileInfo(x);

			if(fileInfo.type EQ "directory") return true;
		}
		return false;
	}


	public any function noop() {};

}