export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_60.jdk/Contents/Home
export CLASSPATH=./:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

export M2_HOME=/Users/xing/soft/apache-maven-3.2.3
export MAVEN_OPTS=-Dfile.encoding=UTF-8
export GRADLE_HOME=/Users/xing/soft/gradle-2.4
export MYSQL_HOME=/usr/local/mysql
export BREW_HOME=/usr/local/homebrew
export GO_HOME=/usr/local/go
export SCALA_HOME=/Users/xing/soft/scala-2.11.7

PATH=$PATH:$M2_HOME/bin:$MYSQL_HOME/bin:$GRADLE_HOME/bin:$SCALA_HOME/bin:$BREW_HOME/bin:$GO_HOME/bin:$HOME/bin

alias self-reload="source /Users/xing/.myself.profile"
alias sfind="find . -iname"
alias grep="grep --color=auto"
alias redis-server="/Users/xing/soft/redis-3.0.5/src/redis-server /Users/xing/soft/redis-3.0.5/redis.conf"
alias redis-cli="/Users/xing/soft/redis-3.0.5/src/redis-cli"
alias ctags="/usr/local/bin/ctags"
alias elastic="/Users/xing/soft/elasticsearch-1.7.1/bin/elasticsearch -d -p /tmp/elastic.pid"
alias elastic-pid="cat /tmp/elastic.pid"
alias elastic-cd="cd /Users/xing/soft/elasticsearch-1.7.1"
alias logstash="/Users/xing/soft/logstash-1.5.3/bin/logstash"
alias kibana="/Users/xing/soft/kibana-4.1.1-darwin-x64/bin/kibana -c /Users/xing/soft/kibana-4.1.1-darwin-x64/config/kibana.yml"
alias vi='/usr/local/homebrew/bin/vim'
alias vim='/usr/local/homebrew/bin/vim'
alias javac="javac -J-Dfile.encoding=utf8"
alias mvn-install="mvn clean install -Dmaven.test.skip -U"

# explain.sh begins
explain () {
  if [ "$#" -eq 0 ]; then
    while read  -p "Command: " cmd; do
      curl -Gs "https://www.mankier.com/api/explain/?cols="$(tput cols) --data-urlencode "q=$cmd"
    done
    echo "Bye!"
  elif [ "$#" -eq 1 ]; then
    curl -Gs "https://www.mankier.com/api/explain/?cols="$(tput cols) --data-urlencode "q=$1"
  else
    echo "Usage"
    echo "explain                  interactive mode."
    echo "explain 'cmd -o | ...'   one quoted command to explain it."
  fi
}
