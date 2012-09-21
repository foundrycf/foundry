component name="StructComponent" {
	public any function init() {
		this.__struct__ = {};

		return this;
	}

	public any function length() {
		return listLen(structKeyList(this.__struct__));
	}

	public any function clear() {
		this.__struct__ = {};
	}

	public any function delete(key) {
		structDelete(this.__struct__,arguments.key);
	}

	public any function keys_list() {
		return structKeyList(this.__struct__);
	}
	
	public any function each_key(fn) {
		var keys = this.keys_list();
		var key = "";
		var fnArgs = {};
		for(var i=1; i <= this.length(); i++) {
			key = keys[i];
			fnArgs = {};
			fnArgs[1] = this.__struct__[key];

			fn(argumentCollection = fnArgs);
		}
	}
}