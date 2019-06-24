#!/bin/bash

# Authenticates credentials against Central and returns the cookie jar file name. USERNAME must
# be set before calling this function. The user will be prompted for the password by curl.
#   USERNAME="foo"
#   COOKIE_JAR=$(startSession)
startSession() {
    # Authentication to XNAT and store cookies in cookie jar file
    local STATUS=4
    while [ ${STATUS} != 0 ]; do
        http --auth="${USERNAME}" --session="${USERNAME}" --verify=no --check-status --output=jsession.txt "https://central.xnat.org/data/JSESSION"
        STATUS=${?}
        [[ ${STATUS} != 0 ]] && {
            echo "Failed to authenticate the user \"${USERNAME}\". Do you want to try again?"
            while true; do
                read -p "Press \"y\" to enter your password again or \"n\" to terminate this script: " yn
                case ${yn} in
                    [Yy]* ) break;;
                    [Nn]* ) exit -1; break;;
                    * ) echo "Please enter yes (y) or no (n).";;
                esac
            done
        }
    done
    rm -f jsession.txt
}

# Downloads a resource from a URL and stores the results to the specified path. The first parameter
# should be the destination path and the second parameter should be the URL.
download() {
    local OUTPUT_PREFIX=${1}
    local URL=${2}
    local FORMAT=${3}
    http --verbose --session="${USERNAME}" --verify=no --download --output=${OUTPUT_PREFIX}.${FORMAT} GET ${URL} format==${FORMAT}
}

# Ends the user session.
endSession() {
    # Delete the JSESSION token - "log out"
    http --session="${USERNAME}" --verify=no --output=jsession.txt DELETE "https://central.xnat.org/data/JSESSION" 
    rm -f jsession.txt
}

