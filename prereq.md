# Prerequisite for workshop (Instructor Only)

- OCP 4.16

## Install Operator

- Login wih Cluster Admin for Install Operator
- Web Terminal
- OpenShift Logging 5.9
- Loki 5.9
- VPA
- GitOps
- Red Hat OpenShift distributed tracing platform
- Kiali
- OpenShift Service Mesh 2.x


## Config Loki --> https://github.com/rhthsa/openshift-demo/blob/main/loki.md


## setup user workload monitoring
- run and check
  ```sh
  oc apply -f user-workload-monitoring.yaml
  oc get po -n openshift-user-workload-monitoring
  ```

## Create User

```sh
export ADMIN_PASSWORD=rzNN0ZiKOHHlUsTA
export USER_PASSWORD=6i08yar6VKeWxlNB
export totalUsers=1
```

- run [setup_user.sh](bin/setup_user.sh)


## Grant ServiceMonitor to User
- run [setup_monitor.sh](bin/setup_monitor.sh)  