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
# Title: Automated_Device_Enrollment_ConfigurationURL.EA.sh
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
# This extension attribute will collect the Automated Device Enrollment ConfigurationURL from the target machine via use of 
# the macOS native binary 'profiles'
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
# 
#
# ----------------------------------------------------------------------------------------------------------------------------

######################################################
# Get the Automated Device Enrollment ConfigurationURL

response=$(profiles show -type enrollment)
exitCode=$?

# Check if the response contains the DEP error message
if echo "$response" | grep -q "Error fetching Device Enrollment configuration: Client is not DEP enabled."; then
    echo "<result>Client is not DEP enabled</result>"
    exit 0
fi

# Verify the 'profiles' binary returned something
if [ $exitCode -ne 0 ]; then
    echo "<result>/usr/bin/profiles binary failed to return ConfigurationURL</result>"
    exit 1
fi

# Extract the ConfigurationURL
URL=$(echo "$response" | grep "ConfigurationURL" | sed -E 's/.*ConfigurationURL = "(.*)";/\1/')

#################################
# Check if the response was a URL

if [[ $URL == http* ]]; then
    echo "<result>$URL</result>"
    exit 0
fi

# Handle any other unexpected output
echo "<result>Unexpected output: $URL</result>"
exit 1