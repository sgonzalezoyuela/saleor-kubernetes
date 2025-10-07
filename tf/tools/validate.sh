#!/usr/bin/env bash

# A robust script to validate a Terraform environment and configuration.
# Exits immediately if any command fails.
set -e

# --- Configuration ---
KUBE_CONFIG_PATH_REQUIRED=true # Set to false if KUBE_CONFIG_PATH is not a hard requirement
DNS_CHECK_SERVICE="saleor-api" # The service name to check for DNS resolution
# --------------------

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Helper Functions ---

# A reusable function to check for required command-line tools.
check_command() {
    local cmd=$1
    local is_required=${2:-true} # Default to true (required)

    if ! command -v "$cmd" &>/dev/null; then
        if [ "$is_required" = true ]; then
            echo -e "${RED}[ERROR]${NC} Required command not found: ${cmd}. Please install it."
            exit 1
        else
            echo -e "${YELLOW}[WARN ]${NC} Recommended command not found: ${cmd}."
        fi
    else
        echo -e "${GREEN}[  OK  ]${NC} Found command: ${cmd}"
    fi
}

# Checks if a critical hostname resolves to localhost (127.0.0.1).
check_dns_resolution() {
    local namespace=$1 # Receive namespace as an argument
    local hostname="$DNS_CHECK_SERVICE.$namespace.svc.cluster.local"
    local timeout=15
    local count=0

    echo -e "\n--- Checking Local DNS Resolution ---"
    echo -n "Waiting for '$hostname' to resolve to 127.0.0.1 "

    while [ $count -lt $timeout ]; do
        if getent hosts "$hostname" | grep -q '^127\.0\.0\.1'; then
            echo -e "\n${GREEN}[  OK  ]${NC} DNS for '$hostname' resolved successfully!"
            return 0
        fi
        sleep 1
        count=$((count + 1))
        echo -n "."
    done

    echo -e "\n${RED}[ERROR]${NC} Timed out waiting for '$hostname' to resolve."
    echo -e "${RED}       Please ensure 'kubefwd' or a similar local DNS forwarding tool is running.${NC}"
    exit 1
}

# --- Main Logic ---
main() {
    # 1. Validate that a namespace argument was provided
    if [ -z "$1" ]; then
        echo -e "${RED}[ERROR]${NC} Namespace argument is required." >&2
        echo "Usage: $0 <namespace>" >&2
        exit 1
    fi
    local NAMESPACE=$1

    echo -e "${BLUE}Validating Terraform configuration for namespace: '$NAMESPACE'...${NC}"
    echo "================================================================="

    # 2. Check for required dependencies
    echo "Checking for required tools..."
    check_command "terraform"
    check_command "kubectl"
    check_command "k9s" false

    # 3. Check for environment variables and cluster connectivity
    echo -e "\nChecking environment and connectivity..."
    if [ -z "$KUBECONFIG" ]; then
        echo -e "${YELLOW}[INFO ]${NC} KUBECONFIG is not set, using default location (~/.kube/config)."
    else
        echo -e "${GREEN}[  OK  ]${NC} KUBECONFIG is set to: $KUBECONFIG"
    fi

    if [ "$KUBE_CONFIG_PATH_REQUIRED" = true ] && [ -z "$KUBE_CONFIG_PATH" ]; then
        echo -e "${RED}[ERROR]${NC} KUBE_CONFIG_PATH is not set. This is required by the Terraform configuration."
        exit 1
    else
        echo -e "${GREEN}[  OK  ]${NC} KUBE_CONFIG_PATH is set to: $KUBE_CONFIG_PATH"
    fi

    if kubectl cluster-info &>/dev/null; then
        echo -e "${GREEN}[  OK  ]${NC} Connected to Kubernetes cluster."
    else
        echo -e "${RED}[ERROR]${NC} Cannot connect to Kubernetes cluster. Check KUBECONFIG."
        exit 1
    fi

    # 4. Validate local DNS resolution is working
    check_dns_resolution "$NAMESPACE"

    # 5. Initialize and validate Terraform
    echo -e "\n--- Running Terraform Checks ---"

    echo "Initializing Terraform..."
    if ! output=$(terraform init -no-color 2>&1); then
        echo -e "${RED}[ERROR]${NC} Terraform initialization failed:"
        echo "$output"
        exit 1
    fi
    echo -e "${GREEN}[  OK  ]${NC} Terraform initialized successfully."

    echo "Validating Terraform configuration..."
    terraform validate -no-color
    echo -e "${GREEN}[  OK  ]${NC} Terraform configuration is valid."

    echo ""
    echo "================================================================="
    echo -e "${GREEN}[  OK  ]${NC} Validation complete! The environment is ready!"
}

# Pass all command-line arguments to the main function
main "$@"
