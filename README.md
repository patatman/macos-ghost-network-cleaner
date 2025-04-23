# macOS Network Service Cleaner

This bash script helps clean up the network list in macOS System Settings by identifying and managing unwanted or "ghost" network services. This is particularly useful when connecting devices like monitors or docks with built-in network adapters results in a long list of inactive network interfaces that persist in the list.

The script provides an interactive way to disable or permanently delete found services via the Terminal.

## Problem

After connecting and disconnecting certain network devices (such as monitors/docks with Ethernet ports connected via Thunderbolt or USB), macOS may retain the configuration of these network interfaces. This results in a growing list of services in Network Preferences, which can be confusing and potentially impact network startup times. Manually deleting them through the GUI can be tedious when dealing with a large number of services.

## Solution

This script automates the process of finding and managing these unwanted network services with the help of the `networksetup` command-line tool.

## Features

* Searches for network services based on a configurable text pattern.
* Displays the found services to the user.
* Offers an interactive menu to choose between disabling or deleting the found services.
* Executes the chosen action for each identified service.
* Uses `sudo` for necessary permissions.

## Prerequisites

* A Mac running macOS.
* Access to the Terminal.
* Administrator privileges (to use `sudo`).

## Installation

1.  Clone this repository or download the `clean_network.sh` file directly.
2.  Open the Terminal application.
3.  Navigate to the directory where you saved the script:
    ```bash
    cd /path/to/your/directory
    ```
4.  Make the script executable:
    ```bash
    chmod +x clean_network.sh
    ```

## Usage

1.  **Configure the Search Pattern:** Open the `clean_network.sh` file in a text editor. Find the line that starts with `SERVICE_PATTERN=`. Modify the pattern within the quotes (`"..."`) so that it **ONLY** matches the names of the network services you want to handle (e.g., those related to your monitor or dock).

    **CRITICAL:** Test this pattern thoroughly before running the script! You can test the pattern by running the following command in the Terminal and checking if only the unwanted services are listed:
    ```bash
    networksetup -listallnetworkservices | grep "YOUR_PATTERN_HERE"
    ```
    Replace `"YOUR_PATTERN_HERE"` with the pattern you intend to use in the script.

2.  **Run the Script:** In Terminal, navigate to the script's directory (if you haven't already) and execute it:
    ```bash
    ./clean_network.sh
    ```
3.  **Follow the Prompts:**
    * The script will display the services it found based on your pattern.
    * It will ask you to choose an action: Disable, Delete, or Cancel.
    * Enter the number corresponding to your choice and press Enter.
    * The script will prompt for your administrator password before performing actions requiring `sudo`.
    * Confirm the chosen action when prompted (by typing `yes`).

---

## ✨ Note on Script Origin ✨

This script was iteratively developed with the assistance of a large language model (Gemini). While the process involved some "vibe coding" through trial and error based on troubleshooting a specific user's issue, the resulting code has been refined and confirmed to work for the problem described. Use with understanding and caution, as with any script that modifies system settings.

---

## Warnings and Disclaimer

* **DELETION IS PERMANENT:** Deleting network services cannot be undone without resetting your network configuration or reconnecting the devices.
* **PATTERN IS CRITICAL:** An incorrectly set `SERVICE_PATTERN` can lead to accidentally disabling or deleting essential network services (like your Wi-Fi or primary Ethernet connection), potentially causing loss of network connectivity. ALWAYS test the pattern with `grep` beforehand.
* **Backup:** It is strongly recommended to back up your system (e.g., using Time Machine) before deleting services. You could also attempt to back up the network configuration files in `/Library/Preferences/SystemConfiguration/`.
* **Use at Your Own Risk:** The author of this script is not responsible for any damage, data loss, or system issues arising from the use of this script. Understand the code and the risks before executing it.

## How it Works (Technical)

The script uses the `networksetup -listallnetworkservices` command to get a list of all services. This list is filtered using `grep` based on the `SERVICE_PATTERN`. The output is then cleaned using `sed` (to remove leading asterisks from disabled services) and `xargs` (for robust whitespace removal). The cleaned names are stored in a Bash array.

Depending on the user's choice, the script iterates through the array and executes the corresponding `networksetup` command for each service name:
* `networksetup -setnetworkserviceenabled "[servicename]" off` to disable the service.
* `networksetup -deletepppoeservice "[servicename]"` to delete the service.

The use of `deletepppoeservice` for non-PPPoE adapters is based on findings that this command can be effective in certain macOS versions and configurations for removing services that cannot otherwise be removed with `removenetworkservice` (often due to the "last service on a port" limitation of that command).

## Contributing

Contributions are welcome! If you have improvements, bug fixes, or suggestions, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.