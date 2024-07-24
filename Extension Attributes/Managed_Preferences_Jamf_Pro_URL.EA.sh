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
# Title: Managed_Preferences_Jamf_Pro_URL.EA.sh
# Date: 7/24/24
# Author: Chris Cohoon, Chippewa Limited Liability Co.
# Version: 1.0
# Target OS: macOS Sonoma
# ----------------------------------------------------------------------------------------------------------------------------
# Version Control:
#
# 1.0 - Initial Release - 7/24/24 - Chris Cohoon, Chippewa Limited Liability Co.
#       
#
#----------------------------------------------------------------------------------------------------------------------------
# Purpose:
#
# This extension attribute will collect the JSS URL from the target machine via the 'defaults' command
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
#  - Jamf Pro Enrolled Client
# 
#
# ----------------------------------------------------------------------------------------------------------------------------

####################################################
# Get the JSS URL from the com.jamfsoftware.jamf.plist

response=$(defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)
exitCode=$?

# Verify the 'defaults' command returned something
if [ $exitCode -ne 0 ]; then
    echo "<result>/usr/bin/defaults command failed to return jss_url</result>"
    exit 1
fi

#################################
# Check if the response was a URL

if [[ $response == http* ]]; then
    echo "<result>$response</result>"
    exit 0
fi

# Handle any other unexpected output
echo "<result>Unexpected output: $response</result>"
exit 1