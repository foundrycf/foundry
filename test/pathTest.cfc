component name="pathTests" extends="mxunit.framework.testcase" {
	

	public void function test_basename() {
		assertEquals(path.basename(f), 'test-path.js');
		assertEquals(path.basename(f, '.js'), 'test-path');

		// POSIX filenames may include control characters
		// c.f. http://www.dwheeler.com/essays/fixing-unix-linux-filenames.html
		if (!isWindows) {
			var controlCharFilename = 'Icon' + String.fromCharCode(13);
			assertEquals(path.basename('/a/b/' + controlCharFilename),
			controlCharFilename);
		}
	}

	public void function test_extname() {
		assertEquals(path.extname(f), '.js');

		assertEquals(path.extname(''), '');
		assertEquals(path.extname('/path/to/file'), '');
		assertEquals(path.extname('/path/to/file.ext'), '.ext');
		assertEquals(path.extname('/path.to/file.ext'), '.ext');
		assertEquals(path.extname('/path.to/file'), '');
		assertEquals(path.extname('/path.to/.file'), '');
		assertEquals(path.extname('/path.to/.file.ext'), '.ext');
		assertEquals(path.extname('/path/to/f.ext'), '.ext');
		assertEquals(path.extname('/path/to/..ext'), '.ext');
		assertEquals(path.extname('file'), '');
		assertEquals(path.extname('file.ext'), '.ext');
		assertEquals(path.extname('.file'), '');
		assertEquals(path.extname('.file.ext'), '.ext');
		assertEquals(path.extname('/file'), '');
		assertEquals(path.extname('/file.ext'), '.ext');
		assertEquals(path.extname('/.file'), '');
		assertEquals(path.extname('/.file.ext'), '.ext');
		assertEquals(path.extname('.path/file.ext'), '.ext');
		assertEquals(path.extname('file.ext.ext'), '.ext');
		assertEquals(path.extname('file.'), '.');
		assertEquals(path.extname('.'), '');
		assertEquals(path.extname('./'), '');
		assertEquals(path.extname('.file.ext'), '.ext');
		assertEquals(path.extname('.file'), '');
		assertEquals(path.extname('.file.'), '.');
		assertEquals(path.extname('.file..'), '.');
		assertEquals(path.extname('..'), '');
		assertEquals(path.extname('../'), '');
		assertEquals(path.extname('..file.ext'), '.ext');
		assertEquals(path.extname('..file'), '.file');
		assertEquals(path.extname('..file.'), '.');
		assertEquals(path.extname('..file..'), '.');
		assertEquals(path.extname('...'), '.');
		assertEquals(path.extname('...ext'), '.ext');
		assertEquals(path.extname('....'), '.');
		assertEquals(path.extname('file.ext/'), '');

		if (isWindows) {
		  // On windows, backspace is a path separator.
		  assertEquals(path.extname('.\\'), '');
		  assertEquals(path.extname('..\\'), '');
		  assertEquals(path.extname('file.ext\\'), '');
		} else {
		  // On unix, backspace is a valid name component like any other character.
		  assertEquals(path.extname('.\\'), '');
		  assertEquals(path.extname('..\\'), '.\\');
		  assertEquals(path.extname('file.ext\\'), '.ext\\');
		}
	}

	public void function test_dirname() {
		assertEquals(path.dirname(f).substr(-11), isWindows ? 'test\\simple' : 'test/simple');
		assertEquals(path.dirname('/a/b/'), '/a');
		assertEquals(path.dirname('/a/b'), '/a');
		assertEquals(path.dirname('/a'), '/');
		assertEquals(path.dirname('/'), '/');

		if (isWindows) {
			assertEquals(path.dirname('c:\\'), 'c:\\');
			assertEquals(path.dirname('c:\\foo'), 'c:\\');
			assertEquals(path.dirname('c:\\foo\\'), 'c:\\');
			assertEquals(path.dirname('c:\\foo\\bar'), 'c:\\foo');
			assertEquals(path.dirname('c:\\foo\\bar\\'), 'c:\\foo');
			assertEquals(path.dirname('c:\\foo\\bar\\baz'), 'c:\\foo\\bar');
			assertEquals(path.dirname('\\'), '\\');
			assertEquals(path.dirname('\\foo'), '\\');
			assertEquals(path.dirname('\\foo\\'), '\\');
			assertEquals(path.dirname('\\foo\\bar'), '\\foo');
			assertEquals(path.dirname('\\foo\\bar\\'), '\\foo');
			assertEquals(path.dirname('\\foo\\bar\\baz'), '\\foo\\bar');
			assertEquals(path.dirname('c:'), 'c:');
			assertEquals(path.dirname('c:foo'), 'c:');
			assertEquals(path.dirname('c:foo\\'), 'c:');
			assertEquals(path.dirname('c:foo\\bar'), 'c:foo');
			assertEquals(path.dirname('c:foo\\bar\\'), 'c:foo');
			assertEquals(path.dirname('c:foo\\bar\\baz'), 'c:foo\\bar');
			assertEquals(path.dirname('\\\\unc\\share'), '\\\\unc\\share');
			assertEquals(path.dirname('\\\\unc\\share\\foo'), '\\\\unc\\share\\');
			assertEquals(path.dirname('\\\\unc\\share\\foo\\'), '\\\\unc\\share\\');
			assertEquals(path.dirname('\\\\unc\\share\\foo\\bar'),
			       '\\\\unc\\share\\foo');
			assertEquals(path.dirname('\\\\unc\\share\\foo\\bar\\'),
			       '\\\\unc\\share\\foo');
			assertEquals(path.dirname('\\\\unc\\share\\foo\\bar\\baz'),
		       '\\\\unc\\share\\foo\\bar');
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
		     [['x', true, 7, 'y', null, {}], 'x/y']
		    ];
		joinTests.forEach(function(test) {
		  var actual = path.join.apply(path, test[1]);
		  var expected = isWindows ? test[2].replace(/\//g, '\\') : test[1];
		  var message = 'path.join(' + test[1].map(JSON.stringify).join(',') + ')' +
		                '\n  expect=' + JSON.stringify(expected) +
		                '\n  actual=' + JSON.stringify(actual);
		  if (actual !== expected) failures.push('\n' + message);
		  // assertEquals(actual, expected, message);
		});
		assertEquals(failures.length, 0, failures.join(''));
	}
	
	public void function test_normalize() {
		// path normalize tests
		if (isWindows) {
		  assertEquals(path.normalize('./fixtures///b/../b/c.js'),
		               'fixtures\\b\\c.js');
		  assertEquals(path.normalize('/foo/../../../bar'), '\\bar');
		  assertEquals(path.normalize('a//b//../b'), 'a\\b');
		  assertEquals(path.normalize('a//b//./c'), 'a\\b\\c');
		  assertEquals(path.normalize('a//b//.'), 'a\\b');
		  assertEquals(path.normalize('//server/share/dir/file.ext'),
		               '\\\\server\\share\\dir\\file.ext');
		} else {
		  assertEquals(path.normalize('./fixtures///b/../b/c.js'),
		               'fixtures/b/c.js');
		  assertEquals(path.normalize('/foo/../../../bar'), '/bar');
		  assertEquals(path.normalize('a//b//../b'), 'a/b');
		  assertEquals(path.normalize('a//b//./c'), 'a/b/c');
		  assertEquals(path.normalize('a//b//.'), 'a/b');
		}

	}

	public void function test_resolve() {
		// path.resolve tests
		if (isWindows) {
		  // windows
		  var resolveTests =
		      // arguments                                    result
		      [[['c:/blah\\blah', 'd:/games', 'c:../a'], 'c:\\blah\\a'],
		       [['c:/ignore', 'd:\\a/b\\c/d', '\\e.exe'], 'd:\\e.exe'],
		       [['c:/ignore', 'c:/some/file'], 'c:\\some\\file'],
		       [['d:/ignore', 'd:some/dir//'], 'd:\\ignore\\some\\dir'],
		       [['.'], process.cwd()],
		       [['//server/share', '..', 'relative\\'], '\\\\server\\share\\relative']];
		} else {
		  // Posix
		  var resolveTests =
		      // arguments                                    result
		      [[['/var/lib', '../', 'file/'], '/var/file'],
		       [['/var/lib', '/../', 'file/'], '/file'],
		       [['a/b/c/', '../../..'], process.cwd()],
		       [['.'], process.cwd()],
		       [['/some/dir', '.', '/absolute/'], '/absolute']];
		}
		var failures = [];
		resolveTests.forEach(function(test) {
		  var actual = path.resolve.apply(path, test[1]);
		  var expected = test[2];
		  var message = 'path.resolve(' + test[1].map(JSON.stringify).join(',') + ')' +
		                '\n  expect=' + JSON.stringify(expected) +
		                '\n  actual=' + JSON.stringify(actual);
		  if (actual !== expected) failures.push('\n' + message);
		  // assertEquals(actual, expected, message);
		});
		assertEquals(failures.length, 0, failures.join(''));
	}
	
	public void function test_relative() {
		// path.relative tests
		if (isWindows) {
		  // windows
		  var relativeTests =
		      // arguments                     result
		      [['c:/blah\\blah', 'd:/games', 'd:\\games'],
		       ['c:/aaaa/bbbb', 'c:/aaaa', '..'],
		       ['c:/aaaa/bbbb', 'c:/cccc', '..\\..\\cccc'],
		       ['c:/aaaa/bbbb', 'c:/aaaa/bbbb', ''],
		       ['c:/aaaa/bbbb', 'c:/aaaa/cccc', '..\\cccc'],
		       ['c:/aaaa/', 'c:/aaaa/cccc', 'cccc'],
		       ['c:/', 'c:\\aaaa\\bbbb', 'aaaa\\bbbb'],
		       ['c:/aaaa/bbbb', 'd:\\', 'd:\\']];
		} else {
		  // posix
		  var relativeTests =
		      // arguments                    result
		      [['/var/lib', '/var', '..'],
		       ['/var/lib', '/bin', '../../bin'],
		       ['/var/lib', '/var/lib', ''],
		       ['/var/lib', '/var/apache', '../apache'],
		       ['/var/', '/var/lib', 'lib'],
		       ['/', '/var/lib', 'var/lib']];
		}
		var failures = [];
		relativeTests.forEach(function(test) {
		  var actual = path.relative(test[1], test[2]);
		  var expected = test[3];
		  var message = 'path.relative(' +
		                test.slice(0, 2).map(JSON.stringify).join(',') +
		                ')' +
		                '\n  expect=' + JSON.stringify(expected) +
		                '\n  actual=' + JSON.stringify(actual);
		  if (actual !== expected) failures.push('\n' + message);
		});
		assertEquals(failures.length, 0, failures.join(''));

	}
	

	public void function test_sep() {
		// path.sep tests
		if (isWindows) {
		    // windows
		    assertEquals(path.sep, '\\');
		} else {
		    // posix
		    assertEquals(path.sep, '/');
		}
	}


	public void function setUp() {
		//variables.common = require('../common');
		variables.assert = require('assert');

		variables.path = require('path');

		variables.isWindows = (server.os.name CONTAINS 'windows');

		//variables.f = __filename;
	}
	
	public void function tearDown() {

	}
	
	

}