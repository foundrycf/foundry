<cfscript>
//persist & cache
request['foundry'] = (structKeyExists(request,'foundry'))? request.foundry : {};
request.foundry['cache'] = (structKeyExists(request.foundry,'cache'))? request.foundry.cache : {};

variables.core_modules = "path,regexp,console,process,struct,arrayobj,util,url,fs,childprocess,emitter,event";

private any function require(x/*,args*/){
	include "./util.cfm";
	include "./path.cfm";
	include "./require_funcs.cfm";
	//writeDump(var=path,abort=true);
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

	//if(structKeyExists(variables,baseName) AND structKeyExists(request.foundry.cache,cacheKey)) return request.cache[cacheKey];

	structDelete(rargs,'x');

	if(isCoreModule(x)) {
		return createObj("component","/foundry/lib/#x#",rargs,cacheKey);
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
</cfscript>