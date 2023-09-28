
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Container Volume Usage Incident.
---

A Container Volume Usage Incident occurs when the usage of a container volume exceeds a certain threshold. This incident is triggered by an alert when the usage of the container volume goes above the predefined limit. The incident is created to notify the relevant team or individual about the issue so that they can take necessary actions to resolve it. The incident may include information about the affected instance, service, team, and the details of the incident, such as the volume usage value and labels. The incident is resolved when the volume usage goes below the threshold, and the team or individual acknowledges the resolution.

### Parameters
```shell
export PVC_NAME="PLACEHOLDER"

export NAMESPACE="PLACEHOLDER"

export POD_NAME="PLACEHOLDER"

export CONTAINER_NAME="PLACEHOLDER"

export EVENT_NAME="PLACEHOLDER"

export DEPLOYMENT_NAME="PLACEHOLDER"

export NEW_VOLUME_SIZE="PLACEHOLDER"

export VOLUME_NAME="PLACEHOLDER"
```

## Debug

### List all persistent volumes (PVs)
```shell
kubectl get pv
```

### List all persistent volume claims (PVCs)
```shell
kubectl get pvc
```

### Describe a specific PVC
```shell
kubectl describe pvc ${PVC_NAME}
```

### List all pods in the namespace
```shell
kubectl get pods -n ${NAMESPACE}
```

### Describe a specific pod
```shell
kubectl describe pod ${POD_NAME} -n ${NAMESPACE}
```

### List all containers in a pod
```shell
kubectl get pods ${POD_NAME} -n ${NAMESPACE} -o jsonpath='{.spec.containers[*].name}'
```

### Check container logs for a specific container in a pod
```shell
kubectl logs ${POD_NAME} -n ${NAMESPACE} ${CONTAINER_NAME}
```

### List all events in the namespace
```shell
kubectl get events -n ${NAMESPACE}
```

### Describe a specific event
```shell
kubectl describe event ${EVENT_NAME} -n ${NAMESPACE}
```

### The container has consumed an excessive amount of data, causing the volume usage to exceed its limit.
```shell


#!/bin/bash



# Set the namespace and pod name variables

NAMESPACE=${NAMESPACE}

POD_NAME=${POD_NAME}



# Get the disk usage for the pod

DISK_USAGE=$(kubectl exec -n $NAMESPACE $POD_NAME -- df -h / | awk 'NR==2{print $5}')



# Get the disk limit for the pod

DISK_LIMIT=$(kubectl describe pod -n $NAMESPACE $POD_NAME | grep -i 'limit' | awk '{print $2}')



# Check if the disk usage is greater than the limit

if [ $DISK_USAGE -gt $DISK_LIMIT ]; then

  # Alert the team about the incident

  echo "Container has exceeded the disk limit. Disk usage: $DISK_USAGE, Disk limit: $DISK_LIMIT"

  # Collect logs and metrics for further analysis

  kubectl logs -n $NAMESPACE $POD_NAME > pod_logs.txt

  kubectl describe pod -n $NAMESPACE $POD_NAME > pod_description.txt

  # Restart the pod to release the disk space

  kubectl delete pod -n $NAMESPACE $POD_NAME

fi


```

### The container is not set up to auto-scale, and the amount of data being processed is too large for the current container configuration.
```shell


#!/bin/bash



# Set the namespace and deployment name

NAMESPACE=${NAMESPACE}

DEPLOYMENT_NAME=${DEPLOYMENT_NAME}



# Get the current replica count

REPLICA_COUNT=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o=jsonpath='{.spec.replicas}')



# Get the CPU and memory usage of the current pods

CPU_USAGE=$(kubectl top pods -n $NAMESPACE | grep $DEPLOYMENT_NAME | awk '{print $2}')

MEMORY_USAGE=$(kubectl top pods -n $NAMESPACE | grep $DEPLOYMENT_NAME | awk '{print $3}')



# Get the CPU and memory requests and limits of the deployment

CPU_REQUEST=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o=jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')

MEMORY_REQUEST=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o=jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')

CPU_LIMIT=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o=jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}')

MEMORY_LIMIT=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o=jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}')



# Check if the CPU or memory usage is exceeding the requests or limits

if [[ $CPU_USAGE -gt $CPU_REQUEST ]] || [[ $MEMORY_USAGE -gt $MEMORY_REQUEST ]]; then

    echo "CPU or memory usage is exceeding the requests. Please check the container configuration."

    exit 1

elif [[ $CPU_USAGE -gt $CPU_LIMIT ]] || [[ $MEMORY_USAGE -gt $MEMORY_LIMIT ]]; then

    echo "CPU or memory usage is exceeding the limits. Please check the container configuration."

    exit 1

elif [[ $REPLICA_COUNT -lt 2 ]]; then

    echo "The current replica count is too low. Please consider increasing the replica count to handle the workload."

    exit 1

else

    echo "The container configuration is sufficient to handle the workload."

    exit 0

fi


```

## Repair

### Increase the size of the container volume or add a new volume to accommodate additional data.
```shell


#!/bin/bash



# Set the name of the deployment and container volume.

DEPLOYMENT_NAME=${DEPLOYMENT_NAME}

VOLUME_NAME=${VOLUME_NAME}



# Set the size of the new container volume.

NEW_VOLUME_SIZE=${NEW_VOLUME_SIZE}



# Resize the container volume.

# If the volume already exists, use this command to resize it:

kubectl patch persistentvolumeclaim $VOLUME_NAME -p '{"spec":{"resources":{"requests":{"storage":"'$NEW_VOLUME_SIZE'"}}}}'



# If a new volume needs to be added, use this command instead:

kubectl apply -f - <<EOF

apiVersion: v1

kind: PersistentVolumeClaim

metadata:

  name: $VOLUME_NAME

spec:

  accessModes:

  - ReadWriteOnce

  resources:

    requests:

      storage: $NEW_VOLUME_SIZE

EOF



# Scale the deployment to apply the changes.

kubectl scale deployment $DEPLOYMENT_NAME --replicas=0

kubectl scale deployment $DEPLOYMENT_NAME --replicas=1


```