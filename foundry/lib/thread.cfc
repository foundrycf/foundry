component name="thread" extends="foundry.lib.module" {
	property name="name" type="string";
	property name="priority" type="string";
	property name="status" type="string";

	public any function init(name = "",) {
		this._thread = createObject("java","java.lang.Thread").init();

		return this;
	}

	public any function run() {
		this._thread.start();
	}

	public any function getter(prop) {
		var func = this._thread['get#prop#'];
		return func();
	}
}