# Protect communication between applications
<!-- TOC -->

- [Protect communication between applications](#protect-communication-between-applications)
  - [Network Policy](#network-policy)
  - [Secure with mTLS (with OpenShift Service Mesh)](#secure-with-mtls-with-openshift-service-mesh)
  - [Back to Table of Content](#back-to-table-of-content)

<!-- /TOC -->


## Network Policy

- In OpenShift Web Console, Select project `userX` (change X to your username!!!)
- click Backend, click Services `backend` Link

  ![](images/sec/sec_0.png)

- In Details tab, copy Hostname such as `backend.user1.svc.cluster.local`

  ![](images/sec/sec_5.png)

- Change to project `scc-userX` (Change X to your username!!!)
- Click scc-tutorial-deploy-default deployment, select pod in this deployment for open terminal
- Try to call backend service with curl command line

  ```ssh
  curl -v http://backend.user1.svc.cluster.local:8080/backend
  ```
  
  example result

  ![](images/sec/sec_6.png)

- back to project `userX` (change X to your username!!!)
- Click Search in left menu, filter in resource with `NetworkPolicy`
- Click Create NetworkPolicy

  ![](images/sec/sec_7.png)
  
- In Create NetworkPolicy
  - Policy Name : example1
  - click Add pod selector
  
  ![](images/sec/sec_9.png)

- set label to `app` and selector to `backend`, this policy will affect only backend pod!
- check affected pods with link

  ![](images/sec/sec_10.png)

- In Ingress, click Add ingress rule, select Allow pods fro the same namespace

  ![](images/sec/sec_11.png)

- Click Create, and check Ingress rules of `example1` Network Policy

  ![](images/sec/sec_12.png)

- Test call again in web terminal, `userX` project

  ```ssh
  curl -v http://backend.userX.svc.cluster.local:8080/backend
  ```

  example result

  ![](images/sec/sec_13.png)

- Change to project `scc-userX` (Change X to your username!!!)
- Click scc-tutorial-deploy-default deployment, select pod in this deployment for open terminal
- Try to call backend service with curl command line

  ```ssh
  curl -v http://backend.userX.svc.cluster.local:8080/backend
  ```
  
  example result

  ![](images/sec/sec_14.png)

## Secure with mTLS (with OpenShift Service Mesh)

- Change to project `mesh-userX` (Change X to your username!!!)
  
  ![](images/sec/sec_1.png)

- Deploy new pod withou side car! `(Don't have sidecar inject)`
- Click Import YAML, deploy with below YAML

  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: mtls
  spec:
    selector:
      matchLabels:
        app: mtls
    template:
      metadata:
        labels:
          app: mtls
      spec:
        containers:
        - image: ubi8/ubi-minimal
          name: ubi-minimal
          command: ['sh', '-c', 'echo "Hello from user $(id -u)" && sleep infinity']
          volumeMounts:
          - mountPath: /var/opt/app/data
            name: data
        serviceAccountName: default
        volumes:
        - emptyDir: {}
          name: data
   ```

- wait until application deploy success and running, go to terminal of pod in `mtls` deployment.

  ![](images/sec/sec_2.png)

- try to call frontend with below command line

  ```ssh
  curl -v http://frontend:8080
  ```

- `(This Step action by Admin User of OSSM Control Plane)`
  - go to Service Mesh Control Plane, set Data Plane Security to True

  ![](images/sec/sec_3.png)

- Test call frontend again from `mtls` deployment
  
  ![](images/sec/sec_4.png)

## Back to Table of Content
- [Best Practices for Develop Cloud-Native Application](README.md)





