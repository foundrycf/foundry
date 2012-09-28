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
	application['foundry'] = (structKeyExists(application,'foundry'))? application.foundry : {};
	application.foundry['cache'] = (structKeyExists(application.foundry,'cache'))? application.foundry.cache : {};
	
	variables.core_modules = "path,regexp,console,struct,arrayobj,util,fs,emitter,event";
	variables.Path = new core.Path();
	variables._ = new core.util();
	
	property name="foundry_paths" type="array";

	this.foundry_paths = [
		expandPath("/"),
		path.resolve(expandPath("/"),"../")
	];

	public any function require(x){
		var Path = new core.Path();
		variables.console = new core.Console();
		var cleanPath = Path.normalize(x);
		var parts = Path.splitPath(x);
		var isRelative = !Path.isAbsolute(x);
		var pathSep = Path.getSep();
		var isPath = (path.fixSeps(x) CONTAINS pathSep);
		var y = getComponentMetaData(this).path;
		var fullPath = Path.join(Path.dirname(y),x);
		var module = {};
		var modules_path = path.join(expandPath('/'),'foundry_modules');
		// 1. If X is a core module,
		//    a. return the core module
		//    b. STOP
		// 2. If X begins with './' or '/' or '../'
		//    a. LOAD_AS_FILE(Y + X)
		//    b. LOAD_AS_DIRECTORY(Y + X)
		// 3. LOAD_FOUNDRY_MODULES(X, dirname(Y))
		// 4. THROW "not found"
		//console.log("fullPath: " & fullPath);
		if(isCoreModule(x)) {
			console.log("[CORE_MODULE] " & cleanPath);
			return createObject("component","core.#cleanPath#");
		} else if (isPath) {
			var thePath = path.resolve(path.dirname(y),x);
			console.log("[PATH] " & thePath);

			module = load_as_file(thePath);
			if(!isDefined("module")) {
				return load_as_directory(thePath);
			}
		} else {
			console.log("[MODULE] " & x);
			module = load_foundry_modules(x,Path.dirname(y));
		}

		if(NOT isDefined("module")) {
			throw(errorCode="fdry001",type="foundry.no_module",message="Foundry module '#x#' not found.");	
		}

		return module;
	}
	private any function isCoreModule(x) {
		if(listFindNoCase(core_modules,x)) return true;

		return false;
	}

	private any function load_as_file(x) {
		var compPath = getCompPath(x);
		
		console.log("load as file: " & x);
		var xWithCFC = (right(x,4) EQ ".cfc")? x : x & ".cfc";
		var xWithCFM = (right(x,4) EQ ".cfm" AND right(x,4) EQ ".cfc")? x : replace(x,'.cfc','') & ".cfm";

		if(isFile(x)) {
			console.log("-----[LOAD_FILE] #x#");
			return createObject("component",compPath);
		} else if (isFile(xWithCFC)) {
			console.log("-----[LOAD_FILE] #xWithCFC#");
			return createObject("component",compPath);
		} else if (isFile(xWithCFM)) {
			console.log("-----[LOAD_FILE] #xWithCFM#");
			return fileRead(x);
		}
	}

	private any function load_as_directory(x) {
		// 1. If X/foundry.json is a file,
		//    a. Parse X/foundry.json, and look for "main" field.
		//    b. let M = X + (json main field)
		//    c. LOAD_AS_FILE(M)
		// 2. If X/index.cfc is a file, load X/index.cfc as JavaScript text.  STOP
		// 3. If X/index.cfm is a file, load X/index.cfm as binary addon.  STOP
		var configFile = Path.join(x,"foundry.json");
		
		var indexCFCPath = Path.join(x, "/index.cfc");
		var indexCfmPath = Path.join(x, "/index.cfm");

		console.log("load_as_directory(#x#)");
		if(isFile(configFile)) {
			var configContent = deserializeJson(fileRead(configFile));

			var config = new core.config(configContent);
			var m = Path.resolve(Path.dirname(configFile), config.main);
			
			return load_as_file(m);
		} else if (isFile(indexCFCPath)) {
			return createObject("component",getCompPath(indexCFCPath));
		} else if (isFile(indexCFMPath)) {
			return fileRead(indexCfmPath);
		} else {
			return false;
		}
	}

	private any function load_foundry_modules(x,start) {
		// 1. let DIRS=FOUNDRY_MODULES_PATHS(START)
		// 2. for each DIR in DIRS:
		// 	a. LOAD_AS_FILE(DIR/X)
		// 	b. LOAD_AS_DIRECTORY(DIR/X)
		var fullPath = "";
		var module_path = foundry_modules_paths(start);

		fullPath = Path.join(module_path,x);
		console.log("load_foundry_modules: " & fullPath);
		if(isDir(fullPath)) {
			return load_as_directory(fullPath);
		} else if (isFile(fullPath)) {
			return load_as_file(fullPath);
		}
	}

	private any function foundry_modules_paths(start) {
		// 1. let PARTS = path split(START)
		// 2. let ROOT = index of first instance of "foundry_modules" in PARTS, or 0
		// 3. let I = count of PARTS - 1
		// 4. let DIRS = []
		// 5. while I > ROOT,
		//    a. if PARTS[I] = "foundry_modules" CONTINUE
		//    c. DIR = path join(PARTS[0 .. I] + "foundry_modules")
		//    b. DIRS = DIRS + DIR
		//    c. let I = I - 1
		// 6. return DIRS
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
				console.log("found: #x#");
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

	private void function cacheModule() {

	}

	private boolean function isFile(x) {
		console.log("isFile: " & x);
		
		if(fileExists(x)) {
			var fileInfo = getFileInfo(x);

			if(fileInfo.type EQ "file") return true;
		}

		return false;
	}

	private boolean function isDir(x) {
		//console.log("isDir: " & x);
		if(directoryExists(x)) {
			var fileInfo = getFileInfo(x);

			if(fileInfo.type EQ "directory") return true;
		}
		return false;
	}

	public any function noop() {};

}