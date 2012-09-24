component name="config" {
	/**
	* @name name
	* @type string
	* @required true
	* @hint The unique name of your package.
	**/
	property name="name";

	/**
	* @name preferGlobal
	* @type boolean
	* @required false
	* @hint Version of the package as specified by <a href="http://semver.org/">Semantic Versioning</a>.
	**/
	property name="preferGlobal";

	/**
	* @name version
	* @type boolean
	* @required false
	* @hint Version of the package as specified by <a href="http://semver.org/">Semantic Versioning</a>.
	**/
	property name="version";

	/**
	* @name author
	* @type string
	* @required false
	* @hint The author of the project.
	**/
	property name="author";

	/**
	* @name description
	* @type string
	* @required false
	* @hint The description of the project.
	**/
	property name="description";

	/**
	* @name contributors
	* @type array
	* @required false
	* @hint An array of structures representing contributors to the project.
	**/
	property name="contributors";

	/**
	* @name bin
	* @type struct
	* @required false
	* @hint An structure containing key/pair mappings of binary script names and cf script paths. 
	**/
	property name="bin";

	/**
	* @name scripts
	* @type string
	* @required false
	* @hint A structure containing key/pair mappings of foundry modules and cf script paths. 
	**/
	property name="scripts";

	/**
	* @name main
	* @type string
	* @required false
	* @hint The main entry point of the package.<br /><br />When calling require('module_name') in Foundry this is the file that will actually be required.
	**/
	property name="main";

	/**
	* @name repository
	* @type struct
	* @required false
	* @hint A structure containing key/pair mappings of source code repositories. 
	* @example &quot;repository&quot;: {<br/>&quot;type&quot;: &quot;git&quot;,<br/>&quot;url&quot;: &quot;https://github.com/nodejitsu/http-server.git&quot;<br/>}
	**/
	property name="repository";

	/**
	* @name keywords
	* @type array
	* @required false
	* @hint An array of keywords which describe your package. 
	**/
	property name="keywords";

	/**
	* @name dependencies
	* @type struct
	* @required false
	* @hint A structure containing key/pair mappings of foundry packages and versions that this project depends on. 
	* @example {<br />&quot;colors&quot;   :  &quot;*&quot;,<br />&quot;flatiron&quot; :  &quot;0.1.x&quot;,<br />&quot;optimist&quot; :  &quot;0.2.x&quot;,<br />&quot;union&quot;    :  &quot;0.1.x&quot;,<br />&quot;ecstatic&quot; :  &quot;0.1.x&quot;,<br />&quot;plates&quot;   :  &quot;https://github.com/flatiron/plates/tarball/master&quot;<br />}
	**/
	property name="dependencies";

	/**
	* @name license
	* @type string
	* @required false
	* @hint The license which you prefer to release your project under.<br /><br /><a href="http://en.wikipedia.org/wiki/MIT_License">MIT</a> is a good choice.
	**/
	property name="license";

	/**
	* @name engines
	* @type struct
	* @required false
	* @hint A struct containing key/pair mappings of engine versions.<br /><br />This is used to specify the versions of CFML and Foundry your package is known to work correctly with.
	* @example { <br />&quot;foundry&quot;: &quot;>=0.6&quot;<br />&quot;railo&quot;: &quot;>=3.1.x&quot;<br />&quot;adobe&quot;: &quot;>=9.x.x&quot; <br />}
	**/
	property name="engines";

	public any function init(params) {
		structAppend(this,params,true);
		variables.Path = new Path();
		this.validate();

		return this;
	}

	public void function validate() {
		var requiredProps = "name,version";

		if(left(Path.basename(this.main),3) NEQ "cfc") {
			this.main &= ".cfc";
		}
	}
}