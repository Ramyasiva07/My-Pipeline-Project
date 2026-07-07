#!/bin/bash
set -e

RELEASE_NAME="my-nginx"
NAMESPACE="default"
CHART="./my-nginx"

CURRENT_TAG=$(kubectl get deployment "$RELEASE_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.template.spec.containers[0].image}" | cut -d':' -f2)
echo "Current NGINX version deployed: $CURRENT_TAG"

echo "=== Step 2: Set the new version ==="

NEW_TAG="1.27.1"

echo "New NGINX version to deploy: $NEW_TAG"

echo "=== Step 3: Upgrade Helm release to new version ==="
helm upgrade "$RELEASE_NAME" "$CHART" \
  -n "$NAMESPACE" \
  --reuse-values \
  --set image.tag=$NEW_TAG

echo "=== Step 4: Wait for rollout to finish ==="
kubectl rollout status deployment/"$RELEASE_NAME" -n "$NAMESPACE"

echo "SUCCESS: NGINX updated from $CURRENT_TAG to $NEW_TAG"
