component name="fs" {
	public any function exists(p,cb) {
		if(fileExists(arguments.p)) {
			exists = true;
		} else {
			exists = false;
		}

		cb(exists);
	}

	public any function readFile(p,charset = 'utf8',cb) {
		var err = {};
		
		try {
			fileRead(p);
		} catch(any err) {
			cb(err, contents);
			return false;
		}

		cb(err, contents);
	}
}