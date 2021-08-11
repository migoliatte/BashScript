# WmicAutomation

    Usage: 
            WmicAutomation.sh [-h] [-l] [-v] -w function
            Script description here:
                    Available options:
                            -h, --help      Print this help and exit
                            -l, --list      Print list of function and exit
                            -v, --verbose   Print script debug info
                            -w, --wmic      Some param description
                            -t, --test      Test some wmic command
                    exemple : 
                            WmicAutomation.sh -w upm
                            WmicAutomation.sh -t FreePhysicalMemory-Win32_OperatingSystem

    Available WMIC functions:
            Standard system metrics :
                    [Physical and virtual memory occupancy rate]
                            Amount of RAM in the system : 
                                    TPM, tpm, totalphymem   TotalPhysicalMemory
                            Amount of RAM used  : 
                                    UPM, upm, usedphymem    UsedPhysicalMemory
                            Quantity of swap file installed on the system : 
                                    SPF,  spf,  sizepaging    SizeStoredInPagingFiles
                            Quantity of swap file used : 
                                    UPF,  upf,  usedpaging    UsedInPagingFiles
                            Memory occupation (with RAM & SWAP)
                                    UTM, utm, usedtotalmem  UsedTotalMemory 
                    [Load average]
                            GCC, gcc, cpucharge  globalCpuCharge
                    [Time since last system reboot]
                            UPT, upt, uptime     upTime
                    [Machine NTP Synchronization Status]
                            Current system time :
                                    LDT, ldt, localtime          localDateTime
                            Current system time (JJ/MM/YYYY/hh/mm/ss) format :
                                    LDF, ldf, localformat          localDateTimeFormat 

            Monitoring of the physical components of the machine : 
                    [Status of the materials making up the equipment]
                            Disk status :
                                    STD, std, statusdisk statusDiskDrive 
                            Power Supply status :
                                    SPS, sps, statuspower statusPowerSupply

            Newtork metrics :
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
