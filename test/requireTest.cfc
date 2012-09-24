component name="requireTest" extends="mxunit.framework.TestCase" {
	FIXTURE_ROOT = expandPath("/test/fixtures");
	import "fixtures.my_module";
	public void function require_should_return_fake_module1() {
		var my_module = new my_module();
		my_module.requires_fake_module1();

		writeDump(var=my_module,abort=true);
	}

	public void function stat_should_be_the_same_fileinfo_2() {
		//assertEquals(getFileInfo(fixture_path("app/views")),trail.stat(fixture_path("app/views")));
	}

	public void function stat_should_be_empty_struct() {
		//assertEquals({},trail.stat(fixture_path("app/views/missing.html")));
	}

	public void function setUp() {
		variables.console = new lib.console();
		console.log("==============");
	}

	public void function tearDown() {
		console.log("==============");
		structDelete(variables,'console');
	}

	private any function fixture_path(path) {
		//return variables.Path.join(FIXTURE_ROOT, path);
	}
	
}