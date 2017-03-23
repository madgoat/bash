#!/bin/bash

prog="apache2"
#Threshold for number of running processes
max_procs=100
#Sleep timer
SleepTime=5

#restart_live 1 to run restart or 0 for testing
restart_live=1

#Do we want mail of events? 1 for yes, 0 for no
mailon=1
#Mail will be sent to
mailto="email@address.com"
#File to store mail message
FILE='/home/user/log/tmp.txt'


#gets number of a running process as defined in $prog variable
get_numprocs(){
        ps -ef | grep $prog | grep -v grep | wc -l
}
#function to work with services
execCmd(){
        if [[ $restart_live -eq 1 ]]
        then
                cmd_What="${1}" #what action are we running on the service
                pRun="/etc/init.d/$prog ${cmd_What}"
                eval $pRun
        fi
}

mailme(){
        if [[ $mailon -eq 1 ]]
        then
                echo "To: $mailto"  > ${FILE}
                echo "Subject: APACHE: Action ${1} : ${2}" >> ${FILE}
                echo "From: root@localhost" >> ${FILE}

                /usr/sbin/sendmail -t < ${FILE}
        fi

}

# Main routine
num_procs=$(get_numprocs) #get the number of processes and set the variable num_procs
if [[ $num_procs -gt $max_procs ]]
        then
                execCmd "restart"
                sleep ${SleepTime}
                echo "`/bin/date` : $num_procs processes : $prog restarted"
                mailme "restart" "Processes $num_procs : Threshold $max_procs"
                exit 0
        elif [[ $num_procs -eq 0 ]]
        then
                execCmd "start"
                sleep ${SleepTime}
                echo "`/bin/date` : $num_procs processes : $prog was not running"
                mailme "start" "Processes $num_procs"
                exit 0
        else
                #We can remove this once we are sure that things are smooth.
                #This is used to see how many processes are running normally
                echo "`/bin/date` : $num_procs processes : All is well."
                exit 0
fi
