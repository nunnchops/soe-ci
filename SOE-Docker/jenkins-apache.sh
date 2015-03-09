#! /bin/bash
# now my addition to an otherwise graceful script 
# could just be plain stupid.. but it may work needs testing 
# may be more sane to actually run httpd from a docker run 

# if `docker run` first argument start with `--` the user is passing jenkins launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
   exec java $JAVA_OPTS -jar /usr/lib/jenkins/jenkins.war $JENKINS_OPTS "$@" && exec /etc/init.d/httpd start
fi

# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"

