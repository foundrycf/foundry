component name="ArrayComponent" {
	public ArrayComponent function init(Array ary = []) {
		this['arr'] = arguments.ary;
		this['utils'] = createObject("java","org.apache.commons.lang.ArrayUtils");

		return this;
	}

	public numeric function length() {
		return arrayLen(this.arr);
	}

	public array function slice() {
		var argCount = listLen(structKeyList(arguments));
		
		return this.arr.subList();
	}

	public array function reverse() {
	    var outArray = ArrayNew(1);
	    var i=0;
	    var j = 1;
	    for (i=ArrayLen(this.arr); i GT 0;i--){
	        outArray[j] = this.arr[i];
	        j++;
	    }

	    return outArray;
	}
	
	public any function replace(other_ary) {
		this.arr = arguments.other_ary;

		return this;
	}

	//removes the last element of the array and returns it
	public any function pop() {
		var lastElement = this.arr[arrayLen(this.arr)];
		arrayDeleteAt(this.arr,arrayLen(this.arr));
		return lastElement;
	}

	//removes the first element of the array and returns it
	public any function shift() {
		var firstElement = this.arr[1];
		arrayDeleteAt(this.arr,1);
		return firstElement;
	}

	public numeric function indexOf(any obj) {
		return arrayFind(this.arr,obj);
	}
}