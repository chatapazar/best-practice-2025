# Implement Application Resiliency
<!-- TOC -->

- [Implement Application Resiliency](#implement-application-resiliency)
  - [Current Topology](#current-topology)
  - [Traffic Management](#traffic-management)
  - [Back to Table of Content](#back-to-table-of-content)

<!-- /TOC -->

## Current Topology

## Traffic Management

DOMAIN=$(oc whoami --show-console|awk -F'apps.' '{print $2}')
echo $DOMAIN

FRONTEND_ISTIO_ROUTE=$(oc get route -n istio-system|grep mesh-userX-frontend-gateway |awk '{print $2}')
curl http://$FRONTEND_ISTIO_ROUTE

FRONTEND_ISTIO_ROUTE=$(oc get route -n istio-system|grep mesh-userX-frontend-gateway |awk '{print $2}')
while [ 1 ];
do
        OUTPUT=$(curl -s $FRONTEND_ISTIO_ROUTE)
        printf "%s\n" $OUTPUT
        sleep .2
done

## Back to Table of Content
- [Best Practices for Develop Cloud-Native Application](README.md)





