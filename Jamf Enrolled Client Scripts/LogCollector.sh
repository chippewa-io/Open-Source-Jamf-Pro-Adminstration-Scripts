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
# Title: Log Collector.sh
# Date: 9/13/24
# Author: Chris Cohoon, Chippewa Limited Liability Co.
# Version: 1.0
# Target OS: macOS Sonoma
# ----------------------------------------------------------------------------------------------------------------------------
# Version Control:
#
# 1.0 - Initial Release - 9/13/24 - Chris Cohoon, Chippewa Limited Liability Co.
#       
#
#----------------------------------------------------------------------------------------------------------------------------
# Purpose:
#  This script will gather a log file that is defined in a Jamf Policy as $4 and send it to a webhook URL that is defined in
#  the same policy as $5. The log file will be compressed into a zip archive before being sent to the webhook.
# 
# The intention then, is that webhook will publish the log file to something like Google Drive, or other repository for easy
# access by an Administrator.
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
# - A system that can receive a webhook, and process it accordingly. (Zapier, ActivePieces, Flask Server, etc.)
# - macOS Sonoma 
#
# ----------------------------------------------------------------------------------------------------------------------------

# Current Logged in user
user=$(stat -f %Su /dev/console)
# Current Date and time 
date=$(date +%s)
# Current Hostname
hostname=$(hostname)

# Get the log file path from argument $4
LOG_FILE="$4"

# Get the webhook URL from argument $5
WEBHOOK_URL="$5"

# Check that both arguments are provided
if [ -z "$LOG_FILE" ] || [ -z "$WEBHOOK_URL" ]; then
  echo "Usage: $0 <log_file> <webhook_url>"
  echo "If being utilized in a Jamf Pro Server, ensure that the script is being called with the correct parameters."
  echo "The script expects to have a log file path as argument $4 and a webhook URL as argument $5."
  exit 1
fi

# Check that the log file exists
if [ ! -f "$LOG_FILE" ]; then
  echo "Error: Log file '$LOG_FILE' does not exist."
  echo "Please ensure that the log file path is correct and that you have not escaped any spaces in the path. The script will properly handle spaces."
  echo "For example, /path/to/log file.log is correct, but /path/to/log\ file.log is incorrect."
  exit 2
fi

# Check that the webhook URL starts with https
if [[ ! "$WEBHOOK_URL" =~ ^https:// ]]; then
  echo "Error: Webhook URL '$WEBHOOK_URL' is not a valid URL or does not start with https."
  echo "http URLs are not supported for security reasons. Please ensure that the webhook URL is a valid https URL."
  exit 3
fi

# Create a temporary directory for the zip file
TEMP_DIR=$(mktemp -d)
# Name compressed file with the above variables ^^ 
ZIP_FILE="${hostname}-${user}-${date}_PrivilegeElevationReportLog.zip"

# Compress the log file into a zip archive
zip -j "$ZIP_FILE" "$LOG_FILE"
if [ $? -ne 0 ]; then
  echo "Error: Failed to zip the log file."
  rm -r "$TEMP_DIR"
  exit 4
fi

# Send the zip file to the webhook using curl (and store response in a variable)
response=$(curl -X POST -F "file=@$ZIP_FILE" "$WEBHOOK_URL")
if [ $? -ne 0 ]; then
  echo "Error: Failed to send the zip file to the webhook."
  echo "Curl response:"
  echo ""
  echo "$response"
  echo ""
  rm -r "$TEMP_DIR"
  exit 5
fi



# Clean up temporary files
rm -r "$TEMP_DIR"
if [ $? -ne 0 ]; then
  echo "Warning: Failed to clean up temporary files."
fi

echo "Success: Log file has been sent to the webhook!"
exit 0 #All other exit codes are handled above. This is the only successful exit code.