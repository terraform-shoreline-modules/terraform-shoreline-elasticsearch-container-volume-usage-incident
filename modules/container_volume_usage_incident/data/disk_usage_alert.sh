

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