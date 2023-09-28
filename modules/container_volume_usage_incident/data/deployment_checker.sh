

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