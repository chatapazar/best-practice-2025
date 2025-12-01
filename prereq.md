# Prerequisite for workshop (Instructor Only)

## Install Operator

- Web Terminal
- OpenShift Logging
- cluster observability 
- Loki
- VPA
- GitOps
- Red Hat OpenShift distributed tracing platform  (jaeger)
- Kiali 1.89
- OpenShift Service Mesh 2 latest

## scale console https://access.redhat.com/solutions/5841381

```yaml
console operator change to Unmanaged   

remove   
   nodeSelector:
     node-role.kubernetes.io/master: ''
```

## Deploy test app at test namespace

oc new-project test

# deploy https://github.com/chatapazar/openshift-workshop.git , path /sample, app name: test, scale 3

## Create User

```sh
export ADMIN_PASSWORD=peqfMDHVFPGgm8gJ
export USER_PASSWORD=DgPZHU1DVZtoBd8P
export totalUsers=20
```


## setup user workload monitoring
- run and check
  ```sh
  oc apply -f user-workload-monitoring.yaml
  oc get po -n openshift-user-workload-monitoring
  ```

## Config Loki 

```sh
S3_BUCKET=$(oc get configs.imageregistry.operator.openshift.io/cluster -o jsonpath='{.spec.storage.s3.bucket}' -n openshift-image-registry)
REGION=$(oc get configs.imageregistry.operator.openshift.io/cluster -o jsonpath='{.spec.storage.s3.region}' -n openshift-image-registry)
ACCESS_KEY_ID=$(oc get secret image-registry-private-configuration -o jsonpath='{.data.credentials}' -n openshift-image-registry|base64 -d|grep aws_access_key_id|awk -F'=' '{print $2}'|sed 's/^[ ]*//')
SECRET_ACCESS_KEY=$(oc get secret image-registry-private-configuration -o jsonpath='{.data.credentials}' -n openshift-image-registry|base64 -d|grep aws_secret_access_key|awk -F'=' '{print $2}'|sed 's/^[ ]*//')
ENDPOINT=$(echo "https://s3.$REGION.amazonaws.com")
DEFAULT_STORAGE_CLASS=$(oc get sc -A -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}')

cat manifests/logging-loki-instance.yaml \
|sed 's/S3_BUCKET/'$S3_BUCKET'/' \
|sed 's/REGION/'$REGION'/' \
|sed 's|ACCESS_KEY_ID|'$ACCESS_KEY_ID'|' \
|sed 's|SECRET_ACCESS_KEY|'$SECRET_ACCESS_KEY'|' \
|sed 's|ENDPOINT|'$ENDPOINT'|'\
|sed 's|DEFAULT_STORAGE_CLASS|'$DEFAULT_STORAGE_CLASS'|' \
|oc apply -f -
```

# https://docs.redhat.com/en/documentation/red_hat_openshift_logging/6.3/html/about_openshift_logging/quick-start#quickstart-viaq_quick-start

```sh
oc create sa collector -n openshift-logging
oc adm policy add-cluster-role-to-user logging-collector-logs-writer -z collector -n openshift-logging
oc adm policy add-cluster-role-to-user collect-application-logs -z collector -n openshift-logging
oc adm policy add-cluster-role-to-user collect-audit-logs -z collector -n openshift-logging
oc adm policy add-cluster-role-to-user collect-infrastructure-logs -z collector -n openshift-logging

oc apply -f manifests/ClusterLogForwarder.yaml
```

- run [setup_user.sh](bin/setup_user.sh)


## Grant ServiceMonitor to User
- run [setup_monitor.sh](bin/setup_monitor.sh)  

## Manual add account to argocd (in ACD CRD) 

extraConfig:
  accounts.user1: apiKey, login
  accounts.user2: apiKey, login
  accounts.user3: apiKey, login
  accounts.user4: apiKey, login
  accounts.user5: apiKey, login
  accounts.user6: apiKey, login
  accounts.user7: apiKey, login
  accounts.user8: apiKey, login
  accounts.user9: apiKey, login
  accounts.user10: apiKey, login
  accounts.user11: apiKey, login
  accounts.user12: apiKey, login
  accounts.user13: apiKey, login
  accounts.user14: apiKey, login
  accounts.user15: apiKey, login
  accounts.user16: apiKey, login
  accounts.user17: apiKey, login
  accounts.user18: apiKey, login
  accounts.user19: apiKey, login
  accounts.user20: apiKey, login
  accounts.user21: apiKey, login
  accounts.user22: apiKey, login
  accounts.user23: apiKey, login
  accounts.user24: apiKey, login
  accounts.user25: apiKey, login
  accounts.user26: apiKey, login
  accounts.user27: apiKey, login
  accounts.user28: apiKey, login
  accounts.user29: apiKey, login
  accounts.user30: apiKey, login

## and add defaultpolicy to role:admin

rbac:
  defaultPolicy: 'role:admin'


## update argocd password

oc adm policy add-cluster-role-to-user cluster-admin -z openshift-gitops-argocd-application-controller -n openshift-gitops
ARGOCD=$(oc get route/openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}')
echo https://$ARGOCD
PASSWORD=$(oc extract secret/openshift-gitops-cluster -n openshift-gitops --to=-) 2>/dev/null
echo $PASSWORD
argocd login $ARGOCD  --insecure --username admin --password $PASSWORD
for i in $( seq 1 $totalUsers )
do
  username=user$i
  argocd account update-password --account $username --new-password $USER_PASSWORD --current-password $PASSWORD
done



## service mesh

oc new-project istio-system
oc create -f manifest/smcp.yaml -n istio-system
watch oc get smcp/basic -n istio-system

## edit smmr.yaml before run, add alll project of all user

oc create -f manifest/smmr.yaml -n istio-system
oc describe smmr/default -n istio-system | grep -A2 Spec:

for i in $( seq 1 $totalUsers )
do
    username=user$i
    oc apply -f manifest/frontend.yaml -n mesh-$username
    oc patch deployment/frontend-v1 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"true"}}}}}' -n mesh-$username
    oc patch deployment/frontend-v2 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"true"}}}}}' -n mesh-$username
    oc apply -f manifest/backend.yaml -n mesh-$username
    oc apply -f manifest/backend-destination-rule.yaml -n mesh-$username
    oc apply -f manifest/backend-virtual-service-v1-v2-50-50.yaml -n mesh-$username
    oc set env deployment/frontend-v1 BACKEND_URL=http://backend:8080/ -n mesh-$username
    oc set env deployment/frontend-v2 BACKEND_URL=http://backend:8080/ -n mesh-$username
    oc annotate deployment frontend-v1 'app.openshift.io/connects-to=[{"apiVersion":"apps/v1","kind":"Deployment","name":"backend-v1"},{"apiVersion":"apps/v1","kind":"Deployment","name":"backend-v2"}]' -n mesh-$username
    oc annotate deployment frontend-v2 'app.openshift.io/connects-to=[{"apiVersion":"apps/v1","kind":"Deployment","name":"backend-v1"},{"apiVersion":"apps/v1","kind":"Deployment","name":"backend-v2"}]' -n mesh-$username
    oc policy add-role-to-user -n istio-system --role-namespace istio-system mesh-user $username
done

for i in $( seq 1 $totalUsers )
do
    username=user$i
    oc policy add-role-to-user -n istio-system --role-namespace istio-system mesh-user $username
    oc adm policy add-role-to-user -n istio-system view $username
done