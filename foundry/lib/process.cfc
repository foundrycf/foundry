component {
	
	public any function init() {
		variables.system = CreateObject("java", "java.lang.System");

		return this;
	}

	public any function env(x) {
		return system.getenv().get(x);
	}

	public any function pid() {
		var runtimeMxBean = createObject("java","java.lang.management.ManagementFactory").getRuntimeMXBean();

		return runtimeMxBean.getName();
	}
}