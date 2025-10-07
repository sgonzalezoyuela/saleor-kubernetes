#!/usr/bin/env bash
# Clean up script for removing Terraform-created resources
# Check namespace
#
NAMESPACE=$1
if [ -z "$NAMESPACE" ]; then
    echo "[WARN]  NAMESPACE is not provided: usage clean.sh <namespace>"
    exit 1
else
    echo "[  OK  ] NAMESPACE  is set to: $NAMESPACE"
fi

# Optional: Delete the namespace itself
echo "Do you want to delete resources from namespace $NAMESPACE? (y/n)"
read -r response
if [[ "$response" == "y" ]]; then
    echo "Deleting ...."
else
    echo "Aborting ...."
    exit 0
fi

echo "Cleaning up Saleor deployment in namespace $NAMESPACE..."

# Delete all resources in the namespace
echo "Deleting all resources in $NAMESPACE namespace..."
kubectl delete all --all -n $NAMESPACE

# Delete PVCs
echo "Deleting PersistentVolumeClaims..."
kubectl delete pvc --all -n $NAMESPACE

# Delete ConfigMaps
echo "Deleting ConfigMaps..."
kubectl delete configmap --all -n $NAMESPACE

# Delete Ingress
echo "Deleting Ingress..."
kubectl delete ingress --all -n $NAMESPACE

# Delete the custom StorageClass if it exists
echo "Deleting custom StorageClass..."
kubectl delete storageclass saleor-storage --ignore-not-found=true

# Optional: Delete the namespace itself
echo "Do you want to delete the namespace $NAMESPACE? (y/n)"
read -r response
if [[ "$response" == "y" ]]; then
    kubectl delete namespace $NAMESPACE
    echo "Namespace deleted."
else
    echo "Namespace kept."
fi

echo "Cleanup complete!"
