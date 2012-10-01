/**
* @name RegExp
* @hint a class representing a regular expression
**/
component name="RegExp" accessors=true {
	property type="string" 
	name="pattern"
	getter=true
	setter=true;

	public any function init(required pattern, global = false, insensitive = false) {
		this.setPattern(arguments.pattern);
		this.insensitive = arguments.insensitive;
		this.global = arguments.global;
		variables.console = new foundry.core.Console();
	}

	public any function test(str) {
		var matches = {};

		if(this.insensitive) {
			matches = this.match(arguments.str);
		} else {
			matches = this.match(arguments.str);
		}

		if(structCount(matches) GT 0) {
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
	public array function match(text,scope = "all") {
		var local = structnew();
		local.results = ArrayNew(1);
		local.GROUPS = {};
		local.pattern =createobject( "java", "java.util.regex.Pattern" ).compile( javacast( "string", this.getPattern()));
		
		local.matcher =local.pattern.matcher( javacast( "string", arguments.text ) );
		
		while (local.Matcher.Find()) {
			local.groups = structnew();
			
			for(local.GroupIndex=0; local.GroupIndex <= local.Matcher.GroupCount();LOCAL.GroupIndex++) {
				LOCAL.Groups[ LOCAL.GroupIndex ] = LOCAL.Matcher.Group(JavaCast( "int", LOCAL.GroupIndex ));
				local.results.add(local.matcher.group(javacast( "int", local.groupindex )));
			}
			if(arguments.scope EQ "one") {
				break;
			}
			
		}

		return LOCAL.Groups;
	}

	public any function replace(text,replacement) {
		return reReplace(text,this.getPattern(),replacement);
	}

}