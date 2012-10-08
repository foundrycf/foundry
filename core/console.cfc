/**
* @name "Console.cfc"
* @author "Joshua F. Rountree"
*
*/
component {
	public any function init(prefix = "",opts = {}) {
		var jarPaths = [];
		variables._ = new Util();
		this.prefix = prefix;
		jarPaths.add("/Users/rountrjf/Sites/foundry/deps/jansi-1.9.jar");
		variables.loader = createObject("component","foundry.deps.javaloader.JavaLoader").init(jarPaths);
    	//writeDump(var=ansi,abort=true);
		variables.AnsiConsole = loader.create("org.fusesource.jansi.AnsiConsole");
		variables.Ansi = loader.create("org.fusesource.jansi.Ansi").init();
		this.Colors = loader.create("org.fusesource.jansi.Ansi$Color");
		AnsiConsole.systemInstall();
		variables.System = createObject("java","java.lang.System");
		
		return this;
	}

	public any function log(obj) {
		return print("[" & timeFormat(now(),"hh:mm:ss") & "] " & obj);
	}

	public any function info(obj) {
    	return print("@|bold,white INFO|@ @|white " & obj & "|@");
	}

	public any function config(obj) {
    	return print("@|bold,magenta CONFIG|@ @|magenta " & obj & "|@");
	}

	public any function error(obj) {
    	return print("@|bold,red ERROR|@ @|red " & obj & "|@");
	}

	public any function warning(obj) {
    	return print("@|bold,yellow WARNING|@ @|yellow " & obj & "|@");
	}

	public any function print(str) {
		return System.out.println(this.prefix & Ansi.ansi().render(str));
	}
}