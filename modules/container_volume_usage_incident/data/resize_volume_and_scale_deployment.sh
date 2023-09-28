

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