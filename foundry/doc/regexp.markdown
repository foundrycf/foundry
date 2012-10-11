#RegExp
If you have ever used Regular Expressions in JavaScript, this is an implementation of the RegExp `class` from JS.

It's not 100% yet, but it'll get you by if you like this kind of syntax.

Use this module with `var myExp = new RegExp('^(exp|ress|ion)$')`.


##RegExp.match(str)
Returns matched groups in a structure with keys starting at 0.
This may change eventually but for now that's how it's working.
It is based on REMatchGroups UDF from [Ben Nadel](http://bennadel.com).

##RegExp.replace(str,replacement)
Replacement can be a regular expression, or a function expression.
It works like the JS function except that the regex pattern used is the one provided during instantiation or by using the setPattern() function first.

```
var myExp = new foundry.core.RegExp('^(exp|ress|ion)$');

replaced = myExp.replace('something','/1 /2 what up'); 
//works like reReplace except the initial expression is passed with the constructor.

//or with a function expression
replaced = myExp.replace('something',function(match1,match2,match3,/* matchN */) {
	//each argument is a different matched group from the main expressions.
	//this function is called once with 1 argument per match group.

	return strToReplacement;
});

##RegExp.split(str)
Splits `str` by the RegExp object's pattern provided with the constructor
and return an array.

```
myExp = new foundry.core.regexp('\/');

myExp.split('my/string/is/cool');
//returns
['my','string','is','cool']
```

This is also something taken from [Ben Nadel](http://bennadel.com)s blog.