<cfscript>
/*TODO: Needs to be more accepting of other types of objects.
...
if function then
    attach just that function to the module;
if component then
    attach all functions to the module;
...
*/
private any function mixin(x/*,args*/){
	include "./path.cfm";
	var objTo = this;
	var objFrom = require(x);
	var objName = path.basename(x);
	
	_.each(objFrom, function(val, key, obj) {
		if(key EQ "init") key = UCASE('#objName#_init');
		objTo[key] = val;
		objTo['_mixins'] = (structKeyExists(objTo,'_mixins'))? objTo._mixins : [];

		objTo._mixins.add(key);
	});
}
</cfscript>