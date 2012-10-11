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
	var loc = {};
	loc.debug = false;
	loc.cleanPath = path.normalize(x);
	loc.parts = Path.splitPath(x);
	loc.isRelative = !Path.isAbsolute(x);
	loc.pathSep = Path.getSep();
	loc.isPath = (path.fixSeps(x) CONTAINS loc.pathSep);
	loc.y = getCurrentTemplatePath();
	loc.yRel = replace(loc.y,expandPath('/'),'');
	//writeDump(var=yRel,abort=true);
	loc.fullPath = Path.join(Path.dirname(loc.y),x);
	loc.module = {};
	loc.modules_path = path.join(expandPath('/'),'foundry_modules');

	loc.baseName = path.basename(x);
	//try to guess meta data to resolve actual component path instead of child class...
	//loc.metaData = getInheritedMetaData(this,{},loc.basename);
	loc.cacheKey = getCacheKey(loc.baseName,arguments);
	loc.rargs = duplicate(arguments);
	//writeDump(var=loc,abort=true);
	//if(structKeyExists(variables,baseName) AND structKeyExists(request.foundry.cache,cacheKey)) return request.cache[cacheKey];

	structDelete(loc.rargs,'x');

	if(isCoreModule(x)) {
		return createObj("component","/foundry/lib/#x#",loc.rargs,loc.cacheKey);
	} else if (loc.isPath) {
		var thePath = path.resolve(path.dirname(loc.y),x);
		module = load_as_file(thePath,loc.rargs,loc.cacheKey);
		if(!isDefined("module")) {
			module = load_as_directory(thePath,loc.rargs,loc.cacheKey);
		}
	} else {
		// writeDump(var=x);
		// writeDump(var=path.dirname(loc.y));
		// writeDump(var=path.relative(path.join(expandPath('/foundry_modules/'),x),path.dirname(loc.y)),abort=true);
		module = load_foundry_modules(x,Path.dirname(loc.y),loc.rargs,loc.cacheKey);
	}

	if(!isDefined("module")) {
		throw(errorCode="fdry001",type="foundry.no_module",message="Foundry module '#x#' not found.");	
	}

	return module;
}
</cfscript>