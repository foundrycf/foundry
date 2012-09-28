component name="ArrayObj" {
	public ArrayObj function init(Array ary = []) {
		this['arr'] = arguments.ary;
		//this['utils'] = createObject("java","org.apache.commons.lang.ArrayUtils");

		return this;
	}

	public numeric function length() {
		return arrayLen(this.arr);
	}

	public array function slice(required fromIndex,toIndex = 0) {
		if(arguments.toIndex EQ 0) {
			arguments.toIndex = arrayLen(this.arr);
		}
		
		return new arrayObj(this.arr.subList(arguments.fromIndex,arguments.toIndex));
	}

	public arrayObj function splice(required index,required howMany) {
		var items = (structCount(arguments) GT 2)? arguments[3] : [];
		
		var newArr = createObject("java","java.util.Vector");

		newArr.addAll(this.arr);

		if (index < 1) {
 			// negative indices mean position from end of array
 			index = arrayLen(newArr) + index;
 		}

 		var result = [];
 		var left = newArr.subList(0, index - 1);
 		var removedItems = newArr.subList(index-1,(index + howMany)-1);
 		var right = newArr.subList((index + howMany)-1,arrayLen(newArr));
 		result.addAll(left);
 		result.addAll(right);
 		this.arr = result;
 		return new arrayObj(removedItems);
	}

	public void function add(str) {
		this.arr.add(str);
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