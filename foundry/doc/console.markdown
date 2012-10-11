#Console
Most will be familiar with the basics of what this offers but for ColdFusion developers, it's not so common to use a terminal to view debugging information or write to the console for that matter.  Obviously, Foundry changes most of that... so here it is.

Use this module with `require("console")`.

##Console.log(obj)
Converts a string or complex object into a stripped version of CFDUMP except it's placed in your terminal window.

Also prepends the current time to the message.
It also strips html and converts complex object types into text.

`console.log("This is a " & obj);`

##Console.print(obj)
Same thing, except it is a raw version of `java.lang.System.out.println`
Which offers no security for advanced objects, but offers a more pure stdout implementation.  

To get the best output, wrap advanced objects in serialize or serializeJson().

`console.print("This is a " & serialize(obj));`

##Variants of console.log()

- console.error(obj) //output: `ERROR: <obj>
- console.info(obj) //output: `INFO: <obj>`
- console.warning(obj) //output: `WARNING: <obj>`
- console.config(obj) //output: `CONFIG: <obj>`

##FUTURE ENHANCEMENTS

- Ansi Colors for Error, Warning, Info, Config, etc.
- Custom ansi color arguments, etc.