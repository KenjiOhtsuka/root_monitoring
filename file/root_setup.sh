#!/bin/sh
# Usage
#   sh root_setup.sh development_remote ap # for development_remote application server
#   sh root_setup.sh production mail       # for production mail server

if [ `whoami` != "root" ]; then
  echo "Execute this script as root user." >&2
  exit 1
fi

func_help () {
  echo "== Usage ==
  sh root_setup.sh [environment] [services]
  sh root_setup.sh -h

== Option ==
  -h : show this help

== Argument ==
  environment - development or production
  services    - ap or mail

== Example ==
  sh root_setup.sh development ap
  sh root_setup.sh production mail

== Description ==
  setup root crontab and root script files.
"
  return 0
}

while getopts h opt
do
  case $opt in
    h) func_help
       exit 0
  esac
done

case $1 in
  development) env=development;;
  production ) env=production;;
  *          ) echo "Set correct environment: development or production" >&2
                      exit 1
esac

case $2 in
  ap  ) services=nginx;;
  mail) services=saslauthd,postfix;;
  *   ) echo "Set correct server type: ap or mail" >&2
        exit 1
esac

dirPath="`dirname $0`"
railsRootDir="`readlink -f $dirPath/../`"
dirPath=$railsRootDir"/file"

# setup monitoring scripts
rootScriptDir=$dirPath"/root/monitoring"
rootFileDir=$dirPath"/root"
rm -rf $rootScriptDir
cp -R  $dirPath"/monitoring" $dirPath"/root"
chmod 755 $rootScriptDir/*

# setup crontab
logDir="`readlink -f $dirPath/../log`"
cronDescription="*/3 * * * * ${rootScriptDir}/service_check.pl $env $services > ${logDir}/service_check.log 2>&1
4 3 * * *   ${rootScriptDir}/resource_check.pl $env > ${logDir}/resource_check.log 2>&1 "
echo "$cronDescription" | crontab

echo "Your root crontab was set to:"
echo "$cronDescription"

exit 0
