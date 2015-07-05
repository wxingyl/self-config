export M2_HOME=/Users/xing/soft/apache-maven-3.2.3
export MAVEN_OPTS=-Dfile.encoding=UTF-8
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_25.jdk/Contents/Home
export CLASSPATH=./:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export GRADLE_HOME=/Users/xing/soft/gradle-2.4
export PATH=$PATH:$M2_HOME/bin:/usr/local/mysql/bin:$GRADLE_HOME/bin

alias sfind="find . -iname"
alias grep="grep --color=auto"
alias redis_server="/Users/xing/soft/redis-2.8.13/src/redis-server"
alias redis_cli="/Users/xing/soft/redis-2.8.13/src/redis-cli"
alias ctags="/usr/local/bin/ctags"
alias elastic="/Users/xing/soft/elasticsearch-1.6.0/bin/elasticsearch -d -p /tmp/elastic.pid"
alias vi='vim'
alias javac="javac -J-Dfile.encoding=utf8"
