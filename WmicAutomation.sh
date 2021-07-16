#!/usr/bin/env bash
### ==============================================================================
### Created by RAMOND Valentin
### Automation of multiple WMIC commands allowing supervision of a Windows unit 
### ==============================================================================

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
param=''
ip='192.168.162.157'
fileInformation=$(cat /tmp/test.txt)

#if [ "$EUID" -ne 996 ]
#        then echo "Please don't run as centreon user"
#        exit
#fi

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
}

function listOfFunction() {
        msg "
                Available WMIC functions:

                ${GREEN}Physical Memory : 
                        FPM, fpm, freephymem   FreePhysicalMemory
                        TPM, tpm, totalphymem  TotalPhysicalMemory
                        UPM, upm, usedphymem   UsedPhysicalMemory${NOFORMAT}
                ${YELLOW}Virtual Memory : 
                        FP,  fp,  freepaging   FreeSpaceInPagingFiles
                        SP,  sp,  sizepaging   SizeStoredInPagingFiles
                        UP,  up,  usedpaging   UsedInPagingFiles
                        FVM, fvm, freevirtmem  FreeVirtualMemory 
                        TVM, tvm, totalvirtmem TotalVirtualMemory 
                        UVM, uvm, usedvirtmem   UsedVirtualMemory ${NOFORMAT}
                ${YELLOW}Total${NOFORMAT} ${GREEN}Memory :${NOFORMAT}
                        ${YELLOW}UTM, utm, usedtotalmem${NOFORMAT} ${GREEN}UsedTotalMemory ${NOFORMAT}

                        
        "
}

function FreePhysicalMemory() {
        echo "----------- FreePhysicalMemory -----------"
        #Appels de fonctions/Wmic
        FreePhysicalMemoryValue=$(echo "$(wmic -U $fileInformation //$ip "select FreePhysicalMemory from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes )")

        #Initialisation de variables
        local warning=3210108
        local critical=3300000

        #Nettoyage chaine/Récuperation Value
        FreePhysicalMemoryValue=$( echo $FreePhysicalMemoryValue|awk -F " " '{print $4}')
        
        #Traitement
        FreePhysicalMemoryValue="$FreePhysicalMemoryValue;$warning;$critical"
        
        #Affichage / retour de la fonction
        echo $FreePhysicalMemoryValue
}

function TotalPhysicalMemory() {
        echo "----------- TotalPhysicalMemory -----------"
        #Appels de fonctions/Wmic
        TotalPhysicalMemoryValue=$(( $(echo "$(wmic -U $fileInformation //$ip "select TotalPhysicalMemory from Win32_ComputerSystem" --option='client ntlmv2 auth'=Yes)"| awk -F "|" '{print $2}'| tail -n 1) / 1000 ))

        #Initialisation de variables
        local warning=4200000
        local critical=4000000

        #Traitement
        TotalPhysicalMemoryValue="$TotalPhysicalMemoryValue;$warning;$critical"

        #Affichage / retour de la fonction
        echo $TotalPhysicalMemoryValue
}

function UsedPhysicalMemory() {
        echo "----------- UsedPhysicalMemory -----------"
        #Appels de fonctions/Wmic
        FreePhysicalMemory FreePhysicalMemoryValue >/tmp/wmicAutomation.output
        TotalPhysicalMemory TotalPhysicalMemoryValue >/tmp/wmicAutomation.output

        #Initialisation de variables
        local warning=1506823
        local critical=200000

        #Nettoyage chaine/Récuperation Value
        FreePhysicalMemoryValue=$(echo $FreePhysicalMemoryValue|awk -F ";" '{print $1}')
        TotalPhysicalMemoryValue=$(echo $TotalPhysicalMemoryValue|awk -F ";" '{print $1}')
        
        #Traitement
        UsedPhysicalMemoryValue=$(($TotalPhysicalMemoryValue - $FreePhysicalMemoryValue))
        UsedPhysicalMemoryValue="$UsedPhysicalMemoryValue;$warning;$critical"

        #Affichage / retour de la fonction
        echo "$UsedPhysicalMemoryValue"
}

function SizeStoredInPagingFiles(){
        echo "----------- SizeStoredInPagingFiles -----------"
        #Appels de fonctions/Wmic
        SizeStoredInPagingFilesValue=$(echo "$(wmic -U $fileInformation //$ip "select SizeStoredInPagingFiles from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes);"|grep ";"    )

        #Initialisation de variables
        local warning=80000
        local critical=100000
        
        #Traitement
        SizeStoredInPagingFilesValue="$SizeStoredInPagingFilesValue;$warning;$critical"

        #Affichage / retour de la fonction
        echo $SizeStoredInPagingFilesValue
}

function FreeSpaceInPagingFiles(){
        echo "----------- FreeSpaceInPagingFiles -----------"
        #Appels de fonctions/Wmic
        FreeSpaceInPagingFilesValue = $(echo "$(wmic -U $fileInformation //$ip "select FreeSpaceInPagingFiles from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes);$warning;$critical;"|grep ";")

        #Initialisation de variables
        local warning=80000
        local critical=100000

        #Traitement
        FreeSpaceInPagingFilesValue="$FreeSpaceInPagingFilesValue;$warning;$critical"

        #Affichage / retour de la fonction
        echo $FreeSpaceInPagingFilesValue
}

function UsedInPagingFiles(){
        echo "----------- UsedInPagingFiles -----------"
        #Appels de fonctions/Wmic
        FreeSpaceInPagingFiles FreeSpaceInPagingFilesValue
        SizeStoredInPagingFiles SizeStoredInPagingFilesValue

        #Initialisation de variables
        local warning=80000
        local critical=100000

        #Nettoyage chaine/Récuperation Value
        FreeSpaceInPagingFiles=$(echo $FreeSpaceInPagingFiles|awk -F ";" '{print $1}')
        SizeStoredInPagingFilesValue=$(echo $SizeStoredInPagingFilesValue|awk -F ";" '{print $1}')
        
        #Traitement
        UsedInPagingFilesValue=$(($SizeStoredInPagingFilesValue - $FreeSpaceInPagingFiles))
        UsedInPagingFilesValue="$UsedInPagingFilesValue;$warning;$critical"

        #Affichage / retour de la fonction
        echo $UsedInPagingFilesValue
}

function FreeVirtualMemory(){
        echo "----------- FreeVirtualMemory -----------"
        #Appels de fonctions/Wmic
        FreeVirtualMemoryValue=$(echo "$(wmic -U $fileInformation //$ip "select FreeVirtualMemory from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes);"|grep ";")

        #Initialisation de variables
        local warning=80000
        local critical=100000

        #Traitement
        FreeVirtualMemoryValue="$FreeVirtualMemoryValue;$warning;$critical"

        #Affichage / retour de la fonction
        echo $FreeVirtualMemoryValue
}

function TotalVirtualMemory(){
        echo "----------- TotalVirtualMemory -----------"
        #Appels de fonctions/Wmic
        TotalVirtualMemoryValue=$(echo "$(wmic -U $fileInformation //$ip "select TotalVirtualMemorySize from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes);"|grep ";")

        #Initialisation de variables
        local warning=80000
        local critical=100000

        #Traitement
        TotalVirtualMemoryValue="$TotalVirtualMemoryValue;$warning;$critical"

        #Affichage / retour de la fonction
        echo $TotalVirtualMemoryValue
}

function UsedVirtualMemory(){
        echo "----------- UsedVirtualMemory -----------"
        #Appels de fonctions/Wmic
        FreeVirtualMemory FreeVirtualMemoryValue   >/tmp/wmicAutomation.output
        TotalVirtualMemory TotalVirtualMemoryValue >/tmp/wmicAutomation.output

        #Initialisation de variables
        local warning=80000
        local critical=100000

        #Nettoyage chaine/Récuperation Value
        FreeVirtualMemoryValue=$(echo $FreeVirtualMemoryValue|awk -F ";" '{print $1}')
        TotalVirtualMemoryValue=$(echo $TotalVirtualMemoryValue|awk -F ";" '{print $1}')

        #Traitement
        UsedVirtualMemoryValue=$(($TotalVirtualMemoryValue - $FreeVirtualMemoryValue))
        UsedVirtualMemoryValue="$UsedVirtualMemoryValue;$warning;$critical"

        #Affichage / retour de la fonction
        echo $UsedVirtualMemoryValue
}

function UsedTotalMemory(){
        echo "----------- UsedTotalMemory -----------"
        #Appels de fonctions/Wmic
        UsedVirtualMemory UsedVirtualMemoryValue     >/tmp/wmicAutomation.output
        TotalVirtualMemory TotalVirtualMemoryValue   >/tmp/wmicAutomation.output
        UsedPhysicalMemory UsedPhysicalMemoryValue   >/tmp/wmicAutomation.output
        TotalPhysicalMemory TotalPhysicalMemoryValue >/tmp/wmicAutomation.output

        #Initialisation de variables
        local warning=30
        local critical=60
 
        #Nettoyage chaine/Récuperation Value
        UsedVirtualMemoryValue=$(echo $UsedVirtualMemoryValue|awk -F ";" '{print $1}')
        TotalVirtualMemoryValue=$(echo $TotalVirtualMemoryValue|awk -F ";" '{print $1}')
        UsedPhysicalMemoryValue=$(echo $UsedPhysicalMemoryValue|awk -F ";" '{print $1}')
        TotalPhysicalMemoryValue=$(echo $TotalPhysicalMemoryValue|awk -F ";" '{print $1}')

        #Traitement
        UsedTotalMemoryValue=$(($UsedPhysicalMemoryValue + $UsedVirtualMemoryValue))
        TotalSizeValue=$(($TotalVirtualMemoryValue+$TotalPhysicalMemoryValue))
        pourcentage=$(($UsedTotalMemoryValue *100 / $TotalSizeValue))
        pourcentage="$pourcentage;$warning;$critical"

        #Affichage / retour de la fonction
        echo $pourcentage
}

function globalCpuCharge(){
        echo "----------- globalCpuCharge -----------"
        #Appels de fonctions/Wmic
        globalCpuChargeValue=$(echo $(wmic -U $fileInformation //$ip "select LoadPercentage from Win32_Processor" --option='client ntlmv2 auth'=Yes))
        
        #Initialisation de variables
        local warning=80000
        local critical=100000

        #Traitement
        globalCpuChargeValue="$globalCpuChargeValue;$warning;$critical"

        #Affichage / retour de la fonction
        echo $globalCpuChargeValue        	

}

#scp .\WmicAutomation.sh root@192.168.162.156:./scp/ ; ssh root@192.168.162.156 ./scp/WmicAutomation.sh 

function testWmicCommand(){
        echo $param        
        PropertiesName=$( echo $param|cut -d "-" -f1 )
        ClassName=$( echo $param|cut -d "-" -f2 )
        echo "$PropertiesName <> $ClassName" 
        echo "$(wmic -U $fileInformation //$ip "select $PropertiesName from $ClassName" --option='client ntlmv2 auth'=Yes)"
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
                FPM|fpm|freephymem)  FreePhysicalMemory ;;
                TPM|tpm|totalphymem) TotalPhysicalMemory ;;
                UPM|upm|usedphymem)  UsedPhysicalMemory ;;
                FP|fp|freepaging) FreeSpaceInPagingFiles ;;
                SP|sp|sizepaging) SizeStoredInPagingFiles ;;
                UP|up|usedpaging) UsedInPagingFiles ;;
                FVM|fvm|freevirtmem)  FreeVirtualMemory ;;
                TVM|tvm|totalvirtmem) TotalVirtualMemory ;;
                UVM|uvm|usedvirtmem)  UsedVirtualMemory ;;
                UTM|utm|usedtotalmem)  UsedTotalMemory ;;
                GCC|gcc|cpucharge) globalCpuCharge ;;
                *) die "Unknown option: $param" ;;
        esac
}

function main() {
        setup_colors
        parse_params "$@"
        parse_wmic
}

main "$@"
