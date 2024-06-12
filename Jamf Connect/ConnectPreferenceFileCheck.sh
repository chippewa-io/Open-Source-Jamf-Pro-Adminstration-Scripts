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
# Title: Jamf Connect License Report
# Date: 6/7/24
# Author: Chris Cohoon, Chippewa Limited Liability Co.
# Version: 1.0
# Target OS: macOS Sonoma
# ----------------------------------------------------------------------------------------------------------------------------
# Version Control:
#
# 1.0 - Initial Release - 6/7/24 - Chris Cohoon, Chippewa Limited Liability Co.
#       
#----------------------------------------------------------------------------------------------------------------------------
# Purpose: 
#
# A common issue found in many Jamf Connect deployments are conflicting Configuration Profiles. When this occurs, 
# the license file referenced in the conflicting Configuration Profiles can cause you to have multiple LicenseFile
# valuse. This leads Jamf Connect to appear to be in an unlicensed state, effecticely graying out 
# and disabling all of it's features.
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
# - Jamf Connect
# - Administrative privileges (script requires that you run it with sudo)
#
# ----------------------------------------------------------------------------------------------------------------------------

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Expected License File String
expectedLicenseFile=""

# Get a list of all user directories, excluding .localized and Shared
allUsers=$(ls /Users | grep -v '^\.localized$' | grep -v '^Shared$')

# Define the base array
jamfConnectPlists=(
    "/Library/Managed Preferences"
    "/Library/Preferences"
)

# Append user-specific paths to the array
for user in $allUsers; do
    jamfConnectPlists+=("/Library/Managed Preferences/$user")
    jamfConnectPlists+=("/Users/$user/Library/Preferences")
done

# Define the report file path
report_file="/tmp/JamfConnectLicenseReport.txt"

# Initialize the report file
{
    echo "${BLUE}===============================${NC}"
    echo "${BLUE}= Jamf Connect License Report =${NC}"
    echo "${BLUE}===============================${NC}"
    echo ""
    echo "${YELLOW}Directories being checked:${NC}"
    for path in "${jamfConnectPlists[@]}"; do
        echo "$path"
    done
    echo ""
    echo "============================================="
} > "$report_file"

# Track the first found LicenseFile content
firstLicenseFileContent=""

# Search for plist files containing 'jamf' in their names and check for "LicenseFile" key
for path in "${jamfConnectPlists[@]}"; do
    {
        echo "${YELLOW}Checking path: $path${NC}"
        echo "============================================="
    } >> "$report_file"
    # Find plists containing 'jamf' in their names, excluding those that reference "jamfsoftware"
    plists_found=false
    find "$path" -name '*jamf*.plist' ! -name '*jamfsoftware*.plist' 2>/dev/null | while read -r plist; do
        plists_found=true
        {
            echo "${BLUE}Found plist:${NC} $plist"
            licenseFileContents=$(defaults read "$plist" LicenseFile 2>/dev/null)
            if [ $? -eq 0 ]; then
                echo "${GREEN}LicenseFile key found in:${NC} $plist"
                if [ -n "$expectedLicenseFile" ]; then
                    if [ "$licenseFileContents" = "$expectedLicenseFile" ]; then
                        echo "${GREEN}Matched 'LicenseFile' key in:${NC} $plist"
                    else
                        echo "${RED}Mismatched 'LicenseFile' key in:${NC} $plist"
                        echo "${RED}Contents of 'LicenseFile' key:${NC}"
                        echo "${RED}$licenseFileContents${NC}"
                    fi
                else
                    if [ -z "$firstLicenseFileContent" ]; then
                        firstLicenseFileContent="$licenseFileContents"
                        echo "${GREEN}Contents of 'LicenseFile' key:${NC}"
                        echo "${GREEN}$licenseFileContents${NC}"
                    else
                        if [ "$licenseFileContents" = "$firstLicenseFileContent" ]; then
                            echo "${GREEN}Contents of 'LicenseFile' key:${NC}"
                            echo "${GREEN}$licenseFileContents${NC}"
                        else
                            echo "${RED}Contents of 'LicenseFile' key:${NC}"
                            echo "${RED}$licenseFileContents${NC}"
                        fi
                    fi
                fi
            else
                echo "${RED}LicenseFile key not found in:${NC} $plist"
            fi
            echo ""
            echo "---------------------------------------------"
        } >> "$report_file"
    done
    if ! $plists_found; then
        {
            echo "${RED}No plist files found in:${NC} $path"
            echo "---------------------------------------------"
        } >> "$report_file"
    fi
done

# Print the report contents
cat "$report_file"

# Print a message indicating where the report has been saved
echo "${BLUE}Report saved to $report_file${NC}"