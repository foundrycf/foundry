component name="pathTests" extends="mxunit.framework.testcase" {
	

	public void function test_basename() {
		//path.basename('/this/is/a/test/okay/test-path.cfc');
		assertEquals( 'test-path.cfc',path.basename(f));
		assertEquals( 'test-path',path.basename(f, '.cfc'));

		// POSIX filenames may include control characters
		// c.f. http://www.dwheeler.com/essays/fixing-unix-linux-filenames.html
		// if (!isWindows) {
		// 	var controlCharFilename = 'Icon' + String.fromCharCode(13);
		// 	assertEquals(path.basename('/a/b/' + controlCharFilename),
		// 	controlCharFilename);
		// }
	}

	public void function test_extname() {
		assertEquals( '.cfc',path.extname(f));

		assertEquals( '',path.extname(''));
		assertEquals( '',path.extname('/path/to/file'));
		assertEquals( '.ext',path.extname('/path/to/file.ext'));
		assertEquals( '.ext',path.extname('/path.to/file.ext'));
		assertEquals( '',path.extname('/path.to/file'));
		assertEquals( '',path.extname('/path.to/.file'));
		assertEquals( '.ext',path.extname('/path.to/.file.ext'));
		assertEquals( '.ext',path.extname('/path/to/f.ext'));
		assertEquals( '.ext',path.extname('/path/to/..ext'));
		assertEquals( '',path.extname('file'));
		assertEquals( '.ext',path.extname('file.ext'));
		assertEquals( '',path.extname('.file'));
		assertEquals( '.ext',path.extname('.file.ext'));
		assertEquals( '',path.extname('/file'));
		assertEquals( '.ext',path.extname('/file.ext'));
		assertEquals( '',path.extname('/.file'));
		assertEquals( '.ext',path.extname('/.file.ext'));
		assertEquals( '.ext',path.extname('.path/file.ext'));
		assertEquals( '.ext',path.extname('file.ext.ext'));
		assertEquals( '.',path.extname('file.'));
		assertEquals( '',path.extname('.'));
		assertEquals( '',path.extname('./'));
		assertEquals( '.ext',path.extname('.file.ext'));
		assertEquals( '',path.extname('.file'));
		assertEquals( '.',path.extname('.file.'));
		assertEquals( '.',path.extname('.file..'));
		assertEquals( '',path.extname('..'));
		assertEquals( '',path.extname('../'));
		assertEquals( '.ext',path.extname('..file.ext'));
		assertEquals( '.file',path.extname('..file'));
		assertEquals( '.',path.extname('..file.'));
		assertEquals( '.',path.extname('..file..'));
		assertEquals( '.',path.extname('...'));
		assertEquals( '.ext',path.extname('...ext'));
		assertEquals( '.',path.extname('....'));
		assertEquals( '',path.extname('file.ext/'));
		if (isWindows) {
		  // On windows, backspace is a path separator.
		  assertEquals( '',path.extname('.\\'));
		  assertEquals( '',path.extname('..\\'));
		  assertEquals( '',path.extname('file.ext\\'));
		} else {
		  // On unix, backspace is a valid name component like any other character.
		  assertEquals( '',path.extname('.\\'));
		  assertEquals( '.\\',path.extname('..\\'));
		  assertEquals( '.ext\\',path.extname('file.ext\\'));
		}
	}

	public void function test_dirname() {
		// var simplePath = isWindows ? 'test\\simple' : 'test/simple';
		// assertEquals(simplePath ,path.dirname(f));
		assertEquals( '/a',path.dirname('/a/b/'));
		assertEquals( '/a',path.dirname('/a/b'));
		assertEquals( '/',path.dirname('/a'));
		assertEquals( '/',path.dirname('/'));

		if (isWindows) {
			assertEquals( 'c:\',path.dirname('c:\'));
			assertEquals( 'c:\',path.dirname('c:\foo'));
			assertEquals( 'c:\',path.dirname('c:\foo\'));
			assertEquals( 'c:\foo',path.dirname('c:\foo\bar'));
			assertEquals( 'c:\foo',path.dirname('c:\foo\bar\'));
			assertEquals( 'c:\foo\bar',path.dirname('c:\foo\bar\baz'));
			assertEquals( '\',path.dirname('\'));
			assertEquals( '\',path.dirname('\foo'));
			assertEquals( '\',path.dirname('\foo\'));
			assertEquals( '\foo',path.dirname('\foo\bar'));
			assertEquals( '\foo',path.dirname('\foo\bar\'));
			assertEquals( '\foo\bar',path.dirname('\foo\bar\baz'));
			assertEquals( 'c:',path.dirname('c:'));
			assertEquals( 'c:',path.dirname('c:foo'));
			assertEquals( 'c:',path.dirname('c:foo\'));
			assertEquals( 'c:foo',path.dirname('c:foo\bar'));
			assertEquals( 'c:foo',path.dirname('c:foo\bar\'));
			assertEquals( 'c:foo\bar',path.dirname('c:foo\bar\baz'));
			assertEquals( '\\unc\share',path.dirname('\\unc\share'));
			assertEquals( '\\unc\share\',path.dirname('\\unc\share\foo'));
			assertEquals( '\\unc\share\',path.dirname('\\unc\share\foo\'));
			assertEquals(path.dirname('\\unc\share\foo\bar'),
			       '\\unc\share\foo');
			assertEquals(path.dirname('\\unc\share\foo\bar\'),
			       '\\unc\share\foo');
			assertEquals(path.dirname('\\unc\share\foo\bar\baz'),
		       '\\unc\share\foo\bar');
		}
	}

	public void function test_join() {
		// path.join tests
		var failures = [];
		var joinTests =
		    // arguments                     result
		    [[['.', 'x/b', '..', '/b/c.js'], 'x/b/c.js'],
		     [['/.', 'x/b', '..', '/b/c.js'], '/x/b/c.js'],
		     [['/foo', '../../../bar'], '/bar'],
		     [['foo', '../../../bar'], '../../bar'],
		     [['foo/', '../../../bar'], '../../bar'],
		     [['foo/x', '../../../bar'], '../bar'],
		     [['foo/x', './bar'], 'foo/x/bar'],
		     [['foo/x/', './bar'], 'foo/x/bar'],
		     [['foo/x/', '.', 'bar'], 'foo/x/bar'],
		     [['./'], './'],
		     [['.', './'], './'],
		     [['.', '.', '.'], '.'],
		     [['.', './', '.'], '.'],
		     [['.', '/./', '.'], '.'],
		     [['.', '/////./', '.'], '.'],
		     [['.'], '.'],
		     [['', '.'], '.'],
		     [['', 'foo'], 'foo'],
		     [['foo', '/bar'], 'foo/bar'],
		     [['', '/foo'], '/foo'],
		     [['', '', '/foo'], '/foo'],
		     [['', '', 'foo'], 'foo'],
		     [['foo', ''], 'foo'],
		     [['foo/', ''], 'foo/'],
		     [['foo', '', '/bar'], 'foo/bar'],
		     [['./', '..', '/foo'], '../foo'],
		     [['./', '..', '..', '/foo'], '../../foo'],
		     [['.', '..', '..', '/foo'], '../../foo'],
		     [['', '..', '..', '/foo'], '../../foo'],
		     [['/'], '/'],
		     [['/', '.'], '/'],
		     [['/', '..'], '/'],
		     [['/', '..', '..'], '/'],
		     [[''], '.'],
		     [['', ''], '.'],
		     [[' /foo'], ' /foo'],
		     [[' ', 'foo'], ' /foo'],
		     [[' ', '.'], ' '],
		     [[' ', '/'], ' /'],
		     [[' ', ''], ' '],
		     // filtration of non-strings.
		     [['x', true, 7, 'y', "", {}], 'x/y']
		    ];
		_.forEach(joinTests,function(test) {
			//console.log("===========");
			//writeDump(var=test[1],abort=true);
		  var actual = path.join(argumentcollection=test[1]);
		  var expected = path.fixSeps(test[2]);
		  var message = 'path.join(' & serialize(test[1]) & ')' &
		                '<br />  expect=' & serialize(expected) &
		                '<br />  actual=' & serialize(actual);

			//console.log("testing: " & message)

		  if (actual NEQ expected) failures.add('<br />' & message);
		 	//assertEquals(expected ,actual);

			//console.log("===========");
		});
		assertEquals( 0,arrayLen(failures), arrayToList(failures,''));
	}
	
	public void function test_normalize() {
		// path normalize tests
		if (isWindows) {
		  assertEquals(path.normalize('./fixtures//b/../b/c.js'),
		               'fixtures\b\c.js');
		  assertEquals( '\bar',path.normalize('/foo/../../../bar'));
		  assertEquals( 'a\b',path.normalize('a//b//../b'));
		  assertEquals( 'a\b\c',path.normalize('a/b/./c'));
		  assertEquals( 'a\b',path.normalize('a/b/.'));
		  assertEquals(path.normalize('//server/share/dir/file.ext'),
		               '\\server\share\dir\file.ext');
		} else {
		  assertEquals(path.normalize('./fixtures//b/../b/c.js'),
		               'fixtures/b/c.js');
		  assertEquals( '/bar',path.normalize('/foo/../../../bar'));
		  assertEquals( 'a/b',path.normalize('a//b//../b'));
		  assertEquals( 'a/b/c',path.normalize('a//b//./c'));
		  assertEquals( 'a/b',path.normalize('a//b//.'));
		}

	}

	public void function test_resolve() {
		// path.resolve tests
		if (isWindows) {
		  // windows
		  var resolveTests =
		      // arguments                                    result
		      [[['c:/ignore', 'd:\a/b\c/d', '\e.exe'], 'd:\e.exe']];
		} else {
		  // Posix
		  var resolveTests = 
		      // arguments                                    result
		      [[['a/b/c/', '../../..'], cwd],
		      	[['/var/lib', '../', 'file/'], '/var/file'],
		       [['/var/lib', '/../', 'file/'], '/file'],
		       
		       [['.'], cwd],
		       [['/some/dir', '.', '/absolute/'], '/absolute']];
		}
		var failures = [];
		_.forEach(resolveTests,function(test) {
		  var actual = path.resolve(argumentCollection=test[1]);
		  var expected = test[2];
		   var message = 'path.resolve(' & serialize(test[1]) & ')' &
		                '<br />  expect=' & serialize(expected) &
		                '<br />  actual=' & serialize(actual);
		  if (actual NEQ expected) failures.add('<br />' & message);
		//assertEquals(expected, actual, message);
		});
		assertEquals(0,arrayLen(failures),arrayToList(failures,''));
	}
	
	// public void function test_relative() {
	// 	// path.relative tests
	// 	if (isWindows) {
	// 	  // windows
	// 	  var relativeTests =
	// 	      // arguments                     result
	// 	      [['c:/blah\\blah', 'd:/games', 'd:\\games'],
	// 	       ['c:/aaaa/bbbb', 'c:/aaaa', '..'],
	// 	       ['c:/aaaa/bbbb', 'c:/cccc', '..\\..\\cccc'],
	// 	       ['c:/aaaa/bbbb', 'c:/aaaa/bbbb', ''],
	// 	       ['c:/aaaa/bbbb', 'c:/aaaa/cccc', '..\\cccc'],
	// 	       ['c:/aaaa/', 'c:/aaaa/cccc', 'cccc'],
	// 	       ['c:/', 'c:\\aaaa\\bbbb', 'aaaa\\bbbb'],
	// 	       ['c:/aaaa/bbbb', 'd:\\', 'd:\\']];
	// 	} else {
	// 	  // posix
	// 	  var relativeTests =
	// 	      // arguments                    result
	// 	      [['/var/lib', '/var', '..'],
	// 	       ['/var/lib', '/bin', '../../bin'],
	// 	       ['/var/lib', '/var/lib', ''],
	// 	       ['/var/lib', '/var/apache', '../apache'],
	// 	       ['/var/', '/var/lib', 'lib'],
	// 	       ['/', '/var/lib', 'var/lib']];
	// 	}
	// 	var failures = [];
	// 	relativeTests.forEach(function(test) {
	// 	  var actual = path.relative(test[1], test[2]);
	// 	  var expected = test[3];
	// 	  var message = 'path.relative(' +
	// 	                test.slice(0, 2).map(JSON.stringify).join(',') +
	// 	                ')' +
	// 	                '\n  expect=' + JSON.stringify(expected) +
	// 	                '\n  actual=' + JSON.stringify(actual);
	// 	  if (actual !== expected) failures.push('\n' + message);
	// 	});
	// 	assertEquals( failures.join(''),failures.length, 0);

	// }
	

	public void function test_sep() {
		// path.sep tests
		if (isWindows) {
		    // windows
		    assertEquals( '\',path.sep());
		} else {
		    // posix
		    assertEquals( '/',path.sep());
		}
	}


	public void function setUp() {
		variables.f = "test-path.cfc";
		//variables.common = require('../common');
		//variables.assert = require('assert');
		variables.cwd = left(expandPath('/'),len(expandPath('/'))-1);
		variables._ = new core.util();
		variables.console = new core.console();
		variables.path = new core.path();

		variables.isWindows = (server.os.name CONTAINS 'windows');

		//variables.f = __filename;
		console.log("===================");
	}
	
	public void function tearDown() {
		console.log("===================");

	}
	
	

}