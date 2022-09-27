#!/bin/sh

# M2 CLEANER

# Script written to run on Cmder in Windows (or other bash command line). 

# Configuration
declare -a NON_DEV_ARTIFACTS=("com.example.archive*" 
                              "com.example.configuration.*" 
                              "com.example.distribution*")
PROJECT_DIR="com/company"
PROJECT_NAME="example"

# Defaults
DEFAULT_M2_PATH="c:/m2"
DEFAULT_AGE=90
DEFAULT_UP_TO_DATE_VERSION="3.9.9"
DEFAULT_REMOVE_NON_DEV_ARTIFACTS="y"

# Script specific
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
CYAN="\e[36m"
BOLD="\e[1m"
NORMAL="\e[0m"
UNDERLINE="\e[4m"

function _confirm {
    echo -e -n "${CYAN}"
    read -e -r -p "${1:-Are you sure?} [yes/no] " response
    echo -e -n "${NORMAL}"
    case $response in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        [nN][oO]|[nN])
            return 1
            ;;
        *)
	    echo 'No answer was recognized. The correct answers are: "yes", "no", "y", n".';
	    _confirm "${1}"
            return $?
            ;;
    esac
}

function _getM2 {
    echo -e -n "${CYAN}"
    read -e -r -p "${1:-Please enter your M2 path} [press Enter for default: '${DEFAULT_M2_PATH}']: " response
    echo -e -n "${NORMAL}"
    if [ $response ]; then
		if [ -d "$response" ] 
		then
			M2_PATH="$response"
		else
			echo "Error: Directory does not exists."
			_getM2
		fi
	else
		M2_PATH=${DEFAULT_M2_PATH}
	fi
}

function _removeNonDevArtifacts() {
	echo "Remove artifacts that are usually not needed by developers (\"com.example.archive*\", \"com.example.configuration.*\", \"com.example.distribution*\")..."
	
	for i in "${NON_DEV_ARTIFACTS[@]}"
	do
		echo "Removing all ${i} ..."
		echo "Removing all directories matching: ${M2_PATH}\${PROJECT_DIR}\\${i}" >> ${REMOVE_LIST_FILE}
		find "${M2_PATH}/${PROJECT_DIR}" -maxdepth 1 -name "${i}" -type d -exec rm -rf {} +
	done
	
	echo "Removing artifacts that are usually not needed by developers: Done!"
}


function _askForRemoveNonDevArtifacts() {
    echo -e -n "${CYAN}"
    read -e -r -p "${1:-Do you want to remove artifacts that are usually not needed by developers (\"com.example.archive*\", \"com.example.configuration.*\", \"com.example.distribution*\")} [y/n, press Enter for default: '${DEFAULT_REMOVE_NON_DEV_ARTIFACTS}']: " response
    echo -e -n "${NORMAL}"
	case $response in
        "")        
		    REMOVE_NON_DEV_ARTIFACTS=${DEFAULT_REMOVE_NON_DEV_ARTIFACTS}
			;;
        [yY][eE][sS]|[yY])
            REMOVE_NON_DEV_ARTIFACTS="y"
            ;;
        [nN][oO]|[nN])
            REMOVE_NON_DEV_ARTIFACTS="n"
            ;;
        *)
	        echo 'No answer was recognized. The correct answers are: "yes", "no", "y", n".';
	        _askForRemoveNonDevArtifacts
            ;;
    esac
}

function _getUpToDateVersion {
    echo -e -n "${CYAN}"
    read -e -r -p "${1:-Please enter the oldest version of artifacts you want to keep} [press Enter for default: '${DEFAULT_UP_TO_DATE_VERSION}']: " response
    echo -e -n "${NORMAL}"
    if [ $response ]; then
		ver_r='^([0-9]+\.){0,3}(\*|[0-9]+)$'
		if [[ $response =~ $ver_r ]]; then
			UP_TO_DATE_VERSION="$response"
		else
			echo "Error: That is not valid version."
			_getUpToDateVersion
		fi
	else
		UP_TO_DATE_VERSION=${DEFAULT_UP_TO_DATE_VERSION}
	fi
	UP_TO_DATE_VERSION_VALUE=$(version $UP_TO_DATE_VERSION)
}

function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

function isUpToDate() {
	if [ $(version $1) -ge $UP_TO_DATE_VERSION_VALUE ]; then
		return 0
	else
		return 1
	fi
}

function _removeOldArtifactsVersions() {
	echo "Searching for project's artifacts..."
	for d in "$M2_PATH/$PROJECT_DIR/$PROJECT_NAME".*/ ; do
		echo -n "Found: $d. Search for the old ones... "
		COUNTER=0
		for ARTIFACT in "$d"*/ ; do
			#ARTIFACT_BASENAME=$(basename $ARTIFACT)
		    ARTIFACT_BASENAME=${ARTIFACT::-1}
			ARTIFACT_BASENAME=${ARTIFACT_BASENAME##*/}
			if ! isUpToDate $ARTIFACT_BASENAME ; then
				echo "Removing: $ARTIFACT"
				echo "Removing: $ARTIFACT" >> ${REMOVE_LIST_FILE}
				rm -rf $ARTIFACT
				COUNTER=$((COUNTER+1)) 
			fi
		done
		echo "done. $COUNTER old artifacts removed."
	done
}


echo -e "${GREEN}==== M2 CLEANER ====${NORMAL}"
echo -e "updated: 2020.09.26 12:11\n"

_getM2	
echo -e -n "${BOLD}"
echo "M2 path = $M2_PATH"
echo -e -n "${NORMAL}"

REMOVE_LIST_FILE=m2_cleaner.log
[ -e "${REMOVE_LIST_FILE}" ] && rm "${REMOVE_LIST_FILE}"
echo "M2_PATH = $M2_PATH" >> ${REMOVE_LIST_FILE}

_getUpToDateVersion
echo -e -n "${BOLD}"
echo "Oldest version of the project to keep = $UP_TO_DATE_VERSION"
echo -e -n "${NORMAL}"

echo "UP_TO_DATE_VERSION = $UP_TO_DATE_VERSION" >> ${REMOVE_LIST_FILE}

_askForRemoveNonDevArtifacts
echo -e -n "${BOLD}"
echo "REMOVE_NON_DEV_ARTIFACTS = $REMOVE_NON_DEV_ARTIFACTS"
echo -e -n "${NORMAL}"

echo "REMOVE_NON_DEV_ARTIFACTS = $REMOVE_NON_DEV_ARTIFACTS" >> ${REMOVE_LIST_FILE}

echo "That were all questions. Start processing. Log file: ${REMOVE_LIST_FILE}"

if [ $REMOVE_NON_DEV_ARTIFACTS = "y" ]; then
	_removeNonDevArtifacts
else
	echo "Skipping fast removal non-dev artifacts."
fi

_removeOldArtifactsVersions

echo "Done! Log file: $REMOVE_LIST_FILE"


