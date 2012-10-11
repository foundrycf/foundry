component name="my_module" extends="foundry.lib.module" {
	public any function init() {
		var fake_module1 = require("fake_module1");
		mixin("emitter");
		this.emitter_init();
		//variables.emitter = require("emitter");

		this.on("test",function() {
			writeOutput("test called!");
		});

		return this;
	}
}