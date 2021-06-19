#!/usr/bin/env bash
### ==============================================================================
### Created by Migoliatte
### Automation of multiple WMIC commands allowing supervision of a Windows unit 
### ==============================================================================

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
param=''
ip='192.168.20.166'
fileInformation=$(cat /tmp/test.txt)
if [ "$EUID" -ne 996 ]
        then echo "Please don't run as centreon user"
        exit
fi

function setup_colors() {
        if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
                NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
        else
                NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
        fi
}

function msg() {
        echo >&2 -e "${1-}"
}

function die() {
        local msg=$1
        local code=${2-1} # default exit status 1
        msg "${RED}$msg${NOFORMAT}"
        usage
        exit "$code"
}

function usage() {
        msg "
                Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-l] [-v] -w function -t PropertiesName-ClassName 

                Script description here.

                Available options:

                ${GREEN}-h, --help      Print this help and exit
                -l, --list      Print list of function and exit${NOFORMAT}
                ${ORANGE}-v, --verbose   Print script debug info${NOFORMAT}
                ${CYAN}-w, --wmic      Some param description
                -t, --test      Test some wmic command${NOFORMAT}

                exemple : 
                
                Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-l] [-v] -w UsedPhysicalMemory
                Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-l] [-v] -t FreePhysicalMemory-Win32_OperatingSystem

        "
        listOfFunction
}

function listOfFunction() {
        msg "
                Available WMIC functions:

                ${GREEN}Physical Memory : 
                        FM, fm, freemem      FreePhysicalMemory
                        TM, tm, totalmem     TotalPhysicalMemory
                        UM, um, usedmem      UsedPhysicalMemory${NOFORMAT}
                ${YELLOW}Virtual Memory : 
                        FP, fp, freepaging   FreeSpaceInPagingFiles
                        SP, sp, sizepaging   SizeStoredInPagingFiles
                        UP, up, usedpaging   UsedInPagingFiles${NOFORMAT}

        "
}

function FreePhysicalMemory() {
        warning=3210108
        critical=3300000
        echo "$(wmic -U $fileInformation //$ip "select FreePhysicalMemory from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes );$warning;$critical;"|grep ";"
}

function UsedPhysicalMemory() {
        warning=1506823
        critical=200000
        free=$(echo $(wmic -U $fileInformation //$ip "select FreePhysicalMemory from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes|tail -n 1))
        total=$(echo $(wmic -U $fileInformation //$ip "select TotalPhysicalMemory from Win32_ComputerSystem" --option='client ntlmv2 auth'=Yes|tail -n 1| cut -d "|" -f2))
        used=$(($total/1000 - $free))
}

function TotalPhysicalMemory() {
        warning=0.5
        critical=50
        echo "$(wmic -U $fileInformation //$ip "select TotalPhysicalMemory from Win32_ComputerSystem" --option='client ntlmv2 auth'=Yes);$warning;$critical;"|grep ";"|cut -d "|" -f2 
}

function SizeStoredInPagingFiles(){
        warning=80000
        critical=100000
        echo "$(wmic -U $fileInformation //$ip "select SizeStoredInPagingFiles from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes);$warning;$critical;"|grep ";"    
}


function FreeSpaceInPagingFiles(){
        warning=80000
        critical=100000
        echo "$(wmic -U $fileInformation //$ip "select FreeSpaceInPagingFiles from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes);$warning;$critical;"|grep ";"    

}

function UsedInPagingFiles(){
        warning=80000
        critical=100000
        free=$(echo $(wmic -U $fileInformation //$ip "select FreeSpaceInPagingFiles from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes);$warning;$critical;|grep ";") 
        total=$(echo $(wmic -U $fileInformation //$ip "select SizeStoredInPagingFiles from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes);$warning;$critical;|grep ";")   
        used=$(($total - $free))
        echo "$used"
}

function testWmicCommand(){
        PropertiesName=$( echo $param|cut -d "-" -f1 )
        ClassName=$( echo $param|cut -d "-" -f2 )
        echo "$PropertiesName <> $ClassName" 
        echo $(echo $(wmic -U $fileInformation //$ip "select $PropertiesName from $ClassName" --option='client ntlmv2 auth'=Yes) )  
}

function parse_params() {
        while :; do
                case "${1-}" in
                        -h | --help) usage && exit ;;
                        -l | --list) listOfFunction && exit ;;
                        -v | --verbose) set -x ;;
                        -w | --wmic) param="${2-}" ;;
                        -t | --test) param="${2-}" && testWmicCommand && exit ;;
                        -?*) die "Unknown option: $1" ;;
                        *) break ;;
                esac
                shift
        done
        args=("$@")
        [[ -z "${param-}" ]] && die "Missing required wmic: function name"
        [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"
}

function parse_wmic(){
        case "$param" in
                FM|fm|freemem)  FreePhysicalMemory ;;
                TM|tm|totalmem) TotalPhysicalMemory ;;
                UM|um|usedmem)  UsedPhysicalMemory ;;
                FP|fp|freepaging) FreeSpaceInPagingFiles ;;
                SP|sp|sizepaging) SizeStoredInPagingFiles ;;
                UP|up|usedpaging) UsedInPagingFiles ;;
                *) die "Unknown option: $param" ;;
        esac
}

function main() {
        setup_colors
        parse_params "$@"
        parse_wmic
}

main "$@"
