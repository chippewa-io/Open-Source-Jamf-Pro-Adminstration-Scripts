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
# Title: Python Version Extension Attribute
# Date: 8/19/24
# Author: Chris Cohoon, Chippewa Limited Liability Co.
# Version: 1.0
# Target OS: macOS Sonoma
# ----------------------------------------------------------------------------------------------------------------------------
# Version Control:
#
# 1.0 - Initial Release - 8/19/24 - Chris Cohoon, Chippewa Limited Liability Co.
#       
#
#----------------------------------------------------------------------------------------------------------------------------
# Purpose: This script is designed to be used as an Extension Attribute in Jamf Pro to report the version of Python 3
#
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
# - Jamf Pro Server
#
# ----------------------------------------------------------------------------------------------------------------------------
# Function to check and report Python 3 version number
check_python3_version() {
    local python3_path=$1
    
    if [[ -x "$python3_path" ]]; then
        python3_version=$($python3_path --version 2>&1 | awk '{print $2}')
        if [[ $? -eq 0 && -n "$python3_version" ]]; then
            echo "$python3_version"
        else
            echo "Unable to determine Python 3 version"
        fi
    else
        echo "Python 3 is not installed"
    fi
}

# Check for Python 3
python3_result=$(check_python3_version "$(which python3 2>/dev/null)")

# Output the result to Jamf
echo "<result>$python3_result</result>"