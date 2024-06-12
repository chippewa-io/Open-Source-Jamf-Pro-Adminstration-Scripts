#!/bin/bash
##############################################################################################################################
#                                                                                                                            #
#                         ██████╗██╗  ██╗██╗██████╗ ██████╗ ███████╗██╗    ██╗ █████╗    ██╗ ██████╗                         #
#                        ██╔════╝██║  ██║██║██╔══██╗██╔══██╗██╔════╝██║    ██║██╔══██╗   ██║██╔═══██╗                        #
#                        ██║     ███████║██║██████╔╝██████╔╝█████╗  ██║ █╗ ██║███████║   ██║██║   ██║                        #
#                        ██║     ██╔══██║██║██╔═══╝ ██╔═══╝ ██╔══╝  ██║███╗██║██╔══██║   ██║██║   ██║                        #
#                        ╚██████╗██║  ██║██║██║     ██║     ███████╗╚███╔███╔╝██║  ██║██╗██║╚██████╔╝                        #
#                         ╚═════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝     ╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝╚═╝ ╚═════╝                         #
#                                                                                                                            #
##############################################################################################################################
# Title: restartConnect.sh
# Date: 6/12/24
# Author: Chris Cohoon, Chippewa Limited Liability Co.
# Version: 1.0
# Target OS: macOS Sonoma
# ----------------------------------------------------------------------------------------------------------------------------
# Version Control:
#
# 1.0 - Initial Release - 6/12/24 - Chris Cohoon, Chippewa Limited Liability Co.
#       
#
#----------------------------------------------------------------------------------------------------------------------------
# Purpose:
#
#  This script will force quit and relaunch Jamf Connect on the target machine.
# 
#
# ----------------------------------------------------------------------------------------------------------------------------
# Legal Disclaimer:
# 
# This script is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
# You may not use this file except in compliance with this License.
# You may obtain a copy of the License at https://creativecommons.org/licenses/by-nc/4.0/legalcode
#
# ----------------------------------------------------------------------------------------------------------------------------
# Warranty Disclaimer:
# 
# This script is provided "as is", without warranty of any kind, express or implied, including but not limited to the
# warranties of merchantability, fitness for a particular purpose, and noninfringement. In no event shall the authors or
# copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise,
# arising from, out of, or in connection with the script or the use or other dealings in the script.
#
# ----------------------------------------------------------------------------------------------------------------------------
# Requirements:
#
#  - Jamf Connect must be installed on the target machine.
#  - Must be run as root.
#
# ----------------------------------------------------------------------------------------------------------------------------
# Variables
LOG_DIR="/Library/Application Support/Chippewa/Logs"
LOG_FILE="$LOG_DIR/jamf_connect.log"
JAMF_CONNECT_APP="/Applications/Jamf Connect.app"

# Create log directory if it doesn't exist
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
fi

# Create log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

# Log the start of the script
log_message "Starting Jamf Connect force quit and relaunch script."

# Check if Jamf Connect is running
JAMF_CONNECT_PID=$(pgrep -f "Jamf Connect")

if [ -n "$JAMF_CONNECT_PID" ]; then
    log_message "Jamf Connect is running with PID: $JAMF_CONNECT_PID. Attempting to force quit."
    
    # Force quit Jamf Connect
    kill -9 "$JAMF_CONNECT_PID"
    sleep 10 #ensure it fully stops
    
    if [ $? -eq 0 ]; then
        log_message "Successfully force quit Jamf Connect."
    else
        log_message "Failed to force quit Jamf Connect."
        exit 1
    fi
else
    log_message "Jamf Connect is not running."
fi

# Relaunch Jamf Connect
log_message "Attempting to relaunch Jamf Connect."
open -a "$JAMF_CONNECT_APP"

if [ $? -eq 0 ]; then
    log_message "Successfully relaunched Jamf Connect."
else
    log_message "Failed to relaunch Jamf Connect."
    exit 1
fi

# Log the end of the script
log_message "Finished Jamf Connect force quit and relaunch script."

exit 0
