#!/usr/bin/env bash
# A script to manage multiple kubectl port-forwards and clean them up gracefully.
NAMESPACE=$1
if [ -z "$NAMESPACE" ]; then
    echo "[WARN]  NAMESPACE is not provided: usage clean.sh <namespace>"
    exit 1
else
    echo "[  OK  ] NAMESPACE  is set to: $NAMESPACE"
fi

# --- Configuration ---
# Add the services and their port mappings you want to forward.
# Format: ["service-name"]="LOCAL_PORT:REMOTE_PORT"
declare -A forwards=(
    ["saleor-api"]="8000"
    ["saleor-dashboard"]="9000"
    ["saleor-storefront"]="3000"
    ["dummy-payment-app"]="3001:3000"
    ["saleor-mailpit"]="8025"
)

# Array to store the PIDs of the background processes
pids=()

# Function to clean up and kill all backgrounded port-forward processes
cleanup() {
    echo -e "\nStopping all port-forwards..."
    for pid in "${pids[@]}"; do
        # Check if the process exists before trying to kill it
        if ps -p "$pid" >/dev/null; then
            kill "$pid"
        fi
    done
    echo "Cleanup complete."
    exit 0
}

# Set a trap to call the cleanup function on script exit (Ctrl+C, etc.)
trap cleanup SIGINT SIGTERM EXIT

# --- Main Script ---
echo "Starting port-forwards in namespace '$NAMESPACE'..."
echo "-------------------------------------------"

# Iterate over the associative array and start each port-forward
for service in "${!forwards[@]}"; do
    ports=${forwards[$service]}
    echo "-> Forwarding service 'svc/$service' to '$ports'"

    # Start kubectl in the background
    kubectl port-forward --namespace "$NAMESPACE" "svc/$service" "$ports" &

    # Store its Process ID (PID) in our array
    pids+=($!)
done

echo -e "\n[  OK  ] All services are being forwarded in the background."
echo "Press Ctrl+C to stop all of them."

# Wait indefinitely for the trap to be triggered
wait
