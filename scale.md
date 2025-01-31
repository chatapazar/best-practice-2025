# Quality of Service (from request/limit) and Pod Auto Scaling
<!-- TOC -->

- [Quality of Service (from request/limit) and Pod Auto Scaling](#quality-of-service-from-requestlimit-and-pod-auto-scaling)
  - [Check Quality of Service](#check-quality-of-service)
  - [Use Vertical Pod Autoscaler for sizing](#use-vertical-pod-autoscaler-for-sizing)
  - [Manual Scale Application](#manual-scale-application)
  - [Auto Scale Application](#auto-scale-application)
  - [Back to Table of Content](#back-to-table-of-content)

<!-- /TOC -->
<!-- /TOC -->
- Open Web Terminal by click '>_' on top of OpenShift Web Console
- use web terminal to run command line

## Check Quality of Service

- Go to Developer Perspective, Topology view and select project <username>

  ![](images/vpa_1.png)

- click Pod link in side panel
  
  ![](images/vpa_2.png)
  
- click YAML Tab, see qosClass `Remember it`
  
  ![](images/vpa_3.png)

- Back to Topology view click `Backend` Deployment, select Actions --> Edit resource limits

  ![](images/vpa_4.png)

- Change Request Cpu = Limit Cpu, Request Memory = Limit Memory, save and wait until pod restart and complete `(Change to Running)`
  
  ![](images/vpa_5.png)

- View Pod YAML again, see qosClass 
  
  ![](images/vpa_6.png)
  
## Use Vertical Pod Autoscaler for sizing 

- click Import YAML icon `(Top Right of Web Console)`, create VPA, click save

  ```yaml
  apiVersion: autoscaling.k8s.io/v1
  kind: VerticalPodAutoscaler
  metadata:
  name: vpa-recommender
  spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: backend
  updatePolicy:
    updateMode: "Off"
  ```

  ![](images/vpa_7.png)

- go to web terminal
- run load test command

  ```bash
  BACKEND_URL=https://$(oc get route backend -o jsonpath='{.spec.host}')
  for i in {0..1000}; do
    curl $BACKEND_URL/backend
    printf "\n"
  done
  ```

- after complete, run vpa to get recommendation  `change namespace/project before run command`

  ```ssh
  oc get vpa vpa-recommender -n user1 --output yaml
  ```

  example output

  ![](images/vpa_8.png)

## Manual Scale Application
- click topology in left menu, click Duke icon (backend deployment), Details tab
- click increase ther pod count (^ icon) to 2 Pod

  ![](images/scale_1.png) 

- wait until application scale to 2 Pods (circle around Duke icon change to dark blue)

  ![](images/scale_2.png)

  ![](images/scale_3.png)

- Wait a few minutes, util new pod ready to receive request!!! 

- Test load to application, go to web terminal, run below command 
  ```bash
  BACKEND_URL=https://$(oc get route backend -o jsonpath='{.spec.host}')
  while [  1  ];
  do
    curl $BACKEND_URL/backend
    printf "\n"
    sleep 10
  done
  ```
  example result, check have result from 2 pods (Host value)
  ```bash
  Backend version:v1, Response:200, Host:backend-95647fbb8-kt886, Status:200, Message: Hello, World
  Backend version:v1, Response:200, Host:backend-95647fbb8-q9dqv, Status:200, Message: Hello, World
  Backend version:v1, Response:200, Host:backend-95647fbb8-kt886, Status:200, Message: Hello, World
  Backend version:v1, Response:200, Host:backend-95647fbb8-q9dqv, Status:200, Message: Hello, World
  ```

- after few minute, type 'ctrl-c' in web terminal to terminated curl command
- go to Resources Tab, in Pods section, show 2 pods after scale

  ![](images/scale_5.png)

- click 'View logs' of 1st Pod and 2nd Pod to confirm both pod are processed. 

  ![](images/scale_6.png)

  example of 1st pod

  ![](images/scale_7.png)  

  example of 2nd pod

  ![](images/scale_8.png)  

- back to detail pages of backend deployment, scale pod to 0 (for this case, no pod for this application)

  ![](images/scale_9.png)  

  ![](images/scale_10.png)  

- scale backend to 1 pod

  ![](images/scale_11.png) 
   
## Auto Scale Application
- Add HorizontalPodAutoscaler
- Go to Topology, click at Duke icon for open backend deployment, click action dropdown menu, select Add HorizontalPodAutoscaler
  ![](images/scale_12.png) 
- in Add HorizontalPodAutoscaler, use Form view
  - set Name: example
  - Minimum Pods: `1`
  - Maximum Pods: `3`
  - CPU Utilization: `10%`
  
  ![](images/scale_13.png) 

- click save, and wait until backend deployment change to Autoscaling

  ![](images/scale_14.png) 

- load test to backend application for proof auto scale
- go to web terminal
- run load test command

  ```bash
  BACKEND_URL=https://$(oc get route backend -o jsonpath='{.spec.host}')
  while [  1  ];
  do
    curl $BACKEND_URL/backend
    printf "\n"
  done
  ```

- click detail tab of backend deployment, wait until autoscaled to 3 (wait a few minutes)

  ![](images/scale_15.png)   

- click resources tab, see 3 pods auto scale

  ![](images/scale_16.png)

- click Observe tab to view CPU usage 

  ![](images/scale-99.png)

- back to web terminal, input 'ctrl-c' to terminate load test command
- wait 5 minute, autoscaled will reduce pod to 1. **(if you don't want to wait autoscale down to 1 pod, you can remove HorizontalPodAutoscaler and manual scale down to 1 by yourself.)**

  ![](images/scale_18.png)

- remove HorizontalPodAutoscaler, go to backend deployment information page, select action menu, select remove HorizontalPodAutoscaler

  ![](images/scale_19.png)      

- confirm Remove, and wait until backend change to manual scale

  ![](images/scale_20.png)  

  ![](images/scale_11.png) 

- **Optional: if you don't want to wait autoscale down to 1 pod, you can remove HorizontalPodAutoscaler and manual scale down to 1 by yourself.**
  
## Back to Table of Content
- [Best Practices for Develop Cloud-Native Application](README.md)


