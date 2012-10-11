<cfscript>
	System = createObject("java", "java.lang.System");
	InputStreamReader = createObject("java","java.io.InputStreamReader");
	BufferedReader = createObject("java","java.io.BufferedReader");
	br = BufferedReader.init(InputStreamReader.init(System.in));
	keepRunning = true;
	script = "";
	while (keepRunning) {
		systemOutput("cfml: ");
		while(isNull(inLine)) {
			inLine = br.readLine();
		}
		args = inLine.split(" ");
		switch(args[1]) {
			case "clear":
				script = "";
				break;

			case "dir": case "ls":
				dir = isNull(args[2]) ? "." : args[2];
				for(dir in directoryList(dir)) {
					systemOutput(dir);
				}
				break;

			case "exit": case "quit": case "q":
				systemOutput("Peace out!");
				keepRunning = false;
				break;

			case "":
				try{
					systemOutput(script);
					systemOutput(evaluate(script));
				} catch (any e) {
					systemOutput("error: " & e.message);
				}
				break;

			default:
				try{
					systemOutput(inLine & " = " & evaluate(inLine));
					script &= inLine;
				} catch (any e) {
					systemOutput("error: " & e.message);
				}
				break;

		}
		inLine = javaCast("null","");
	}
</cfscript>
