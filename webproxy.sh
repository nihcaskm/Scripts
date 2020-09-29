#!/bin/sh
s=$(i=1
while [ "$i" -le 100 ]; do
    echo -n "="
    i=$(( i + 1 ))
done)
echo -e "\nInitiating Script... To Stop the Script Press Ctrl+C"
echo -e "\nEnter Domain Name (e.x. sophos.com) :"
read URL
echo -e "\nEnter Source IP :"
read sip
echo -e "\nSystem Details " >> web.log
echo -e "\n" >> web.log
date >> web.log
uptime >> web.log
cat /etc/displayversion >> web.log
echo $s >> web.log
echo -e "\nPerforming Category Lookup (10%)"
nsxld -l $URL >> web.log
echo $s >> web.log
echo -e "\nPerforming Name Resolution (20%)"
nslookup $URL | grep Address >> web.log
echo $s >> web.log
echo -e "\nInitiating Ping on $URL (30%)"
echo -e "\nPing on $URL" >> web.log
echo -e "\n" >> web.log
ping $URL -c 8 >> web.log
echo $s >> web.log
echo -e "\nInitiating Telnet on $URL (40%)"
echo -e "\nTelnet on Port 80" >> web.log
echo -e "\n" >> web.log
sleep 5 | telnet $URL 80 >> web.log
echo -e "\nTelnet on Port 443" >> web.log
echo -e "\n" >> web.log
sleep 5 | telnet $URL 443 >> web.log
echo $s >> web.log
echo -e "\nChecking Status of Service (50%)"
status=$(service -S | grep awarrenhttp | cut -d " " -f11)
if [ $status == "RUNNING,DEBUG" ]
then
   echo -e "\nService is in Debug"
   echo -e "\nReload URL and then press Enter Key (60%)"
   read reload
   echo -e "\nCollecting Logs (70%)"
   echo -e "\nLogs on URL" >> web.log
   echo -e "\n" >> web.log
   grep -i "$URL" /log/awarrenhttp_access.log >> web.log
   echo $s >> web.log
   echo -e "\nLogs on Source IP" >> web.log
   echo -e "\n" >> web.log
   grep -i "$sip" /log/awarrenhttp_access.log >> web.log
   echo $s >> web.log
   echo -e "\nWidcard Logs on URL" >> web.log
   echo -e "\n" >> web.log
   grep -i "$URL" /log/*.log >> web.log
   echo $s >> web.log
   service awarrenhttp:debug -ds nosync >> /dev/null 2>&1
elif [ $status == "RUNNING" ]
then
   echo -e "\nService is not in Debug"
   echo "Keeping Service in Debug"
   service awarrenhttp:debug -ds nosync >> /dev/null 2>&1
   echo -e "\nReload URL and then press Enter Key (60%)"
   read reload
   echo -e "\nCollecting Logs (70%)"
   echo -e "\nLogs on URL" >> web.log
   echo -e "\n" >> web.log
   grep -i "$URL" /log/awarrenhttp_access.log >> web.log
   echo $s >> web.log
   echo -e "\nLogs on Source IP" >> web.log
   echo -e "\n" >> web.log
   grep -i "$sip" /log/awarrenhttp_access.log >> web.log
   echo $s >> web.log
   echo -e "\nWidcard Logs on URL" >> web.log
   echo -e "\n" >> web.log
   grep -i "$URL" /log/*.log >> web.log
   echo $s >> web.log
   service awarrenhttp:debug -ds nosync >> /dev/null 2>&1
else
   echo -e "\nIssue with the awarrenhttp service"
   echo "Restarting awarrenhttp service"
   service awarrenhttp:start -ds nosync >> /dev/null 2>&1
fi
echo -e "\nCollecting Conntrack Entries on Source IP (80%)"
echo -e "\nConntrack on Source IP" >> web.log
echo -e "\n" >> web.log
conntrack -L -s $sip >> web.log
echo $s >> web.log
echo -e "\nCollecting Conntrack Entries on Destination IP  (90%)"
resolve=$(nslookup $URL | grep Address | awk '{print $4}')
echo -e "\nConntrack on Destination IP" >> web.log
echo -e "\n" >> web.log
conntrack -L -d $resolve >> web.log
echo $s >> web.log
echo -e "\nFinal Status of awarrenhttp Service" >> web.log
echo -e "\n" >> web.log
service -S | grep awarrenhttp >> web.log
echo $s >> web.log
echo -e "\nStatus of All Services" >> web.log
echo -e "\n" >> web.log
service -S >> web.log
echo $s >> web.log
echo -e "\nCore Dumps" >> web.log
echo -e "\n" >> web.log
ls -larth /var/cores >> web.log
echo $s >> web.log
echo -e "\nDisk Space" >> web.log
echo -e "\n" >> web.log
df -kh >> web.log
echo $s >> web.log
echo -e "\nLicensing Logs" >> web.log
echo -e "\n" >> web.log
tail -n 30 /log/licensing.log | grep "trackingId" >> web.log
echo $s >> web.log
echo -e "\nBusyBox Status" >> web.log
echo -e "\n" >> web.log
grep "BusyBox" /log/*.log >> web.log
echo $s >> web.log
echo -e "\nCollected All Logs (100%)"
echo -e "\nStopping Script"
