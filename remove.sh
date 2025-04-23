#!/bin/bash

# --- Configuration ---
# Define the pattern to find unwanted services.
# BE VERY CAREFUL WITH THIS! Adjust it so that it ONLY matches the services you want to process.
# Test this pattern separately first with 'networksetup -listallnetworkservices | grep "YOUR_PATTERN_HERE"'
SERVICE_PATTERN="USB 10/100/1000 LAN"

# --- Script Start ---

echo "Searching for network services matching the pattern: '$SERVICE_PATTERN'"

# Get the list of services and filter the relevant ones.
# We populate the array using a while read loop for better compatibility.
services_to_process=()
while IFS= read -r service_name_raw; do
    # Remove leading asterisk and trim whitespace directly after reading
    cleaned_service_name=$(echo "$service_name_raw" | sed 's/^*//' | xargs)
    if [[ -n "$cleaned_service_name" ]]; then
        services_to_process+=("$cleaned_service_name")
    fi
done < <(networksetup -listallnetworkservices | grep "$SERVICE_PATTERN" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | grep -v "^$")


# Check if any services were found after cleaning
if [ ${#services_to_process[@]} -eq 0 ]; then
    echo "No services found matching the pattern '$SERVICE_PATTERN' or the found names could not be cleaned."
    exit 0
fi

echo ""
echo "The following services were found (cleaned for use):"
# Display the found services with numbers
for i in "${!services_to_process[@]}"; do
    echo "$((i+1)). ${services_to_process[$i]}"
done
echo ""

# Ask the user for a choice
echo "Choose an action for the found services:"
echo "1) Disable"
echo "2) Delete"
echo "3) Cancel"

read -p "Enter the number of your choice: " action_choice

echo ""

# Execute the chosen action
case $action_choice in
    1)
        echo "Action chosen: Disable"
        read -r -p "Are you sure you want to disable these services? (yes/no): " confirm_disable
        if [[ "$confirm_disable" =~ ^[Yy][Ee][Ss]$ ]]; then
            sudo -v # Ask for password at the start of the action
            for service_name in "${services_to_process[@]}"; do
                echo "Disabling service: $service_name"
                sudo networksetup -setnetworkserviceenabled "$service_name" off
                if [ $? -eq 0 ]; then
                    echo "Successfully disabled."
                else
                    echo "Error disabling $service_name. Check the name and try manually if needed."
                fi
                # sleep 0.1 # Optional pause
            done
            echo "Disabling complete."
        else
            echo "Action cancelled by user."
        fi
        ;;
    2)
        echo "Action chosen: Delete"
        read -r -p "ARE YOU SURE you want to permanently delete these services? This cannot be undone! (yes/no): " confirm_delete
        if [[ "$confirm_delete" =~ ^[Yy][Ee][Ss]$ ]]; then
             sudo -v # Ask for password at the start of the action
            for service_name in "${services_to_process[@]}"; do
                echo "Deleting service: $service_name"
                # We use networksetup -deletepppoeservice as you discovered
                sudo networksetup -deletepppoeservice "$service_name"
                 if [ $? -eq 0 ]; then
                    echo "Successfully deleted."
                else
                    echo "Error deleting $service_name. Check the name and try manually if needed."
                    # The error about being the last service on a port is less likely here,
                    # as deletepppoeservice seems to work differently.
                 fi
                # sleep 0.1 # Optional pause
            done
            echo "Deletion complete. You may need to close and reopen Network Preferences to refresh the list."
        else
            echo "Action cancelled by user."
        fi
        ;;
    3)
        echo "Action cancelled."
        ;;
    *)
        echo "Invalid choice. Action cancelled."
        ;;
esac

exit 0