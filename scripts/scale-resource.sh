#!/bin/bash
set -e

RELEASE="my-nginx"
NAMESPACE="default"
CHART="./my-nginx"

echo "=========================================="
echo " PRECHECK: Current pod resources (BEFORE)"
echo "=========================================="

POD=$(kubectl get pods -n "$NAMESPACE" -l app="$RELEASE" -o jsonpath='{.items[0].metadata.name}')
echo "Pod name: $POD"

OLD_CPU_REQ=$(kubectl get pod "$POD" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].resources.requests.cpu}')
OLD_MEM_REQ=$(kubectl get pod "$POD" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].resources.requests.memory}')
OLD_CPU_LIM=$(kubectl get pod "$POD" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].resources.limits.cpu}')
OLD_MEM_LIM=$(kubectl get pod "$POD" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].resources.limits.memory}')

echo "CPU Request (before)    : $OLD_CPU_REQ"
echo "Memory Request (before) : $OLD_MEM_REQ"
echo "CPU Limit (before)      : $OLD_CPU_LIM"
echo "Memory Limit (before)   : $OLD_MEM_LIM"

echo ""
echo "=========================================="
echo " UPDATE: Calculating new resource values"
echo "=========================================="

CPU_NUM=$(echo "$OLD_CPU_LIM" | tr -d 'm')
NEW_CPU_LIM="$((CPU_NUM + 100))m"
NEW_CPU_REQ="$((CPU_NUM + 50))m"

MEM_NUM=$(echo "$OLD_MEM_LIM" | tr -d 'Mi')
NEW_MEM_LIM="$((MEM_NUM + 128))Mi"
NEW_MEM_REQ="$((MEM_NUM + 64))Mi"

echo "New CPU Request    : $NEW_CPU_REQ"
echo "New Memory Request : $NEW_MEM_REQ"
echo "New CPU Limit      : $NEW_CPU_LIM"
echo "New Memory Limit   : $NEW_MEM_LIM"

echo ""
echo "Applying update via Helm..."
helm upgrade "$RELEASE" "$CHART" \
  -n "$NAMESPACE" \
  --reuse-values \
  --set resources.requests.cpu="$NEW_CPU_REQ" \
  --set resources.requests.memory="$NEW_MEM_REQ" \
  --set resources.limits.cpu="$NEW_CPU_LIM" \
  --set resources.limits.memory="$NEW_MEM_LIM"

echo "Waiting for rollout to complete..."
kubectl rollout status deployment/"$RELEASE" -n "$NAMESPACE"

echo ""
echo "=========================================="
echo " POSTCHECK: Confirming new pod resources (AFTER)"
echo "=========================================="

NEW_POD=$(kubectl get pods -n "$NAMESPACE" -l app="$RELEASE" -o jsonpath='{.items[0].metadata.name}')
echo "New pod name: $NEW_POD"

FINAL_CPU_REQ=$(kubectl get pod "$NEW_POD" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].resources.requests.cpu}')
FINAL_MEM_REQ=$(kubectl get pod "$NEW_POD" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].resources.requests.memory}')
FINAL_CPU_LIM=$(kubectl get pod "$NEW_POD" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].resources.limits.cpu}')
FINAL_MEM_LIM=$(kubectl get pod "$NEW_POD" -n "$NAMESPACE" -o jsonpath='{.spec.containers[0].resources.limits.memory}')

echo "CPU Request (after)    : $FINAL_CPU_REQ"
echo "Memory Request (after) : $FINAL_MEM_REQ"
echo "CPU Limit (after)      : $FINAL_CPU_LIM"
echo "Memory Limit (after)   : $FINAL_MEM_LIM"

echo ""
echo "=========================================="
echo " SUMMARY"
echo "=========================================="
echo "CPU Limit    : $OLD_CPU_LIM  -->  $FINAL_CPU_LIM"
echo "Memory Limit : $OLD_MEM_LIM  -->  $FINAL_MEM_LIM"
echo "Vertical scaling completed successfully."
