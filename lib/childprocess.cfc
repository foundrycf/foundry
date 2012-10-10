component name="childprocess" {
  property type="any" name="env";

  include "../core/require.cfm";
  variables.emitter = require("emitter");

  public any function init() {
    //for ACF compatibility
    var path = require("path");
    var syscmdJar = [path.resolve(path.dirname(getCurrentTemplatePath()),'../deps/systemcommand.jar')];

    var loader = createObject("component","foundry.deps.javaloader.JavaLoader").init(syscmdJar);
    variables.cmd = loader.create("au.com.webcode.util.SystemCommand");
    
    loader = "";
    syscmdJar = "";

    return this;
  }

  public any function spawn(command, vargs = [], settings = {}) {
    var args = [];
    args.add(command);
    args.addAll(vargs);
    var cwd = "";
    
    if(structKeyExists(settings,'cwd')) {
     cwd = settings.cwd;
    } else {
      cwd = returnNull();
    }

    res = cmd.execute(name="#command#",arguments=arrayToList(vargs,' '),timeout="10000",variable="out");
    results = res.getResult();
    return {
      'stdout': results.result,
      'stderr': results.error
    };
  };

  private void function returnNull() {

  }
}
