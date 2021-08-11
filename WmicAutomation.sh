#!/usr/bin/env bash
### ==============================================================================
### Created by Migoliatte
### Automation of multiple WMIC commands allowing supervision of a Windows unit 
### ==============================================================================

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
param=''
ip='192.168.211.157'

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

function FreePhysicalMemory() {
        #echo "----------- FreePhysicalMemory -----------"
        #Initialisation de variables
        local warning=3210108
        local critical=3300000
        local valueName="FreePhysicalMemoryValue"

        #Appels de fonctions/Wmic
        FreePhysicalMemoryValue=$(echo "$(wmic -U $fileInformation //$ip "select FreePhysicalMemory from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes )")

        #Nettoyage chaine/Récuperation Value
        FreePhysicalMemoryValue=$( echo $FreePhysicalMemoryValue|awk -F " " '{print $4}')
        local value=$FreePhysicalMemoryValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function TotalPhysicalMemory() {
        #echo "----------- TotalPhysicalMemory -----------"
        #Initialisation de variables
        local warning=4303771
        local critical=4503771
        local valueName="TotalPhysicalMemoryValue"

        #Appels de fonctions/Wmic
        TotalPhysicalMemoryValue=$(echo "$(wmic -U $fileInformation //$ip "select TotalPhysicalMemory from Win32_ComputerSystem" --option='client ntlmv2 auth'=Yes)")
        
        #Traitement
        TotalPhysicalMemoryValue=$(echo $TotalPhysicalMemoryValue|awk -F "|" '{print $3}')
        TotalPhysicalMemoryValue=$(($TotalPhysicalMemoryValue / 1000 ))
        local value=$TotalPhysicalMemoryValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function UsedPhysicalMemory() {
        #echo "----------- UsedPhysicalMemory -----------"
        #Initialisation de variables
        local warning=3000000
        local critical=3500000
        local valueName="UsedPhysicalMemoryValue"
        local fonctionSecondaire=True

        #Appels de fonctions/Wmic
        FreePhysicalMemory FreePhysicalMemoryValue 
        TotalPhysicalMemory TotalPhysicalMemoryValue 
        
        #Traitement
        UsedPhysicalMemoryValue=$(($TotalPhysicalMemoryValue - $FreePhysicalMemoryValue))
        local value=$UsedPhysicalMemoryValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionTertiaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function FreeSpaceInPagingFiles(){
        #echo "----------- FreeSpaceInPagingFiles -----------"
        #Initialisation de variables
        local warning=80000
        local critical=100000
        local valueName="FreeSpaceInPagingFilesValue"

        #Appels de fonctions/Wmic
        FreeSpaceInPagingFilesValue=$(echo "$(wmic -U $fileInformation //$ip "select FreeSpaceInPagingFiles from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes)")

        #Traitement
        FreeSpaceInPagingFilesValue=$(echo $FreeSpaceInPagingFilesValue|awk -F " " '{print $4}')
        local value=$FreeSpaceInPagingFilesValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function SizeStoredInPagingFiles(){
        #echo "----------- SizeStoredInPagingFiles -----------"
        #Initialisation de variables
        local warning=80000
        local critical=100000
        local valueName="SizeStoredInPagingFilesValue"

        #Appels de fonctions/Wmic
        SizeStoredInPagingFilesValue=$(echo "$(wmic -U $fileInformation //$ip "select SizeStoredInPagingFiles from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes)")
        
        #Traitement
        SizeStoredInPagingFilesValue=$(echo $SizeStoredInPagingFilesValue|awk -F " " '{print $4}')
        local value=$SizeStoredInPagingFilesValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function UsedInPagingFiles(){
        #echo "----------- UsedInPagingFiles -----------"
        #Initialisation de variables
        local warning=80000
        local critical=100000
        local valueName="UsedInPagingFilesValue"
        local fonctionSecondaire=True

        #Appels de fonctions/Wmic
        FreeSpaceInPagingFiles FreeSpaceInPagingFilesValue
        SizeStoredInPagingFiles SizeStoredInPagingFilesValue
        
        #Traitement
        UsedInPagingFilesValue=$(($SizeStoredInPagingFilesValue - $FreeSpaceInPagingFilesValue))
        local value=$UsedInPagingFilesValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionTertiaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function FreeVirtualMemory(){
        #echo "----------- FreeVirtualMemory -----------"
        #Initialisation de variables
        local warning=80000
        local critical=100000
        local valueName="FreeVirtualMemoryValue"
        
        #Appels de fonctions/Wmic
        FreeVirtualMemoryValue=$(echo "$(wmic -U $fileInformation //$ip "select FreeVirtualMemory from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes)")

        #Traitement
        FreeVirtualMemoryValue=$(echo $FreeVirtualMemoryValue|awk -F " " '{print $4}')
        local value=$FreeVirtualMemoryValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function TotalVirtualMemory(){
        #echo "----------- TotalVirtualMemory -----------"
        #Initialisation de variables
        local warning=80000
        local critical=100000
        local valueName="TotalVirtualMemoryValue"
        
        #Appels de fonctions/Wmic
        TotalVirtualMemoryValue=$(echo "$(wmic -U $fileInformation //$ip "select TotalVirtualMemorySize from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes)")
       
        #Traitement
        TotalVirtualMemoryValue=$(echo $TotalVirtualMemoryValue|awk -F " " '{print $4}')
        local value=$TotalVirtualMemoryValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function UsedVirtualMemory(){
        #echo "----------- UsedVirtualMemory -----------"
        #Initialisation de variables
        local warning=80000
        local critical=100000
        local valueName="UsedVirtualMemoryValue"
        local fonctionSecondaire=True

        #Appels de fonctions/Wmic
        FreeVirtualMemory FreeVirtualMemoryValue   
        TotalVirtualMemory TotalVirtualMemoryValue 

        #Traitement
        UsedVirtualMemoryValue=$(($TotalVirtualMemoryValue - $FreeVirtualMemoryValue))
        local value=$UsedVirtualMemoryValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionTertiaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function UsedTotalMemory(){
        #echo "----------- UsedTotalMemory -----------"
        #Initialisation de variables
        local warning=30
        local critical=60
        local valueName="UsedTotalMemoryValue"
        local fonctionSecondaire=True
        local fonctionTertiaire=True

        #Appels de fonctions/Wmic
        UsedVirtualMemory UsedVirtualMemoryValue     
        TotalVirtualMemory TotalVirtualMemoryValue   
        UsedPhysicalMemory UsedPhysicalMemoryValue   
        TotalPhysicalMemory TotalPhysicalMemoryValue 

        #Traitement
        UsedTotalMemoryValue=$(($UsedPhysicalMemoryValue + $UsedVirtualMemoryValue))
        TotalSizeValue=$(($TotalVirtualMemoryValue+$TotalPhysicalMemoryValue))
        pourcentage=$(($UsedTotalMemoryValue *100 / $TotalSizeValue))
        local value=$pourcentage

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionQuaternaires ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value}% $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value}% $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value}% $valueName <missing information>"
                        exit 0
                fi
        fi
}

function globalCpuCharge(){
        #echo "----------- globalCpuCharge -----------"
        #Initialisation de variables
        local warning=75
        local critical=90
        local valueName="globalCpuChargeValue"

        #Appels de fonctions/Wmic
        globalCpuChargeValue=$(echo $(wmic -U $fileInformation //$ip "select LoadPercentage from Win32_Processor" --option='client ntlmv2 auth'=Yes))
        
        #Nettoyage chaine/Récuperation Value
        globalCpuChargeValue=$(echo $globalCpuChargeValue|awk -F "|" '{print $3}')
        local value=$globalCpuChargeValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value}% of cpu  used"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value}% of cpu  used"
                        exit 1
                else
                        echo "OK: ${value}% of cpu  used"
                        exit 0
                fi
        fi
}

function localDateTime(){
        ##echo "----------- localDateTime -----------"
        #Initialisation de variables
        local warning=80000
        local critical=100000
        local valueName="localDateTimeValue"

        #Appels de fonctions/Wmic
        localDateTimeValue=$(echo $(wmic -U $fileInformation //$ip "select LocalDateTime from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes))


        #Traitement
        localDateTimeValue=$(echo $localDateTimeValue|awk -F " " '{print $4}'|awk -F "." '{print $1}')
        local value=$localDateTimeValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi

}

function lastBootTime(){
        ##echo "----------- lastBootTime -----------"
        #Initialisation de variables
        local warning=80000
        local critical=100000
        local year month day hour minute seconde
        local valueName="lastBootTimeValue"

        #Appels de fonctions/Wmic
        lastBootTimeValue=$(echo $(wmic -U $fileInformation //$ip "select LastBootUpTime from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes))

        #Traitement
        lastBootTimeValue=$(echo $lastBootTimeValue|awk -F " " '{print $4}'|awk -F "." '{print $1}')
        year=10#$(echo "${lastBootTimeValue:0:4}")
        month=10#$(echo "${lastBootTimeValue:4:2}")
        day=10#$(echo "${lastBootTimeValue:6:2}")
        hour=10#$(echo "${lastBootTimeValue:8:2}")
        minute=10#$(echo "${lastBootTimeValue:10:2}")
        seconde=10#$(echo "${lastBootTimeValue:12:2}")
        lastBootTimeValue=$(( ($year*31536000) + ($month*2628002) + ($day*86400) + ($hour*3600) + ($minute*60) + ($seconde*1) ))
        local value=$lastBootTimeValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function upTime(){
        ##echo "----------- uptime -----------"
        #Initialisation de variables
        local warning=75
        local critical=90
        local year month day hour minute seconde
        local valueName="upTimeValue"
        local fonctionSecondaire=True

        #Appels de fonctions/Wmic
        localDateTime localDateTimeValue  
        lastBootTime lastBootTimeValue    

        #Nettoyage chaine/Récuperation Value
        localDateTimeValue=$(echo $localDateTimeValue|awk -F ";" '{print $1}')
        lastBootTimeValue=$(echo $lastBootTimeValue|awk -F ";" '{print $1}')

        #Traitement
        year=10#$(echo "${localDateTimeValue:0:4}")
        month=10#$(echo "${localDateTimeValue:4:2}")
        day=10#$(echo "${localDateTimeValue:6:2}")
        hour=10#$(echo "${localDateTimeValue:8:2}")
        minute=10#$(echo "${localDateTimeValue:10:2}")
        seconde=10#$(echo "${localDateTimeValue:12:2}")
        localDateTimeValue=$(( ($year*31536000) + ($month*2628002) + ($day*86400) + ($hour*3600) + ($minute*60) + ($seconde*1) ))

        upTimeValue=$(($localDateTimeValue - $lastBootTimeValue))
        local value=$upTimeValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionTertiaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi  
}

function localDateTimeFormat(){
        ##echo "----------- localDateTimeFormat -----------"
        #Initialisation de variables
        local warning=75
        local critical=90
        local year month day hour minute seconde
        local valueName="localDateTimeFormatValue"
        
        #Appels de fonctions/Wmic
        localDateTimeFormatValue=$(echo $(wmic -U $fileInformation //$ip "select * from Win32_LocalTime" --option='client ntlmv2 auth'=Yes))

        #Nettoyage chaine/Récuperation Value
        localDateTimeFormatValue=$(echo $localDateTimeFormatValue|awk -F " " '{print $4}')
        year=$(echo $localDateTimeFormatValue|awk -F "|" '{print $10}')
        month=$(echo $localDateTimeFormatValue|awk -F "|" '{print $6}')
        day=$(echo $localDateTimeFormatValue|awk -F "|" '{print $1}')
        hour=$(echo $localDateTimeFormatValue|awk -F "|" '{print $3}')
        minute=$(echo $localDateTimeFormatValue|awk -F "|" '{print $5}')
        seconde=$(echo $localDateTimeFormatValue|awk -F "|" '{print $8}')

        #Traitement
        localDateTimeFormat=$(echo "$day/$month/$year/$hour/$minute/$seconde")
        local value=$localDateTimeFormat

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                #if [[ $value -gt $critical ]]; then
                #        echo "CRITICAL: ${value} $valueName <missing information>"
                #        exit 2
                #elif [ $value -gt $warning ]; then
                #        echo "WARNING: ${value} $valueName <missing information>"
                #        exit 1
                #else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                #fi
        fi         
}

function statusDiskDrive(){
        ##echo "----------- statusDiskDrive -----------"
        #Initialisation de variables
        local warning=80000
        local critical=100000
        local valueName="statusDiskDriveValue"
        
        #Appels de fonctions/Wmic
        statusDiskDriveValue=$(echo $(wmic -U $fileInformation //$ip "select status from CIM_DiskDrive" --option='client ntlmv2 auth'=Yes))

        #Traitement
        statusDiskDriveValue=$(echo $statusDiskDriveValue|awk -F "|" '{print $3}')
        local value=$statusDiskDriveValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                #if [[ $value -gt $critical ]]; then
                #        echo "CRITICAL: ${value} $valueName <missing information>"
                #        exit 2
                #elif [ $value -gt $warning ]; then
                #        echo "WARNING: ${value} $valueName <missing information>"
                #        exit 1
                #else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                #fi
        fi
}

function statusPowerSupply(){ # ne retourne rien meme sur l'host ( Get-WmiObject CIM_Powersupply *  )
        ##echo "----------- statusPowerSupply -----------"
        #Initialisation de variables
        local warning=80000
        local critical=100000
        local valueName="statusPowerSupplyValue"

        #Appels de fonctions/Wmic
        statusPowerSupplyValue=$(echo $(wmic -U $fileInformation //$ip "select status from CIM_PowerSupply" --option='client ntlmv2 auth'=Yes))

        #Traitement
        local value=$statusPowerSupplyValue

        #Affichage / retour de la fonction
        fonctionSecondaire=True
        echo "La requette"
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function pingStatus(){
        ##echo "----------- pingStatus -----------"
        #Initialisation de variables
        local warning=80000
        local critical=100000
        local address="Address = '8.8.8.8'"
        local valueName="pingStatusValue"

        #Appels de fonctions/Wmic
        pingStatusValue=$(echo $(wmic -U $fileInformation //$ip "select StatusCode from Win32_PingStatus where $address " --option='client ntlmv2 auth'=Yes ))

        #Traitement
        pingStatusValue=$(echo $pingStatusValue| awk -F " " '{print $4}')
        pingStatusValue=$(echo $pingStatusValue| awk -F "|" '{print $8}')
        local value=$pingStatusValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function pingStatusAverage(){
        ##echo "----------- pingStatusAverage -----------"

        #Initialisation de variables
        local warning=80000
        local critical=100000
        local result=0
        local address="Address = '8.8.8.8'"
        local valueName="pingStatusAverageValue"

        #Appels de fonctions/Wmic
        for (( i=0; i<10; i++ ))
        do
                pingStatusAverageValue=$(echo $(wmic -U $fileInformation //$ip "select ResponseTime from Win32_PingStatus where $address  " --option='client ntlmv2 auth'=Yes ))
                pingStatusAverageValue=$(echo $pingStatusAverageValue| awk -F " " '{print $4}')
                pingStatusAverageValue=$(echo $pingStatusAverageValue| awk -F "|" '{print $6}')
                bonjour[$i]=$pingStatusAverageValue
                result=$(( result + ${bonjour[$i]} ))
        done

        #Traitement
        for (( i=0; i<10; i++ ))
        do
                result=$(( result + ${bonjour[$i]} ))
        done
        result=$(( result / 10 ))
        local value=$result

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function networkadaptater(){ # je ne sais pas quoi afficher ici
        ##echo "----------- networkadaptater -----------"
        #Initialisation de variables
        local warning=80000
        local critical=100000
        local valueName="FreePhysicalMemoryValue"

        #Appels de fonctions/Wmic
        networkadaptaterValue=$(echo $(wmic -U $fileInformation //$ip "select NetConnectionStatus from Win32_NetworkAdapter" --option='client ntlmv2 auth'=Yes))

        #Traitement
        networkadaptaterValue=$(echo $networkadaptaterValue)
        #CLASS: Win32_NetworkAdapter DeviceID|NetConnectionStatus 0|0 1|0 2|0 3|2
        #Print "ok" car un = 2 ? print quoi ?
        #Disconnected (0)
        #Connecting (1)
        #Connected (2)

        local value=$FreePhysicalMemoryValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function inputOccupRate(){
        ##echo "----------- inputOccupRate -----------"
        #Initialisation de variables
        local warning=80000
        local critical=100000
        local valueName="inputOccupRateValue"

        #Appels de fonctions/Wmic
        BytesReceivedPersecValue=$(echo $(wmic -U $fileInformation //$ip "select BytesReceivedPersec from Win32_PerfFormattedData_Tcpip_NetworkInterface" --option='client ntlmv2 auth'=Yes))
        CurrentBandwidthValue=$(echo $(wmic -U $fileInformation //$ip "select CurrentBandwidth from Win32_PerfFormattedData_Tcpip_NetworkInterface" --option='client ntlmv2 auth'=Yes))


        #Traitement
        BytesReceivedPersecValue=$(echo $BytesReceivedPersecValue|awk -F " " '{print $4}'|awk -F "|" '{print $1}')
        CurrentBandwidthValue=$(echo $CurrentBandwidthValue|awk -F " " '{print $4}'|awk -F "|" '{print $1}')
        inputOccupRateValue=$(( ($BytesReceivedPersecValue * 8) / ($CurrentBandwidthValue) ))
        local value=$inputOccupRateValue

        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}

function outputOccupRate(){
        #echo "----------- outputOccupRate -----------"
        #Initialisation de variables
        local warning=80000
        local critical=100000
        local valueName="outputOccupRateValue"

        #Appels de fonctions/Wmic
        BytesSentPersecValue=$(echo $(wmic -U $fileInformation //$ip "select BytesSentPersec from Win32_PerfFormattedData_Tcpip_NetworkInterface" --option='client ntlmv2 auth'=Yes))
        CurrentBandwidthValue=$(echo $(wmic -U $fileInformation //$ip "select CurrentBandwidth from Win32_PerfFormattedData_Tcpip_NetworkInterface" --option='client ntlmv2 auth'=Yes))


        #Traitement
        BytesSentPersecValue=$(echo $BytesSentPersecValue|awk -F " " '{print $4}'|awk -F "|" '{print $1}')
        CurrentBandwidthValue=$(echo $CurrentBandwidthValue|awk -F " " '{print $4}'|awk -F "|" '{print $1}')
        outputOccupRateValue=$(( ($BytesSentPersecValue * 8) / ($CurrentBandwidthValue) ))
        local value=$outputOccupRateValue

        echo $BytesSentPersecValue
        echo $CurrentBandwidthValue
        echo $outputOccupRateValue
        #Affichage / retour de la fonction
        if [[ ! -n $fonctionSecondaire ]]; then
                if [[ $value -gt $critical ]]; then
                        echo "CRITICAL: ${value} $valueName <missing information>"
                        exit 2
                elif [ $value -gt $warning ]; then
                        echo "WARNING: ${value} $valueName <missing information>"
                        exit 1
                else
                        echo "OK: ${value} $valueName <missing information>"
                        exit 0
                fi
        fi
}


#scp .\WmicAutomation.sh root@192.168.162.156:./scp/ ; ssh root@192.168.162.156 ./scp/WmicAutomation.sh 

function testWmicCommand(){
        PropertiesName=$( echo $param|cut -d "-" -f1 )
        ClassName=$( echo $param|cut -d "-" -f2 )
        #echo "------------------------------------------ Lancement de la commande -------------------------------------"
        echo "wmic -U $fileInformation //$ip "select $PropertiesName from $ClassName" --option='client ntlmv2 auth'=Yes" 
        #echo "------------------------------------------ Lancement de la commande -------------------------------------"
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
                FPM|fpm|freephymem   )   FreePhysicalMemory      ;;
                TPM|tpm|totalphymem  )   TotalPhysicalMemory     ;;
                UPM|upm|usedphymem   )   UsedPhysicalMemory      ;;
                FPF|fpf|freepaging   )   FreeSpaceInPagingFiles  ;;
                SPF|spf|sizepaging   )   SizeStoredInPagingFiles ;;
                UPF|upf|usedpaging   )   UsedInPagingFiles       ;;
                FVM|fvm|freevirtmem  )   FreeVirtualMemory       ;;
                TVM|tvm|totvirtmem   )   TotalVirtualMemory       ;;
                UVM|uvm|usedvirtmem  )   UsedVirtualMemory         ;;
                UTM|utm|usedtotalmem )   UsedTotalMemory         ;;
                GCC|gcc|cpucharge    )   globalCpuCharge         ;;
                LDT|ldt|localtime    )   localDateTime           ;;
                LBT|lbt|lastboot     )   lastBootTime           ;;
                UPT|upt|uptime       )   upTime                  ;;
                LDF|ldf|localformat  )   localDateTimeFormat     ;;
                SDD|sdd|statusdisk   )   statusDiskDrive         ;;
                SPS|sps|statuspower  )   statusPowerSupply       ;;
                PGS|pgs|ping         )   pingStatus              ;;
                PSA|psa|pinga        )   pingStatusAverage       ;;
                NKA|nka|netada       )   networkadaptater        ;;
                IOR|ior|ioccupr      )   inputOccupRate          ;;
                OOR|oor|ooccupr      )   outputOccupRate         ;;
                *) die "Unknown option: $param"                  ;;
        esac
}

function listOfFunction() {
        msg "
Available WMIC functions:
        Standard system metrics
                [${GREEN}Physical${NOFORMAT} and ${YELLOW}virtual${NOFORMAT} memory occupancy rate]
                        ${GREEN}Amount of RAM in the system : 
                                TPM, tpm, totalphymem   TotalPhysicalMemory
                        Amount of RAM used  : 
                                UPM, upm, usedphymem    UsedPhysicalMemory${NOFORMAT}
                        ${YELLOW}Quantity of swap file installed on the system : 
                                SPF,  spf,  sizepaging    SizeStoredInPagingFiles
                        Quantity of swap file used : 
                                UPF,  upf,  usedpaging    UsedInPagingFiles${NOFORMAT}
                        Memory occupation (with ${YELLOW}RAM${NOFORMAT} & ${GREEN}SWAP${NOFORMAT})
                                ${YELLOW}UTM, utm, usedtotalmem${NOFORMAT}  ${GREEN}UsedTotalMemory ${NOFORMAT}
                [${ORANGE}Load average${NOFORMAT}]
                        ${ORANGE}GCC, gcc, cpucharge  globalCpuCharge${NOFORMAT}
                [${CYAN}Time since last system reboot${NOFORMAT}]
                        ${CYAN}UPT, upt, uptime     upTime${NOFORMAT}
                [${GREEN}Machine NTP Synchronization Status]
                        Current system time :
                                LDT, ldt, localtime          localDateTime
                        Current system time (JJ/MM/YYYY/hh/mm/ss) format :
                                LDF, ldf, localformat          localDateTimeFormat ${NOFORMAT}

        Monitoring of the physical components of the machine 
                [Status of the materials making up the equipment]
                        Fan status :
                                FT, ft, fantach FanTachometer #fonctionne pas
                        Disk status :
                                STD, std, statusdisk statusDiskDrive 
                        Power Supply status :
                                SPS, sps, statuspower statusPowerSupply

        Newtork metrics
                [Response time to ping]
                        Response to an ICMP echo request (ping)
                                PS, ps, ping pingStatus
                        Average RTT over 10 consecutive requests in milliseconds  
                                PSA, psa, pinga pingStatusAverage
                [Network Card status]
                        Presence of a functional link
                                NA, na, netada networkadaptater
                        Input bandwidth occupancy rate
                                IOR, ior, ioccupr inputOccupRate
                        output occupancy rate  
                                OOR, oor, ooccupr outputOccupRate
        "
}


function main() {
        setup_colors
        parse_params "$@"
        parse_wmic
}

main "$@"
