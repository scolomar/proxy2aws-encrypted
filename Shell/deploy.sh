#!/bin/bash

set +x && test "$debug" = true && set -x ;

pwd=$( dirname $( readlink -f $0 ) ) ;

test -z "$stack" && echo PLEASE DEFINE THE VALUE FOR stack && exit 1 ;
test -z "$deploy" && echo PLEASE DEFINE THE TYPE OF DEPLOYMENT: LATEST/RELEASE && exit 1 ; 

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

command=" sudo docker stack deploy --compose-file proxy2aws/Compose/$deploy/aws2cloud.yml aws2cloud " ;
targets=" InstanceManager1 " ;
for target in $targets ; do
 send_list_command "$command" "$target" "$stack" ;
done ;

command=" sudo docker stack deploy --compose-file proxy2aws/Compose/$deploy/aws2prem.yml aws2prem " ;
targets=" InstanceManager1 " ;
for target in $targets ; do
 send_list_command "$command" "$target" "$stack" ;
done ;

command=" sudo rm --recursive --force proxy2aws " ;
targets=" InstanceManager1 " ;
for target in $targets ; do
 send_command "$command" "$target" "$stack" ;
done ;

