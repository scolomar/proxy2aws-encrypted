#!/bin/bash

set +x && test "$debug" = true && set -x ;

pwd=$( dirname $( readlink -f $0 ) ) ;

test -z "$stack" && echo PLEASE DEFINE THE VALUE FOR stack && exit 1 ;

git clone https://github.com/secobau/docker.git ;
source docker/AWS/common/functions.sh ;
rm --recursive --force docker ;

command=" git clone https://github.com/secobau/proxy2aws.git proxy2aws " ;
targets=" InstanceManager1 " ;
for target in $targets ; do
 send_command "$command" "$target" "$stack" ;
done ;

command=" find proxy2aws " ;
targets=" InstanceManager1 " ;
for target in $targets ; do
 send_command "$command" "$target" "$stack" ;
done ;

folders=" configs secrets " ;
for folder in $folders ;
do
 command=" sudo cp --recursive --verbose proxy2aws/$folder / ; " ;
 targets=" InstanceManager1 " ;
 for target in $targets ; do
  send_command "$command" "$target" "$stack" ;
 done ;
done ;

command=" sudo rm --recursive --force proxy2aws " ;
targets=" InstanceManager1 " ;
for target in $targets ; do
 send_command "$command" "$target" "$stack" ;
done ;
