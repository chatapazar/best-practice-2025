# Prerequisite for workshop (Instructor Only)

- OCP 4.16

## Install Operator

- Web Terminal
- OpenShift Logging 5.9
- Loki 5.9
- VPA
- GitOps
- Red Hat OpenShift distributed tracing platform
- Kiali
- OpenShift Service Mesh 2.x

## Config Loki --> https://github.com/rhthsa/openshift-demo/blob/main/loki.md

- or

```sh
S3_BUCKET=$(oc get configs.imageregistry.operator.openshift.io/cluster -o jsonpath='{.spec.storage.s3.bucket}' -n openshift-image-registry)
REGION=$(oc get configs.imageregistry.operator.openshift.io/cluster -o jsonpath='{.spec.storage.s3.region}' -n openshift-image-registry)
ACCESS_KEY_ID=$(oc get secret image-registry-private-configuration -o jsonpath='{.data.credentials}' -n openshift-image-registry|base64 -d|grep aws_access_key_id|awk -F'=' '{print $2}'|sed 's/^[ ]*//')
SECRET_ACCESS_KEY=$(oc get secret image-registry-private-configuration -o jsonpath='{.data.credentials}' -n openshift-image-registry|base64 -d|grep aws_secret_access_key|awk -F'=' '{print $2}'|sed 's/^[ ]*//')
ENDPOINT=$(echo "https://s3.$REGION.amazonaws.com")
DEFAULT_STORAGE_CLASS=$(oc get sc -A -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}')
```


  
```sh
cat manifest/logging-loki-instance.yaml \
    |sed 's/S3_BUCKET/'$S3_BUCKET'/' \
    |sed 's/REGION/'$REGION'/' \
    |sed 's|ACCESS_KEY_ID|'$ACCESS_KEY_ID'|' \
    |sed 's|SECRET_ACCESS_KEY|'$SECRET_ACCESS_KEY'|' \
    |sed 's|ENDPOINT|'$ENDPOINT'|'\
    |sed 's|DEFAULT_STORAGE_CLASS|'$DEFAULT_STORAGE_CLASS'|' \
    |oc apply -f -
watch oc get po -n openshift-logging
```

- enable console plugin --> at operator hub

## setup user workload monitoring
- run and check
  ```sh
  oc apply -f user-workload-monitoring.yaml
  oc get po -n openshift-user-workload-monitoring
  ```

## Create User

```sh
export ADMIN_PASSWORD=dsdp015gNxM9hkwz
export USER_PASSWORD=QcjwTSbFZhnYsVTB
export totalUsers=1
```

- run [setup_user.sh](bin/setup_user.sh)


## Grant ServiceMonitor to User
- run [setup_monitor.sh](bin/setup_monitor.sh)  