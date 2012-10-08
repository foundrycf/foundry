component name="childprocess" extends="emitter" {
  property type="any" name="env";

  public any function init() {
    var path = require("path");
    var syscmdJar = [];
    syscmdJar.add(path.resolve(path.dirname(getComponentMetaData(this).path),'../deps/systemcommand.jar'));
    var loader = createObject("component","foundry.deps.javaloader.JavaLoader").init(syscmdJar);
    variables.cmd = loader.create("au.com.webcode.util.SystemCommand");
    
    loader = "";
    syscmdJar = "";

    return this;
  }

  public any function spawn(command,vargs = [], settings = {}) {
    var args = [];
    args.add(command);
    args.addAll(vargs);
    var cwd = "";
    
    if(structKeyExists(settings,'cwd')) {
     cwd = settings.cwd;
    } else {
      cwd = returnNull();
    }

    var result = cmd.execute("#command# #arrayToList(vargs,' ')#",'10000',cwd);
    
    return {
      'stdout': result.getStandardOutput(),
      'stderr': result.getErrorOutput()
    };
  };

  private void function returnNull() {

  }
}
