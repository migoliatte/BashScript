#!/usr/bin/env bash
### ==============================================================================
### Created by Migoliatte
### Automation of multiple WMIC commands allowing supervision of a Windows unit 
### ==============================================================================

### Global variable part
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
param=''
ip='192.168.211.157'
passwordFile=$(cat /tmp/test.txt) #exemple : user%password
### Global variable part

### Testing part
function testWmicCommand(){        # Allow to test wmic command 
        PropertiesName=$( echo $param|cut -d "-" -f1 )
        ClassName=$( echo $param|cut -d "-" -f2 )
        echo "wmic -U $passwordFile //$ip "select $PropertiesName from $ClassName" --option='client ntlmv2 auth'=Yes" 
        echo "$(wmic -U $passwordFile //$ip "select $PropertiesName from $ClassName" --option='client ntlmv2 auth'=Yes)"
}
### Testing part

### Network part
# Ping part
function pingStatus(){             # Response to an ICMP echo request (ping)
        #Initialization of variables
        local warning=80000
        local critical=100000
        local address="Address = '8.8.8.8'"
        local valueName="pingStatusValue"

        #Function calls / Wmic
        pingStatusValue=$(echo $(wmic -U $passwordFile //$ip "select StatusCode from Win32_PingStatus where $address " --option='client ntlmv2 auth'=Yes ))

        #Treatment 
        pingStatusValue=$(echo $pingStatusValue| awk -F " " '{print $4}')
        pingStatusValue=$(echo $pingStatusValue| awk -F "|" '{print $8}')
        local value=$pingStatusValue

        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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

function pingStatusAverage(){      # Average RTT over 10 consecutive requests in milliseconds 
        #Initialization of variables
        local warning=80000
        local critical=100000
        local result=0
        local address="Address = '8.8.8.8'"
        local valueName="pingStatusAverageValue"

        #Function calls / Wmic
        for (( i=0; i<10; i++ ))
        do
                pingStatusAverageValue=$(echo $(wmic -U $passwordFile //$ip "select ResponseTime from Win32_PingStatus where $address  " --option='client ntlmv2 auth'=Yes ))
                pingStatusAverageValue=$(echo $pingStatusAverageValue| awk -F " " '{print $4}')
                pingStatusAverageValue=$(echo $pingStatusAverageValue| awk -F "|" '{print $6}')
                bonjour[$i]=$pingStatusAverageValue
                result=$(( result + ${bonjour[$i]} ))
        done

        #Treatment 
        for (( i=0; i<10; i++ ))
        do
                result=$(( result + ${bonjour[$i]} ))
        done
        result=$(( result / 10 ))
        local value=$result

        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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

# Bandidth part
function networkadaptater(){       # Presence of a functional link
        #Initialization of variables
        local warning=80000
        local critical=100000
        local valueName="FreePhysicalMemoryValue"

        #Function calls / Wmic
        networkadaptaterValue=$(echo $(wmic -U $passwordFile //$ip "select NetConnectionStatus from Win32_NetworkAdapter" --option='client ntlmv2 auth'=Yes))

        #Treatment 
        networkadaptaterValue=$(echo $networkadaptaterValue)

        #CLASS: Win32_NetworkAdapter DeviceID|NetConnectionStatus 0|0 1|0 2|0 3|2
        #Disconnected (0)
        #Connecting (1)
        #Connected (2)

        local value=$FreePhysicalMemoryValue

        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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

function inputOccupRate(){         # Input bandwidth occupancy rate
        #Initialization of variables
        local warning=80000
        local critical=100000
        local valueName="inputOccupRateValue"

        #Function calls / Wmic
        BytesReceivedPersecValue=$(echo $(wmic -U $passwordFile //$ip "select BytesReceivedPersec from Win32_PerfFormattedData_Tcpip_NetworkInterface" --option='client ntlmv2 auth'=Yes))
        CurrentBandwidthValue=$(echo $(wmic -U $passwordFile //$ip "select CurrentBandwidth from Win32_PerfFormattedData_Tcpip_NetworkInterface" --option='client ntlmv2 auth'=Yes))


        #Treatment 
        BytesReceivedPersecValue=$(echo $BytesReceivedPersecValue|awk -F " " '{print $4}'|awk -F "|" '{print $1}')
        CurrentBandwidthValue=$(echo $CurrentBandwidthValue|awk -F " " '{print $4}'|awk -F "|" '{print $1}')
        inputOccupRateValue=$(( ($BytesReceivedPersecValue * 8) / ($CurrentBandwidthValue) ))
        local value=$inputOccupRateValue

        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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

function outputOccupRate(){        # Output occupancy rate
        #Initialization of variables
        local warning=80000
        local critical=100000
        local valueName="outputOccupRateValue"

        #Function calls / Wmic
        BytesSentPersecValue=$(echo $(wmic -U $passwordFile //$ip "select BytesSentPersec from Win32_PerfFormattedData_Tcpip_NetworkInterface" --option='client ntlmv2 auth'=Yes))
        CurrentBandwidthValue=$(echo $(wmic -U $passwordFile //$ip "select CurrentBandwidth from Win32_PerfFormattedData_Tcpip_NetworkInterface" --option='client ntlmv2 auth'=Yes))


        #Treatment 
        BytesSentPersecValue=$(echo $BytesSentPersecValue|awk -F " " '{print $4}'|awk -F "|" '{print $1}')
        CurrentBandwidthValue=$(echo $CurrentBandwidthValue|awk -F " " '{print $4}'|awk -F "|" '{print $1}')
        outputOccupRateValue=$(( ($BytesSentPersecValue * 8) / ($CurrentBandwidthValue) ))
        local value=$outputOccupRateValue

        echo $BytesSentPersecValue
        echo $CurrentBandwidthValue
        echo $outputOccupRateValue
        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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
### Network part

### Equipment part
# Power supply part
function statusPowerSupply(){      # status of power supply
        #Initialization of variables
        local warning=80000
        local critical=100000
        local valueName="statusPowerSupplyValue"

        #Function calls / Wmic
        statusPowerSupplyValue=$(echo $(wmic -U $passwordFile //$ip "select status from CIM_PowerSupply" --option='client ntlmv2 auth'=Yes))

        #Treatment 
        local value=$statusPowerSupplyValue

        #Function display / return
        SecondaryFunction=True
        echo "La requette"
        if [[ ! -n $SecondaryFunction ]]; then
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

# Disk part
function statusDiskDrive(){        # Disk status
        #Initialization of variables
        local warning=80000
        local critical=100000
        local valueName="statusDiskDriveValue"
        
        #Function calls / Wmic
        statusDiskDriveValue=$(echo $(wmic -U $passwordFile //$ip "select status from CIM_DiskDrive" --option='client ntlmv2 auth'=Yes))

        #Treatment 
        statusDiskDriveValue=$(echo $statusDiskDriveValue|awk -F "|" '{print $3}')
        local value=$statusDiskDriveValue

        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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
### Equipment part


### Time part
function localDateTime(){          # The local date in the system (YYYYMMDDhhmmss)
        #Initialization of variables
        local warning=80000
        local critical=100000
        local valueName="localDateTimeValue"

        #Function calls / Wmic
        localDateTimeValue=$(echo $(wmic -U $passwordFile //$ip "select LocalDateTime from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes))


        #Treatment 
        localDateTimeValue=$(echo $localDateTimeValue|awk -F " " '{print $4}'|awk -F "." '{print $1}')
        local value=$localDateTimeValue
        
        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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

function lastBootTime(){           # Display in second the date of the last boot
        #Initialization of variables
        local warning=80000
        local critical=100000
        local year month day hour minute seconde
        local valueName="lastBootTimeValue"

        #Function calls / Wmic
        lastBootTimeValue=$(echo $(wmic -U $passwordFile //$ip "select LastBootUpTime from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes))

        #Treatment 
        lastBootTimeValue=$(echo $lastBootTimeValue|awk -F " " '{print $4}'|awk -F "." '{print $1}')
        year=10#$(echo "${lastBootTimeValue:0:4}")
        month=10#$(echo "${lastBootTimeValue:4:2}")
        day=10#$(echo "${lastBootTimeValue:6:2}")
        hour=10#$(echo "${lastBootTimeValue:8:2}")
        minute=10#$(echo "${lastBootTimeValue:10:2}")
        seconde=10#$(echo "${lastBootTimeValue:12:2}")
        lastBootTimeValue=$(( ($year*31536000) + ($month*2628002) + ($day*86400) + ($hour*3600) + ($minute*60) + ($seconde*1) ))
        local value=$lastBootTimeValue

        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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

function upTime(){                 # Time since the last system restart (uptime) in seconds  
        #Initialization of variables
        local warning=75
        local critical=90
        local year month day hour minute seconde
        local valueName="upTimeValue"
        local SecondaryFunction=True

        #Function calls / Wmic
        localDateTime localDateTimeValue  
        lastBootTime lastBootTimeValue    

        #Chain cleaning
        localDateTimeValue=$(echo $localDateTimeValue|awk -F ";" '{print $1}')
        lastBootTimeValue=$(echo $lastBootTimeValue|awk -F ";" '{print $1}')

        #Treatment 
        year=10#$(echo "${localDateTimeValue:0:4}")
        month=10#$(echo "${localDateTimeValue:4:2}")
        day=10#$(echo "${localDateTimeValue:6:2}")
        hour=10#$(echo "${localDateTimeValue:8:2}")
        minute=10#$(echo "${localDateTimeValue:10:2}")
        seconde=10#$(echo "${localDateTimeValue:12:2}")
        localDateTimeValue=$(( ($year*31536000) + ($month*2628002) + ($day*86400) + ($hour*3600) + ($minute*60) + ($seconde*1) ))

        upTimeValue=$(($localDateTimeValue - $lastBootTimeValue))
        local value=$upTimeValue

        #Function display / return
        if [[ ! -n $TertiaryFunction ]]; then
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

function localDateTimeFormat(){    # The local date in the system (JJ/MM/YYYY/hh/mm/ss)
        #Initialization of variables
        local warning=75
        local critical=90
        local year month day hour minute seconde
        local valueName="localDateTimeFormatValue"
        
        #Function calls / Wmic
        localDateTimeFormatValue=$(echo $(wmic -U $passwordFile //$ip "select * from Win32_LocalTime" --option='client ntlmv2 auth'=Yes))

        #Chain cleaning
        localDateTimeFormatValue=$(echo $localDateTimeFormatValue|awk -F " " '{print $4}')
        year=$(echo $localDateTimeFormatValue|awk -F "|" '{print $10}')
        month=$(echo $localDateTimeFormatValue|awk -F "|" '{print $6}')
        day=$(echo $localDateTimeFormatValue|awk -F "|" '{print $1}')
        hour=$(echo $localDateTimeFormatValue|awk -F "|" '{print $3}')
        minute=$(echo $localDateTimeFormatValue|awk -F "|" '{print $5}')
        seconde=$(echo $localDateTimeFormatValue|awk -F "|" '{print $8}')

        #Treatment 
        localDateTimeFormat=$(echo "$day/$month/$year/$hour/$minute/$seconde")
        local value=$localDateTimeFormat

        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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
### Time part


### CPU part
function globalCpuCharge(){        # Percentage of CPU load
        #Initialization of variables
        local warning=75
        local critical=90
        local valueName="globalCpuChargeValue"

        #Function calls / Wmic
        globalCpuChargeValue=$(echo $(wmic -U $passwordFile //$ip "select LoadPercentage from Win32_Processor" --option='client ntlmv2 auth'=Yes))
        
        #Chain cleaning
        globalCpuChargeValue=$(echo $globalCpuChargeValue|awk -F "|" '{print $3}')
        local value=$globalCpuChargeValue

        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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
### CPU part


### Memory part
function UsedTotalMemory(){        # Memory occupation ( With RAM & Swap )
        #Initialization of variables
        local warning=30
        local critical=60
        local valueName="UsedTotalMemoryValue"
        local SecondaryFunction=True
        local TertiaryFunction=True

        #Function calls / Wmic
        UsedVirtualMemory UsedVirtualMemoryValue     
        TotalVirtualMemory TotalVirtualMemoryValue   
        UsedPhysicalMemory UsedPhysicalMemoryValue   
        TotalPhysicalMemory TotalPhysicalMemoryValue 

        #Treatment 
        UsedTotalMemoryValue=$(($UsedPhysicalMemoryValue + $UsedVirtualMemoryValue))
        TotalSizeValue=$(($TotalVirtualMemoryValue+$TotalPhysicalMemoryValue))
        pourcentage=$(($UsedTotalMemoryValue *100 / $TotalSizeValue))
        local value=$pourcentage

        #Function display / return
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

# Virtual memory part
function FreeVirtualMemory(){       # Amount of virtual RAM used in the system 
        #Initialization of variables
        local warning=80000
        local critical=100000
        local valueName="FreeVirtualMemoryValue"
        
        #Function calls / Wmic
        FreeVirtualMemoryValue=$(echo "$(wmic -U $passwordFile //$ip "select FreeVirtualMemory from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes)")

        #Treatment 
        FreeVirtualMemoryValue=$(echo $FreeVirtualMemoryValue|awk -F " " '{print $4}')
        local value=$FreeVirtualMemoryValue

        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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

function TotalVirtualMemory(){      # Amount of virtual RAM installed in the system
        #Initialization of variables
        local warning=80000
        local critical=100000
        local valueName="TotalVirtualMemoryValue"
        
        #Function calls / Wmic
        TotalVirtualMemoryValue=$(echo "$(wmic -U $passwordFile //$ip "select TotalVirtualMemorySize from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes)")
       
        #Treatment 
        TotalVirtualMemoryValue=$(echo $TotalVirtualMemoryValue|awk -F " " '{print $4}')
        local value=$TotalVirtualMemoryValue

        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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

function UsedVirtualMemory(){       # Amount of virtual RAM used in the system 
        #Initialization of variables
        local warning=80000
        local critical=100000
        local valueName="UsedVirtualMemoryValue"
        local SecondaryFunction=True

        #Function calls / Wmic
        FreeVirtualMemory FreeVirtualMemoryValue   
        TotalVirtualMemory TotalVirtualMemoryValue 

        #Treatment 
        UsedVirtualMemoryValue=$(($TotalVirtualMemoryValue - $FreeVirtualMemoryValue))
        local value=$UsedVirtualMemoryValue

        #Function display / return
        if [[ ! -n $TertiaryFunction ]]; then
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

# Paging files part
function FreeSpaceInPagingFiles(){  # Amount of swap file invailable on the system
        #Initialization of variables
        local warning=80000
        local critical=100000
        local valueName="FreeSpaceInPagingFilesValue"

        #Function calls / Wmic
        FreeSpaceInPagingFilesValue=$(echo "$(wmic -U $passwordFile //$ip "select FreeSpaceInPagingFiles from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes)")

        #Treatment 
        FreeSpaceInPagingFilesValue=$(echo $FreeSpaceInPagingFilesValue|awk -F " " '{print $4}')
        local value=$FreeSpaceInPagingFilesValue

        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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

function SizeStoredInPagingFiles(){ # Amount of swap file installed on the system : 
        #Initialization of variables
        local warning=80000
        local critical=100000
        local valueName="SizeStoredInPagingFilesValue"

        #Function calls / Wmic
        SizeStoredInPagingFilesValue=$(echo "$(wmic -U $passwordFile //$ip "select SizeStoredInPagingFiles from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes)")
        
        #Treatment 
        SizeStoredInPagingFilesValue=$(echo $SizeStoredInPagingFilesValue|awk -F " " '{print $4}')
        local value=$SizeStoredInPagingFilesValue

        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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

function UsedInPagingFiles(){       # Amount of swap file used in the system 
        #Initialization of variables
        local warning=80000
        local critical=100000
        local valueName="UsedInPagingFilesValue"
        local SecondaryFunction=True

        #Function calls / Wmic
        FreeSpaceInPagingFiles FreeSpaceInPagingFilesValue
        SizeStoredInPagingFiles SizeStoredInPagingFilesValue
        
        #Treatment 
        UsedInPagingFilesValue=$(($SizeStoredInPagingFilesValue - $FreeSpaceInPagingFilesValue))
        local value=$UsedInPagingFilesValue

        #Function display / return
        if [[ ! -n $TertiaryFunction ]]; then
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

# RAM part
function FreePhysicalMemory() {     # Amount of RAM available in the system
        #Initialization of variables
        local warning=3210108
        local critical=3300000
        local valueName="FreePhysicalMemoryValue"

        #Function calls / Wmic
        FreePhysicalMemoryValue=$(echo "$(wmic -U $passwordFile //$ip "select FreePhysicalMemory from Win32_OperatingSystem" --option='client ntlmv2 auth'=Yes )")

        #Chain cleaning
        FreePhysicalMemoryValue=$( echo $FreePhysicalMemoryValue|awk -F " " '{print $4}')
        local value=$FreePhysicalMemoryValue

        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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

function TotalPhysicalMemory() {    # Amount of RAM installed in the system
        #Initialization of variables
        local warning=4303771
        local critical=4503771
        local valueName="TotalPhysicalMemoryValue"

        #Function calls / Wmic
        TotalPhysicalMemoryValue=$(echo "$(wmic -U $passwordFile //$ip "select TotalPhysicalMemory from Win32_ComputerSystem" --option='client ntlmv2 auth'=Yes)")
        
        #Treatment 
        TotalPhysicalMemoryValue=$(echo $TotalPhysicalMemoryValue|awk -F "|" '{print $3}')
        TotalPhysicalMemoryValue=$(($TotalPhysicalMemoryValue / 1000 ))
        local value=$TotalPhysicalMemoryValue

        #Function display / return
        if [[ ! -n $SecondaryFunction ]]; then
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

function UsedPhysicalMemory() {     # Amount of RAM used in the system 
        #Initialization of variables
        local warning=3000000
        local critical=3500000
        local valueName="UsedPhysicalMemoryValue"
        local SecondaryFunction=True

        #Function calls / Wmic
        FreePhysicalMemory FreePhysicalMemoryValue 
        TotalPhysicalMemory TotalPhysicalMemoryValue 
        
        #Treatment 
        UsedPhysicalMemoryValue=$(($TotalPhysicalMemoryValue - $FreePhysicalMemoryValue))
        local value=$UsedPhysicalMemoryValue

        #Function display / return
        if [[ ! -n $TertiaryFunction ]]; then
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
### Memory part

### General part
#Display part
function msg() { # simplified display 
        echo >&2 -e "${1-}"
}

function die() { # error message
        local msg=$1
        local code=${2-1}
        msg "${RED}$msg${NOFORMAT}"
        usage
        exit "$code"
}

function listOfFunction() {        # display all wmic functions available
        msg "
        Available WMIC functions:
                Standard system metrics
            |       [Physical and virtual memory occupancy rate]
            |       |       Amount of RAM installed in the system : 
            |       |               TPM, tpm, totalphymem                  TotalPhysicalMemory
            |       |       Amount of RAM used in the system : 
            |       |               UPM, upm, usedphymem                   UsedPhysicalMemory
            |       |       Amount of swap file installed on the system : 
            |       |               SPF,  spf,  sizepaging                 SizeStoredInPagingFiles
            |       |       Amount of swap file used in the system : 
            |       |               UPF,  upf,  usedpaging                 UsedInPagingFiles
            |       |       Memory occupation (with RAM & SWAP) :
            |       |               UTM, utm, usedtotalmem                 UsedTotalMemory 
            |
            |       [Load average]
            |       |       Percentage of CPU load :
            |       |               GCC, gcc, cpucharge                    globalCpuCharge
            |
            |       [Time since last system reboot]
            |       |       Time since the last system restart (uptime) in seconds  :
            |       |               UPT, upt, uptime                       upTime
            |
            |       [Machine NTP Synchronization Status]
            |       |       The local date in the system (YYYYMMDDhhmmss) :
            |       |               LDT, ldt, localtime                    localDateTime
            |       |       Current system time (JJ/MM/YYYY/hh/mm/ss) format :
            |       |               LDF, ldf, localformat                  localDateTimeFormat 
            
            Monitoring of the physical components of the machine 
            |       [Status of the materials making up the equipment]
            |       |       Fan status :
            |       |               FT, ft, fantach                        FanTachometer
            |       |       Disk status :
            |       |               STD, std, statusdisk                   statusDiskDrive 
            |       |       Power Supply status :
            |       |               SPS, sps, statuspower                  statusPowerSupply

            Newtork metrics
            |       [Response time to ping]
            |       |       Response to an ICMP echo request (ping) :
            |       |               PS, ps, ping                           pingStatus
            |       |       Average RTT over 10 consecutive requests in milliseconds : 
            |       |               PSA, psa, pinga                        pingStatusAverage
            |
            |       [Network Card status]
            |       |       Presence of a functional link :
            |       |               NA, na, netada                         networkadaptater
            |       |       Input bandwidth occupancy rate :
            |       |               IOR, ior, ioccupr                      inputOccupRate
            |       |       Output occupancy rate :
            |       |               OOR, oor, ooccupr                      outputOccupRate
        "
}

function usage() { # help display
        msg "
                Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-l] [-v] -w function

                Script description here.

                Available options:
                -h, --help      Print this help and exit
                -l, --list      Print list of function and exit
                -v, --verbose   Print script debug info
                -w, --wmic      Some param description
                -t, --test      Test some wmic command

                exemple : 
                Usage: $(basename "${BASH_SOURCE[0]}") -w upm
                Usage: $(basename "${BASH_SOURCE[0]}") -t FreePhysicalMemory-Win32_OperatingSystem

        "
}

#Parsing part
function parse_wmic(){             # parsing wmic function
        case "$param" in
                FPM|fpm|freephymem   )   FreePhysicalMemory      ;;
                TPM|tpm|totalphymem  )   TotalPhysicalMemory     ;;
                UPM|upm|usedphymem   )   UsedPhysicalMemory      ;;
                FPF|fpf|freepaging   )   FreeSpaceInPagingFiles  ;;
                SPF|spf|sizepaging   )   SizeStoredInPagingFiles ;;
                UPF|upf|usedpaging   )   UsedInPagingFiles       ;;
                FVM|fvm|freevirtmem  )   FreeVirtualMemory       ;;
                TVM|tvm|totvirtmem   )   TotalVirtualMemory      ;;
                UVM|uvm|usedvirtmem  )   UsedVirtualMemory       ;;
                UTM|utm|usedtotalmem )   UsedTotalMemory         ;;
                GCC|gcc|cpucharge    )   globalCpuCharge         ;;
                LDT|ldt|localtime    )   localDateTime           ;;
                LBT|lbt|lastboot     )   lastBootTime            ;;
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

function parse_params() {          # parsing user parameter
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

#Design part
function setup_colors() { # Allow to use cli colors into the script
        if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
                NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
        else
                NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
        fi
}

#Main part
function main() {                  # main function
        setup_colors
        parse_params "$@"
        parse_wmic
}
### General part

### Program
main "$@"
### Program
