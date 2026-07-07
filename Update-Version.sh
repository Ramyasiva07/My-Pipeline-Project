#!/bin/bash
set -e

RELEASE_NAME="my-nginx"
NAMESPACE="default"
CHART="bitnami/nginx"

echo "=== Step 1: Get current deployed version ==="
CURRENT_TAG=$(helm get values "$RELEASE_NAME" -n "$NAMESPACE" -o json | grep -o '"tag": *"[^"]*"' | sed 's/.*"tag": *"\(.*\)"/\1/')
echo "Current NGINX version deployed: $CURRENT_TAG"

echo "=== Step 2: Calculate next version ==="
# splits 1.25.3 into 1.25 and 3, bumps patch number: 3 -> 4
MAJOR_MINOR=$(echo "$CURRENT_TAG" | cut -d. -f1,2)
PATCH=$(echo "$CURRENT_TAG" | cut -d. -f3)
NEW_PATCH=$((PATCH + 1))
NEW_TAG="$MAJOR_MINOR.$NEW_PATCH"
echo "New NGINX version to deploy: $NEW_TAG"

echo "=== Step 3: Upgrade Helm release to new version ==="
helm upgrade "$RELEASE_NAME" "$CHART" \
  -n "$NAMESPACE" \
  --reuse-values \
  --set image.tag=$NEW_TAG

echo "=== Step 4: Wait for rollout to finish ==="
kubectl rollout status deployment/"$RELEASE_NAME" -n "$NAMESPACE"

echo "SUCCESS: NGINX updated from $CURRENT_TAG to $NEW_TAG"
