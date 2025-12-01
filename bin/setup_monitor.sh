#!/bin/sh
echo "Add Policy  1 to $totalUsers ..."
oc login -u admin -p $ADMIN_PASSWORD --insecure-skip-tls-verify
#oc create -f ./bin/scc-tutorial-scc.yaml

for i in $( seq 1 $totalUsers )
do
  username=user$i
  oc adm policy add-role-to-user view $username -n test
  oc adm policy add-role-to-user monitoring-edit $username -n $username
  oc adm policy add-role-to-user  monitoring-rules-view $username -n $username
  oc adm policy add-role-to-user  monitoring-rules-edit $username -n $username
  oc adm policy add-role-to-user cluster-logging-application-view $username -n $username

  oc adm policy add-role-to-user cluster-monitoring-view user$i -n user$i
  oc adm policy add-role-to-user cluster-monitoring-view user$i -n openshift-monitoring
done

for i in $( seq 1 $totalUsers )
do
  username=user$i
  #oc create sa scc-tutorial-sa -n scc-$username
  #oc create -f ./bin/rolebinding.yaml -n scc-$username
  oc create sa anyuid -n scc-$username
  oc adm policy add-scc-to-user -n scc-$username -z anyuid anyuid
  
done


for i in $( seq 1 $totalUsers )
do
  
  oc adm policy add-role-to-user cluster-monitoring-view user$i -n user$i
  oc adm policy add-role-to-user cluster-monitoring-view user$i -n openshift-monitoring
done