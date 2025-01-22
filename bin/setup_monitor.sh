#!/bin/sh
echo "Add Policy  1 to $totalUsers ..."
oc login -u admin -p $ADMIN_PASSWORD --insecure-skip-tls-verify
for i in $( seq 1 $totalUsers )
do
    username=user$i
    oc adm policy add-role-to-user monitoring-edit $username -n $username
    oc adm policy add-role-to-user  monitoring-rules-view $username -n $username
    oc adm policy add-role-to-user  monitoring-rules-edit $username -n $username
    oc adm policy add-role-to-user cluster-logging-application-view $username -n $username
done

