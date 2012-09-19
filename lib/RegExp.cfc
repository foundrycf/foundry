component accessors=true {
	property type="string" 
	name="pattern"
	getter=true
	setter=true;

	public any function init(required pattern, global = false, insensitive = false) {
		this.setPattern(arguments.pattern);
		this.insensitive = arguments.insensitive;
		this.global = arguments.global;
		variables.console = new cf_modules.Console.Console();
	}

	public any function test(str) {
		var matches = [];

		if(this.insensitive) {
			matches = REMatchGroups(arguments.str,this.getPattern());
		} else {
			matches = REMatchGroups(arguments.str,this.getPattern());
		}

		if(arrayLen(matches) GT 0) {
			return true;
		} else {
			matches = REMatch(this.getPattern(),arguments.str);

			if(arrayLen(matches) GT 0) {
			
				return true;
			}

			return false;
		}
	}

	public any function escaped() {
		var ptrn = this.getPattern();
		return rereplacenocase("([.?*+^$[\]\\(){}|-])", "\\\1","all");
	}

	/**
	* REMatchGroups UDF
	* @Author Ben Nadel <http://bennadel.com/>
	*/
	private array function REMatchGroups(text,pattern,scope = "all") {
		var local = structnew();
		local.results = ArrayNew(1);
		local.pattern =createobject( "java", "java.util.regex.Pattern" ).compile( javacast( "string", arguments.pattern ) );
		
		local.matcher =local.pattern.matcher( javacast( "string", arguments.text ) );
		
		while (local.Matcher.Find()) {
			local.groups = structnew();
			
			for(local.GroupIndex=0; local.GroupIndex <= local.Matcher.GroupCount();LOCAL.GroupIndex++) {
				local.results.add(local.matcher.group(javacast( "int", local.groupindex )));
			}
			
			if(arguments.scope EQ "one") {
				break;
			}
			
		}

		return local.results;
	}

}