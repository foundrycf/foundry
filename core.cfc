/**
* @name core
* @author Joshua F. Rountree <http://www.joshuairl.com/>
* 
* This is the primary module to extend in your components.
* It contains the primary functions needed to include other 
* Foundry modules into your applications.
*/
component {
	//persist & cache
	request['foundry'] = (structKeyExists(request,'foundry'))? request.foundry : {};
	request.foundry['cache'] = (structKeyExists(request.foundry,'cache'))? request.foundry.cache : {};
		
	variables.core_modules = "path,regexp,console,process,struct,arrayobj,util,url,fs,childprocess,emitter,event";
	variables.Path = new core.Path();
	variables._ = new core.util();
	
	property name="foundry_paths" type="array";

	// this.foundry_paths = [
	// 	expandPath("/"),
	// 	path.resolve(expandPath("/"),"../")
	// ];

	public any function require(x/*,args*/){
		var debug = false;
		
		var cleanPath = Path.normalize(x);
		var parts = Path.splitPath(x);
		var isRelative = !Path.isAbsolute(x);
		var pathSep = Path.getSep();
		var isPath = (path.fixSeps(x) CONTAINS pathSep);
		var y = getComponentMetaData(this).path;
		var fullPath = Path.join(Path.dirname(y),x);
		var module = {};
		var modules_path = path.join(expandPath('/'),'foundry_modules');

		var baseName = path.basename(x);
		var cacheKey = baseName & "_" & LCase(HASH(serializeJson(arguments),"MD5","UTF-8"));
		var rargs = duplicate(arguments);
		
		console.config("basename: " & basename);
		console.config("cacheKey: " & cacheKey);
		
		structDelete(rargs,'x');

		if(isCoreModule(x)) {
			return createObj("component",path.join("core",x),rargs,cacheKey);
		} else if (isPath) {
			var thePath = path.resolve(path.dirname(y),x);
			
			module = load_as_file(thePath,rargs,cacheKey);
			if(!isDefined("module")) {
				module = load_as_directory(thePath,rargs,cacheKey);
			}
		} else {
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
		var rootPath = path.fixSeps(expandPath("/")).replaceFirst("[\\\/]{1}$","");
		var dirs = directoryList(path=currPath,listInfo="name");
		var foundryPaths = [];

		if(rootPath EQ currPath) {
			root = true;
		};

		foundryPaths = arrayFilter(dirs,function(x) {
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

	private any function createObj(objType,objPath,rargs = {},cacheKey) {
		var obj = {};
		if(len(trim(cacheKey)) GT 0 AND isCached(cacheKey)) {
			console.warning("Loading From Cache: #cacheKey#");
			obj = request.foundry['cache'][cacheKey];
		} else {
			console.error("Not Cached: #objPath#");
			obj = createObject(objType,getCompPath(objPath));
			
			if(compHasInit(obj)) {
				obj = obj.init(argumentCollection=rargs);
			}

			if(len(trim(cacheKey)) GT 0 AND isDefined("obj")) {
				request.foundry['cache'][cacheKey] = obj;
			}
		}

		return isDefined("obj")? obj : {};
	}

	private boolean function compHasInit(obj) {
		var hasInit = false;

		var objInfo = getComponentMetaData(obj);

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