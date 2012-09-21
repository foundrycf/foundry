component name="my_module" extends="Foundry.Module" {
	public any function doSomething() {
		return true;
	}

	public any function requires_fake_module1() {
		var fake_module1 = require("fake_module1");
		
		return false;
	}

	public any function getMeSomething() {
		return {
			"something":1,
			"somethingElse":"Nope!"
		};
	}
}