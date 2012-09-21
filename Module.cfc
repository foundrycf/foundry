component name="Module" {
	//persist & cache
	application['foundry'] = (structKeyExists(application,'foundry'))? application.foundry : {};
	application.foundry['cache'] = (structKeyExists(application.foundry,'cache'))? application.foundry.cache : {};
	
	this.core_modules = "path,regexp,console,struct,array";
	/**
	 * Creates a CFC instance based upon a relative, absolute or dot notation path.
	*/
	public any function require(x){
		var Path = new lib.Path();
		var cleanPath = Path.normalize(x);
		var parts = Path.splitPath(x);
		var _ = new lib.Underscore();
		var isRelative = !Path.isAbsolute(x);
		var pathSep = Path.getSep();
		var isPath = (cleanPath CONTAINS pathSep);
		var metaData = getComponentMetaData(this);
		var y = Path.splitPath(metaData.path)[2];
		var fullPath = Path.resolve(y,x);

		if(isCoreModule(cleanPath)) {
			return createObject("component","lib.#cleanPath#");
		} else if (isPath) {
			if(isDir(fullPath)) {
				
				load_as_directory(fullPath);
			} else if (isFile(fullPath)) {
				load_as_file(fullPath);
			} else {
				load_foundry_modules();
			}
		} else {

		}
		// 1. If X is a core module,
		//    a. return the core module
		//    b. STOP
		// 2. If X begins with './' or '/' or '../'
		//    a. LOAD_AS_FILE(Y + X)
		//    b. LOAD_AS_DIRECTORY(Y + X)
		// 3. LOAD_NODE_MODULES(X, dirname(Y))
		// 4. THROW "not found"
	}
	private any function isCoreModule(x) {
		if(listFindNoCase(this.core_modules,x)) return true;

		return false;
	}
	private any function load_as_file(x) {
		// 1. If X is a file, load X as JavaScript text.  STOP
		// 2. If X.js is a file, load X.js as JavaScript text.  STOP
		// 3. If X.node is a file, load X.node as binary addon.  STOP
	}

	private any function load_as_directory(x) {
		// 1. If X/package.json is a file,
		//    a. Parse X/package.json, and look for "main" field.
		//    b. let M = X + (json main field)
		//    c. LOAD_AS_FILE(M)
		// 2. If X/index.js is a file, load X/index.js as JavaScript text.  STOP
		// 3. If X/index.node is a file, load X/index.node as binary addon.  STOP
	}

	private any function load_foundry_modules(x,start) {
		var dirs = foundry_modules_paths(start);
		for (dir in dirs) {
			if(isDir(fullPath)) {
				load_as_directory(fullPath);
			} else if (isFile(fullPath)) {
				load_as_file(fullPath);
			}
		}
		// 1. let DIRS=NODE_MODULES_PATHS(START)
		// 2. for each DIR in DIRS:
		// 	a. LOAD_AS_FILE(DIR/X)
		// 	b. LOAD_AS_DIRECTORY(DIR/X)
	}

	private any function foundry_modules_paths(start) {
		var parts = start.splitPath();
		// 1. let PARTS = path split(START)
		// 2. let ROOT = index of first instance of "node_modules" in PARTS, or 0
		// 3. let I = count of PARTS - 1
		// 4. let DIRS = []
		// 5. while I > ROOT,
		//    a. if PARTS[I] = "node_modules" CONTINUE
		//    c. DIR = path join(PARTS[0 .. I] + "node_modules")
		//    b. DIRS = DIRS + DIR
		//    c. let I = I - 1
		// 6. return DIRS
	}

	private void function cacheModule() {

	}

	private boolean function isFile(x) {
		var fileInfo = getFileInfo(expandPath(x));

		if(fileInfo.type EQ "file") return true;

		return false;
	}

	private boolean function isDir(x) {
		var fileInfo = getFileInfo(expandPath(x));

		if(fileInfo.type EQ "directory") return true;

		return false;
	}

	public any function noop() {};

}