component name="ChildProcess" extends="emitter" {
  property type="any" name="env";

  public any function init(command,vargs = [],settings = {}) {
    var args = [];
    args.add(command);
    args.addAll(vargs);

    this.pb = createObject("java","java.lang.ProcessBuilder").init(args);
    this.env = this.pb.environment();
    if(structKeyExists(settings,'cwd')) {
      var cwd = createObject("java","java.io.File").init(settings.cwd);
      this.pb.directory(cwd);
    }

    this.on("exec",function() {
      console.print("Running command...");
    });

    this.on("close",function() {
      console.print("Exiting command...");
    });
    return this;
  }

  public any function exec() {
    this.Process = this.pb.start();
    this.OutputStream = this.Process.getOutputStream();
    this.InputStream = this.Process.getInputStream();
    this.ErrorStream = this.Process.getErrorStream();

    this.emit("exec");
  }

  public any function stdout(str) {
    this.OutputStream.println('test');
  }

  public any function stdin(str) {
    
  }

  public any function stderr(str) {
    
  }

  public any function close() {
    this.Process

    this.emit("close");
  }
}
