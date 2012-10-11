<cfscript>
isCoreModule = function(x) {
	if(listFindNoCase(core_modules,x)) return true;

	return false;
};

isCached = function(x) {
	if(structKeyExists(request.foundry.cache,x)) {
		return true;
	}

	return false;
};

load_as_file = function(x,rargs = {},cacheKey = "") {
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
};

load_as_directory = function(x,rargs = {},cacheKey = "") {
	var configFile = Path.join(x,"foundry.json");
	
	var indexCFCPath = Path.join(x, "/index.cfc");
	var indexCfmPath = Path.join(x, "/index.cfm");

	if(isFile(configFile)) {
		var configContent = deserializeJson(fileRead(configFile));

		var config = new foundry.lib.config(configContent);
		var m = Path.resolve(Path.dirname(configFile), config.main);
		
		return load_as_file(m,rargs,cacheKey);
	} else if (isFile(indexCFCPath)) {
		return createObj("component",indexCFCPath,rargs,cacheKey);
	} else if (isFile(indexCFMPath)) {
		return fileRead(indexCfmPath);
	} else {
		return false;
	}
};

load_foundry_modules = function(x,start,rargs,cacheKey) {
	var fullPath = "";
	var module_path = foundry_modules_paths(start);

	fullPath = Path.join(module_path,x);
	if(isDir(fullPath)) {
		return load_as_directory(fullPath,rargs,cacheKey);
	} else if (isFile(fullPath)) {
		return load_as_file(fullPath,rargs,cacheKey);
	}
};

foundry_modules_paths = function(start) {
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
};

getCompPath = function(x) {
	var cleanPath = replace(Path.normalize(x),".cfc","");
	var sep = Path.sep();
	cleanPath = Path.relative(expandPath("/"),cleanPath);
	cleanPath = replace(cleanPath,"../","","ALL");
	return replace(Path.relative(expandPath("/"),cleanPath),sep,".","ALL");
};

createObj = function(objType,objPath,rargs = {},ckey = "") {
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
};

compHasInit = function(objPath) {
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
};

getCacheKey = function(moduleid,args) {
	return moduleid & "_" & LCase(HASH("#moduleid#_" & serializeJson(args),"MD5","UTF-8"));
};

checkForInit = function(x) {
	var data = getMetaData(x);
	var constructorNames = "init";
	for (func in data.functions) {
		if(listFindNoCase(constructorNames,func.name)) {
			return true;
		}
	}

	return false;
};

isFile = function(x) {
	if(fileExists(x)) {
		var fileInfo = getFileInfo(x);

		if(fileInfo.type EQ "file") return true;
	}

	return false;
};

isDir = function(x) {
	if(directoryExists(x)) {
		var fileInfo = getFileInfo(x);

		if(fileInfo.type EQ "directory") return true;
	}
	return false;
};

_requireCore = function(moduleid) {
	return createObject("component","core.#moduleid#").init();
};

noop = function() {};

getInheritedMetaData = function(required component,md = {},stopStr = "") {
	var local = {};

	//First time through, get metaData of component. 
	if (structIsEmpty(md)) {
		if (isObject(component)) {
			md = getMetaData(component);
		} else {
			md = getComponentMetaData(component);
		}
	}

	if(len(trim(stopStr)) GT 0 AND md.fullname CONTAINS stopStr) return md;
	
	//If it has a parent, stop and calculate it first, unless of course, we've reached a class we shouldn't recurse into.
	if (structKeyExists(md,"extends")) {
		local.parent = getInheritedMetaData(component,md.extends);
	//If we're at the end of the line, it's time to start working backwards so start with an empty struct to hold our condensesd metadata.
	} else {
		local.parent = {};
		local.parent.inheritancetrail = [];
	}
	
	//Override ourselves into parent
	for (local.key in structKeyArray(md)) {
		//Functions and properties are an array of structs keyed on name, so I can treat them the same
		if (listFind("FUNCTIONS,PROPERTIES",local.key)) {
			if (not structKeyExists(local.parent,local.key)) {
					local.parent[local.key] = [];
			}
			//For each function/property in me...
			for (data in md) {
				local.item = data;
				local.parentItemCounter = 0;
				local.foundInParent = false;

				//...Look for an item of the same name in my parent...
				for (local.parentItem in local.parent) {
					local.parentItemCounter++;
					//...And override it
					if (compareNoCase(local.item.name,local.parentItem.name) eq 0) {
						local.parentItem[local.parentItemCounter] = local.item;
						local.foundInParent = true;
						break;
					}
				}
				//...Or add it
				if (not local.foundInParent) {
					arrayAppend(local.parent[local.key],local.item);
				}
			}
		//For everything else (component-level annotations), just override them directly into the parent
		} else if (NOT listFind("EXTENDS,IMPLEMENTS",local.key)) {
			local.parent[local.key] = md[local.key];
		}
	}

	arrayPrepend(local.parent.inheritanceTrail,local.parent.name);
	return local.parent;
}
</cfscript>