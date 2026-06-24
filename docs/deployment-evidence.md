# Deployment Evidence

## Cluster Verification

kubectl get nodes

Result:
1 Ready Control Plane Node

## Application Verification

kubectl get pods -n hello-world

Result:
1 Running Pod

## Service Verification

kubectl get svc -n hello-world

Result:
NodePort Service Exposed

## Browser Verification

Application accessible successfully through:

http://<PUBLIC_IP>:30080