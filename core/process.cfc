component name="foundry.core.process" {
	variables.system = CreateObject("java", "java.lang.System");

	public any function env(x) {
		return system.getenv().get(x);
	}

	public any function pid() {
		var runtimeMxBean = createObject("java","java.lang.management.ManagementFactory").getRuntimeMXBean();

		return runtimeMxBean.getName();
	}
}