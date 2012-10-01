/**
* @name "Console.cfc"
* @author "Joshua F. Rountree"
*
*/
component {
	variables.System = createObject("java","java.lang.System");
	public any function init(opts = {}) {
		
		return this;
	}

	public any function log(obj) {
		savecontent variable="output" { writeDump(var=obj,format="text"); }
    	return System.out.println("[" & timeFormat(now(),"hh:mm:ss") & "] " & removeHtml(output));
	}

	public any function info(obj) {
		return System.out.println("INFO: " & obj);
	}

	public any function config(obj) {
		return System.out.println("CONFIG: " & obj);
	}

	public any function error(obj) {
		return System.out.println("ERROR: " & obj);
	}

	public any function warning(obj) {
		return System.out.println("WARN: " & obj);
	}

	public any function print(str) {
		return System.out.println(str);
	}
	private any function removeHTML(source){
		
		// Remove all spaces becuase browsers ignore them
		var result = ReReplace(trim(source), "[[:space:]]{2,}", " ","ALL");
		
		// Remove the header
		result = ReReplace(result, "<[[:space:]]*head.*?>.*?</head>","", "ALL");
		
		// remove all scripts
		result = ReReplace(result, "<[[:space:]]*script.*?>.*?</script>","", "ALL");
		
		// remove all styles
		result = ReReplace(result, "<[[:space:]]*style.*?>.*?</style>","", "ALL");
		
		// insert tabs in spaces of <td> tags
		result = ReReplace(result, "<[[:space:]]*td.*?>","	", "ALL");
		
		// insert line breaks in places of <BR> and <LI> tags
		result = ReReplace(result, "<[[:space:]]*br[[:space:]]*>",chr(13), "ALL");
		result = ReReplace(result, "<[[:space:]]*li[[:space:]]*>",chr(13), "ALL");
		
		// insert line paragraphs (double line breaks) in place
		// if <P>, <DIV> and <TR> tags
		result = ReReplace(result, "<[[:space:]]*div.*?>",chr(13), "ALL");
		result = ReReplace(result, "<[[:space:]]*tr.*?>",chr(13), "ALL");
		result = ReReplace(result, "<[[:space:]]*p.*?>",chr(13), "ALL");
		
		// Remove remaining tags like <a>, links, images,
		// comments etc - anything thats enclosed inside < >
		result = ReReplace(result, "<.*?>","", "ALL");
		
		// replace special characters:
		result = ReReplace(result, "&nbsp;"," ", "ALL");
		result = ReReplace(result, "&bull;"," * ", "ALL");    
		result = ReReplace(result, "&lsaquo;","<", "ALL");        
		result = ReReplace(result, "&rsaquo;",">", "ALL");        
		result = ReReplace(result, "&trade;","(tm)", "ALL");        
		result = ReReplace(result, "&frasl;","/", "ALL");        
		result = ReReplace(result, "&lt;","<", "ALL");        
		result = ReReplace(result, "&gt;",">", "ALL");        
		result = ReReplace(result, "&copy;","(c)", "ALL");        
		result = ReReplace(result, "&reg;","(r)", "ALL");    
		
		// Remove all others. More special character conversions
		// can be added above if needed
		result = ReReplace(result, "&(.{2,6});", "", "ALL");    
		result = trim(result);
		// Thats it.
		return result;

	}
}