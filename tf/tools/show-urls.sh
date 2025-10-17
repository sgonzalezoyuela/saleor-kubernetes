#!/usr/bin/env bash

# Script to display public URLs for Saleor services
# Works with both GKE (public IPs) and Talos/internal deployments

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get namespace from argument or use default
NAMESPACE=${1:-saleor-demo}

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Saleor Service URLs - Namespace: ${NAMESPACE}${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo -e "${YELLOW} Namespace '$NAMESPACE' not found${NC}"
    echo ""
    echo "Available namespaces:"
    kubectl get namespaces | grep saleor || echo "  (no saleor namespaces found)"
    exit 1
fi

# Function to get service info
get_service_url() {
    local service_name=$1
    local service_port=$2
    local prefix=$3

    local service_type=$(kubectl get svc "$service_name" -n "$NAMESPACE" -o jsonpath='{.spec.type}' 2>/dev/null || echo "")

    if [ -z "$service_type" ]; then
        echo "  ⊗ ${service_name}: Not found"
        return
    fi

    if [ "$service_type" = "LoadBalancer" ]; then
        local external_ip=$(kubectl get svc "$service_name" -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")

        if [ -n "$external_ip" ]; then
            echo -e "  ${GREEN}${NC} ${prefix}: http://${prefix}.${external_ip}.nip.io:${service_port}"
        else
            echo -e "  ${YELLOW}${NC} ${prefix}: <pending LoadBalancer IP>"
        fi
    else
        # ClusterIP - show internal address
        local cluster_ip=$(kubectl get svc "$service_name" -n "$NAMESPACE" -o jsonpath='{.spec.clusterIP}' 2>/dev/null || echo "")
        echo -e "  ${BLUE}ℹ${NC} ${prefix}: ${service_name}.${NAMESPACE}.svc.cluster.local:${service_port} (ClusterIP: ${cluster_ip})"
    fi
}

echo -e "${YELLOW}Services:${NC}"
echo ""

# Get all services
get_service_url "saleor-api" "8000" "API       "
get_service_url "saleor-dashboard" "9000" "Dashboard"
get_service_url "saleor-storefront" "3000" "Storefront"
get_service_url "dummy-payment-app" "3000" "Payment   "

echo ""
echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
echo ""

# Show GraphQL endpoint specifically
api_type=$(kubectl get svc saleor-api -n "$NAMESPACE" -o jsonpath='{.spec.type}' 2>/dev/null || echo "")
if [ "$api_type" = "LoadBalancer" ]; then
    api_ip=$(kubectl get svc saleor-api -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ -n "$api_ip" ]; then
        echo -e "${GREEN} GraphQL Endpoint:${NC}"
        echo "   http://api.${api_ip}.nip.io:8000/graphql/"
        echo ""
    fi
fi

# Show port-forward commands for ClusterIP services
if [ "$api_type" = "ClusterIP" ]; then
    echo -e "${YELLOW} To access services locally, use port-forwarding:${NC}"
    echo ""
    echo "   kubectl port-forward -n $NAMESPACE svc/saleor-api 8000:8000"
    echo "   kubectl port-forward -n $NAMESPACE svc/saleor-dashboard 9000:9000"
    echo "   kubectl port-forward -n $NAMESPACE svc/saleor-storefront 3000:3000"
    echo "   kubectl port-forward -n $NAMESPACE svc/dummy-payment-app 3001:3000"
    echo ""
fi

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
