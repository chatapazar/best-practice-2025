#!/bin/sh
echo "Creating Project 1 to $totalUsers ..."
for i in $( seq 1 $totalUsers )
do
    username=user$i
    oc login -u $username -p $USER_PASSWORD --insecure-skip-tls-verify
    oc new-project scc-$username
    oc new-project $username
done

