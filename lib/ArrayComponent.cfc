component name="ArrayComponent" {
	public ArrayComponent function init() {
		this['arr'] = [];
		this['utils'] = createObject("java","org.apache.commons.lang.ArrayUtils");

		return this;
	}

	public numeric function length() {
		return arrayLen(this.__arr__);
	}

	public array function slice() {
		var argCount = listLen(structKeyList(arguments));
		
		return this.__arr__.subList();
	}

	public array function reverse() {
	    var outArray = ArrayNew(1);
	    var i=0;
	    var j = 1;
	    for (i=ArrayLen(this.__arr__); i GT 0;i--){
	        outArray[j] = this.__arr__[i];
	        j++;
	    }

	    return outArray;
	}
	
	public any function replace(other_ary) {
		this.__arr__ = arguments.other_ary;
	}
}