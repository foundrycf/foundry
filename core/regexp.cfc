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
		variables._ = new foundry.core.util();
		variables.console = new foundry.core.Console();

		return this;
	}

	public any function test(str) {
		var matches = {};
		console.print("testing: " & serialize(str));
		if(this.insensitive) {
			matches = this.match(arguments.str);
		} else {
			matches = this.match(arguments.str);
		}

		if(structCount(matches) GT 0) {
			return true;
		} else {
			matches = REMatchNoCase(this.getPattern(),arguments.str);

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
		var result = text;

		if(_.isFunction(replacement)) {
			var matches = this.match(text);
			if(structCount(matches) GT 0) {
				var args = [];
				for(var i=0; i <= structCount(matches); i++) {
					if(structKeyExists(matches,i)) {
						var match = matches[i];
					} else {
						var match = "";
					}
					args.add(match);
				}
				var repResult = replacement(argumentCollection=arrayCollection(args));
				var result = rereplaceNoCase(text,this.getPattern(),repResult);
			}
		} else {
			var result = reReplaceNoCase(text,this.getPattern(),replacement)
		}

		return result;
	}

	/**
	* reSplit UDF
	* @Author Ben Nadel <http://bennadel.com/>
	*/
	public any function split(value) {
		var local = {};
		local.result = [];
		local.parts = javaCast( "string", arguments.value ).split(
			javaCast( "string", this.getPattern() ),
			javaCast( "int", -1 )
		);

		for (local.part in local.parts) {
			arrayAppend(local.result,local.part );
		};

		return local.result;
	}

	/**
	* arrayCollection UDF
	*  @Author Ben Nadel <http://bennadel.com/>
	*/
	public struct function arrayCollection(array arr) {
		var local = {};
		local.keys = createObject( "java", "java.util.LinkedHashMap" ).init();

		for(var i=1; i <= arrayLen(arguments.arr); i++) {
			if (arrayIsDefined( arguments.arr, i)) {
				local.keys.put(javaCast( "string", i),arguments.arr[i]);
			};
		};
	 
		return local.keys;
	}

}