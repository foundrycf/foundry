component name="common" {
	function runCallChecks() {
	  var failed = mustCallChecks.filter(function(context) {
	    return (context.actual NEQ context.expected);
	  });

	  failed.forEach(function(context) {
	    console.log('Mismatched %s function calls. Expected %d, actual %d.',
	                context.name,
	                context.expected,
	                context.actual);
	    console.log(context.stack.split('\n').slice(2).join('\n'));
	  });

	  if (failed.length) process.exit(1);
	}



	public any function mustCall(fn, expected) {
	  if (!isNumeric(expected)) expected = 1;

	  var context = {
	    expected: arguments.expected,
	    actual: 0,
	    stack: (new Error).stack,
	    name: getMetaData(fn).name || '<anonymous>'
	  };

	  // add the exit listener only once to avoid listener leak warnings
	  if (arrayLen(mustCallChecks) EQ 0) process.on('exit', runCallChecks);

	  mustCallChecks.add(context);

	  return function() {
	    context.actual++;
	    return fn(argumentCollection=arguments);
	  };
	};
}