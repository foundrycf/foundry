#Foundry
Foundry is a ColdFusion platform for building modular components for applications.

##Preface
Please be patient with Foundry, as pieces of this functionality is conceptual and is still being proven / developed.

ColdFusion (or CF) is a powerful server-side language wrapped around the JVM to build web applications.
Like most languages, CF has an object-oriented aspect known as components (or CFC's) which provide a "class / method / inheritance" foundation for enhancing your applications.
Up until now, there hasn't been a great way to adequately use CF to build, share, re-use and manage these Components.

That is why Foundry was created.

##What can it do for me?
Whether you're building a large CMS application, or a smaller utility library, there comes a time when you need to use it in more applications.
You may also want to share it, and allow others to use it in their applications.

Foundry builds upon common principles found in many other environments such as Ruby (and RubyGems), and Node (and npm).

These principles include (not limited to):

- Easily defining required dependencies at the top of Component files.
- Pre-defining required dependencies in a single config file and then requiring them.
- Managing dependencies by being able to install / update them on the fly without visiting sites like Riaforge, Github, etc.
- [Semantic Versioning](http://semver.org/) standards to keep track of versions of modules.
- Set of core components that augment your module building experience.

Now you can use CF to build more than just web apps.

##Getting Started
You can jump in at any level with Foundry.

The easiest way to get started is by simply including a "foundry.json" file within your application's root.
This defines some basic information about your application that will help Foundry know more about your application and what it needs to run properly.
Soon you will even be able to publish your apps to our registry at fpmcf.org so that others can quickly use your modules within their own applications.

Without installing Foundry, this doesn't offer much in terms of further implementing Foundry principles into your modules.
To learn how to install Foundry, follow the Installation guide in the section titled 'Installing Foundry' below.

To utilize advanced functionality provided by Foundry, you can begin by making your base components extend "Foundry.Module".
``` ColdFusion
component name="MyAwesomeComponent" extends="Foundry.Module" {

}
```

##Installing Foundry
Foundry's core is very basic in nature, but powerful when applied.  
Many of it's principles are probably already used in your applications today so it shouldn't be hard to implement them.

1. [Download Foundry] (http://github.com/joshuairl/)
    or better yet, use Git

    ```
    $ cd ~/my_projects_folder/
    $ git clone https://github.com/joshuairl/foundry.git foundry
    ```
2. Create a mapping (and/or symlink/virtualweb in your project) to `/foundry`.

    **Logical Path:** /foundry<br />
    **Physical Path:** /Users/<user>/my_projects_folder/foundry<br />
    - Adobe - http://localhost/CFIDE/administrator
    - Railo - http://localhost:8888/railo-context/admin/web.cfm

3. Create a new site / project folder or navigate to your existing one you would like to use Foundry on.

4. Create a new file in your project's folder called `foundry.json`.

    Paste the following into it and change the values accordingly.
   
    **Advanced `foundry.json` example**
    ``` JavaScript
    {
      "name": "my_app_module",
    	"description":"",
    	"version": "0.0.1",
    	"main":"./lib/main",
    	"author": "Joshua F. Rountree",
    	"dependencies":{
    		"UnderscoreCF":"~>0.0.0"
    	}
   }
   ```
    **Advanced `foundry.json` example**
    ``` JavaScript
    {
      "name": "my_module", //The unique name of your project
      "preferGlobal": "true", //Flag that indicates this package prefers to be installed globally for all your apps.
      "version": "0.3.0", //Version of the package as specified by http://semver.org/.
      "author": "Ricky Bobby <ricky@rickybobby.com>", //The author of the project.
      "description": "a simple tool to help you do cool things.", //The description of the project.
      
      //An array of structures representing contributors to the project.
      "contributors": [ 
        {
          "name": "John Smith",
          "email": "john@smithcode.dom"
        } 
      ], 
      "bin": {
        "module-cli": "./bin/module" //A structure containing key/pair mappings of binary script names and cf script paths. 
      },
      "scripts": {}, //A structure containing key/pair mappings of foundry modules and cf script paths. (not currently used yet)
      "main": "./lib/http-server", //The main entry point of the package. When calling require('module_name') in Foundry this is the file that will actually be required.
      "repository": {
        "type": "git",
        "url": "https://github.com/joshuairl/my_project.git"
      }, //A structure containing key/pair mappings of source code repositories. 
      "keywords": [
        "cli",
        "http",
        "server"
      ], //An array of keywords which describe your package. Useful for people searching the fpmcf.org registry.
      "dependencies" : {
        "UnderscoreCF"   :  "*"
      }, //A structure containing key/pair mappings of foundry packages and versions that this project depends on.
    
      "license": "MIT", The license which you prefer to release your project under. MIT is a good choice.
      "engines": {
        "adobe": ">=9.0.0" //specifies adobe version required
        "railo": ">=3.3.1" //specifies railo version requird
        "foundy": "0.0.3" //even a place to specify the foundry version (good practice)
      } //A struct containing key/pair mappings of engine versions. This is used to specify the versions of CFML and Foundry your package is known to work correctly with.
    }
    ```

5. Extend your base components to allow for easy usage of external dependencies.
    ```
    component name="my_base" extends="foundry.module" {
        public my_base function init() {
            variables.path = require("path"); //require the foundry path module, apart of foundry's core.
            variables._ = require("UnderscoreCF"); //require underscore, an external module by @russplaysguitar
        }

        public any function doSomething() {
            myPath = path.resolve('foo/bar', '/tmp/file/', '..', 'a/../subfile');
            myArray = _.forEach();
        }
    }
    ```

6. To download and install dependencies use `fpm.cfc`. (soon there will be a CLI for this, sorry!)

    Install all defined dependencies in foundry.json
    `http://localhost/foundry/fpm.cfc?method=install

## Usage Examples