#!/bin/sh
cmd=
for a in "$@"
do
	case "$a" in
	-*) continue ;;
	*)  cmd=$a; break; ;;
	esac
done

use_pager=
case "$cmd" in
blame)    use_pager=1 ;;
diff)     use_pager=1 ;;
log)      use_pager=1 ;;
esac

this_script=`which "$0" 2>/dev/null`
[ $? -gt 0 -a -f "$0" ] && this_script="$0"
cp=$this_script
JRE=$(dirname $this_script)/jre
if [ -n "$RAILO_CLASSPATH" ]
then
	cp="$cp:$RAILO_CLASSPATH"
fi

# Cleanup paths for Cygwin.
#
case "`uname`" in
CYGWIN*)
	cp=`cygpath --windows --mixed --path "$cp"`
	;;
Darwin)
	if [ -e /System/Library/Frameworks/JavaVM.framework ]
	then
		java_args='
			-Dcom.apple.mrj.application.apple.menu.about.name=Railo
			-Dcom.apple.mrj.application.growbox.intrudes=false
			-Dapple.laf.useScreenMenuBar=true
			-Xdock:name=Railo
			-Dfile.encoding=UTF-8
		'
	fi
	;;
esac

CLASSPATH="$cp"
export CLASSPATH
echo $JAVA_HOME
java=java
if [ -n "$JAVA_HOME" ]
then
	java="$JAVA_HOME/bin/java"
	echo $java
fi

if [ -d "$JRE" ]
then
	java="$JRE/bin/java"
	echo $java
fi

if [ -n "$use_pager" ]
then
	use_pager=${RAILO_PAGER:-${PAGER:-less}}
	[ cat = "$use_pager" ] && use_pager=
fi

if [ -n "$use_pager" ]
then
	LESS=${LESS:-FSRX}
	export LESS

	"$java" $java_args cliloader.LoaderCLIMain "$@" | $use_pager
	exit
else
  exec "$java" $java_args -cp . cliloader.LoaderCLIMain "$@"
  exit 1
fi
