package cliloader;

import java.io.File;
import java.io.FileOutputStream;
import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.FilenameFilter;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.LinkedList;
import java.util.List;
import java.util.jar.JarEntry;
import java.util.jar.JarInputStream;

public class LoaderCLIMain {

	private static String ZIP_PATH = "libs.zip";
	private static final int KB = 1024;

	public static void main(String[] args) throws Throwable {
		ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
		Map<String,String> config=toMap(args);
		Boolean debug = false, updateLibs = false;
		Boolean startServer = false;
		Boolean background = false;
		File currentDir;
		String userHome = System.getProperty("user.home");
		System.out.println(args);
		if(userHome != null) {
			currentDir = new File(userHome + "/.railo/");
			if(!currentDir.exists())
				System.out.println("Configuring "+ userHome + "/.railo/" + " (change with -lib=/path/to/dir)");
			currentDir.mkdir();
		} else {
			currentDir = new File(LoaderCLIMain.class.getProtectionDomain().getCodeSource().getLocation().getPath()).getParentFile();
		}
		//System.out.println(currentDir.getPath());
		File libDir=new File(currentDir,"lib").getCanonicalFile();
		
		// debug
		if(config.get("debug") != null) {
			debug = true;
			System.out.println("Using configuration in "+ userHome + "/.railo/" + " (change with -lib=/path/to/dir)");
		}
		// update/overwrite libs
		if(config.get("update") != null) {
			updateLibs = true;
			args = removeElementThenAdd(args,"-update","");
		}
		// background
		if(config.get("background") != null) {
			background = true;
			args = removeElementThenAdd(args,"-background","");
		}
		
		if(config.get("?") != null || args.length == 0) {
			System.out.println("USAGE: railo /path/to/script [-libs=/path/to/libs/dir -webroot=/path/to/web -uri=/webroot/script/path -config-server=/path/to/dir -config-web=/path/to/dir] [-form=name=susi -cgi=user_agent=urs]");
			System.out.println("Ex: railo test.cfm");
			System.out.println("Or for server mode: railo -server --port=8088");
			System.out.println("And to update libs after updating binary: railo -update");
			Thread.sleep(3000);
			System.exit(0);
		}
		
		// libs dir
		String strLibs=config.get("lib");
		if(strLibs != null && strLibs.length() != 0) {
			libDir=new File(strLibs);
		}

		String strStart=config.get("server");
		if(strStart != null) {
			startServer=true;
		}


        if(libDir.toString().equals("/Users/mic/Projects/Railo/Source2/railo/railo-java/railo-loader"))
			libDir=new File("/Users/mic/temp/ext");

		if(debug) System.out.println("lib dir: " + libDir);

		if (!libDir.exists() || updateLibs) {
			libDir.mkdir();
			URL resource = classLoader.getResource(ZIP_PATH);
			if (resource == null) {
				System.err.println("Could not find the " + ZIP_PATH + " on classpath!");
				System.exit(1);
			}
			if(debug) System.out.println("Extracting " + ZIP_PATH);

			try {

				BufferedInputStream bis = new BufferedInputStream(resource.openStream());
				JarInputStream jis = new JarInputStream(bis);
				JarEntry je = null;

				while ((je = jis.getNextJarEntry()) != null) {
					java.io.File f = new java.io.File(libDir.toString() + java.io.File.separator + je.getName());
					if (je.isDirectory()) {
						f.mkdir();
						continue;
					}
					File parentDir = new File(f.getParent());
					if (!parentDir.exists()) {
						parentDir.mkdir();
					}
					writeStreamTo(jis, new FileOutputStream(f), 8 * KB);
				}
				bis.close();

			} catch (Exception exc) {
				exc.printStackTrace();
			}
		}

		
        File[] children = libDir.listFiles(new ExtFilter());
        if(children.length<2) {
        	libDir=new File(libDir,"lib");
        	 children = libDir.listFiles(new ExtFilter());
        }
        
        URL[] urls = new URL[children.length];
        if(debug) System.out.println("Loading Jars");
        for(int i=0;i<children.length;i++){
        	urls[i]=children[i].toURI().toURL();
        	if(debug) System.out.println("- "+urls[i]);
        }
        //URLClassLoader cl = new URLClassLoader(urls,ClassLoader.getSystemClassLoader());
        //URLClassLoader cl = new URLClassLoader(urls,null);
        URLClassLoader cl = new URLClassLoader(urls,classLoader);
		//Thread.currentThread().setContextClassLoader(cl);
        Class cli;
        if(!startServer) {
        	if(debug) System.out.println("Running in CLI mode");
	        cli = cl.loadClass("railocli.CLIMain");
        } 
        else {
        	if(debug) System.out.println("Running in server mode");
        	File curDir = new File("./").getCanonicalFile();
	        cli = cl.loadClass("runwar.Start");
	        //Thread.currentThread().setContextClassLoader(cl);
	        /*
	        System.out.println(libDir.getPath()+"/");
	        Boolean addWarArg = true;
			for (String s : args)
			    if (s.toLowerCase().startsWith("-war"))
			        addWarArg = false;
			String[] newArgs;
        	if(addWarArg) {
				newArgs = new String[] {"-war",curDir.getPath(),"-background","false"};
        	} else {
				newArgs = new String[] {"-background","false"};
        	}
			String[] temp = new String[args.length + newArgs.length];
			System.arraycopy(newArgs, 0, temp, 0, newArgs.length)
			System.arraycopy(args, 0, temp, newArgs.length, args.length);
			newArgs = temp;        	
	        args = new String[] { "-war",curDir.getPath()
        		,"-background","true"
        		,"-loglevel","WARN"
        		//,"-port","8078"
        		//,"-dirs",curDir.getPath()
        		//,"-libs",libDir.getPath()
    		};
    		*/
			String path = LoaderCLIMain.class.getProtectionDomain().getCodeSource().getLocation().getPath();
			//System.out.println("yum from:"+path);
			String decodedPath = java.net.URLDecoder.decode(path, "UTF-8");
			decodedPath = new File(decodedPath).getPath();

    		//args = removeElementThenAdd(args,"-server","-war "+curDir.getPath()+" --background false --logdir " + libDir.getParent());
    		String argstr;
    		if(background) {
    			argstr="-war "+curDir.getPath()+" --background true --jar \""+decodedPath.replace('\\','/')+"\" --libdir \"" + libDir.getPath() +"\"";
    		} else {
    			argstr="-war "+curDir.getPath()+" --background false";
    		}
    		args = removeElementThenAdd(args,"-server",argstr);
        	if(debug) System.out.println("Args: " + java.util.Arrays.toString(args));
        } 
        Method main = cli.getMethod("main",new Class[]{String[].class});
		try{
        	main.invoke(null, new Object[]{args});
		} catch (Exception e) {
			e.getCause().printStackTrace();
		}
        
        
	}
	
	public static String[] removeElementThenAdd(String[] input, String deleteMe, String addList) {
	    List<String> result = new LinkedList<String>();
	    for(String item : input)
	        if(!deleteMe.equals(item))
	            result.add(item);

	    for(String item : addList.split(" "))
	    		result.add(item);
	    
	    return result.toArray(input);
	}


	public static class ExtFilter implements FilenameFilter {
		
		private String ext=".jar";
		public boolean accept(File dir, String name) {
			return name.toLowerCase().endsWith(ext);
		}

	}

	public static int writeStreamTo(final InputStream input, final OutputStream output, int bufferSize)
			throws IOException {
		int available = Math.min(input.available(), 256 * KB);
		byte[] buffer = new byte[Math.max(bufferSize, available)];
		int answer = 0;
		int count = input.read(buffer);
		while (count >= 0) {
			output.write(buffer, 0, count);
			answer += count;
			count = input.read(buffer);
		}
		return answer;
	}

	private static Map<String, String> toMap(String[] args) {
		int index;
		Map<String, String> config=new HashMap<String, String>();
		String raw,key,value;
		if(args!=null)for(int i=0;i<args.length;i++){
			raw=args[i].trim();
			if(raw.length() == 0) continue;
			if(raw.startsWith("-"))raw=raw.substring(1).trim();
			index=raw.indexOf('=');
			if(index==-1) {
				key=raw;
				value="";
			}
			else {
				key=raw.substring(0,index).trim();
				value=raw.substring(index+1).trim();
			}
			config.put(key.toLowerCase(), value);
		}
		return config;
	}
}
