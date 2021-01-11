#!/bin/bash
aHostname=$(hostname)

# reset files
echo '"ID","Type","Name","Documentation"' > ${aHostname}_elements.csv
echo '"ID","Key","Value"' > ${aHostname}_properties.csv
echo '"ID","Type","Name","Documentation","Source","Target"' > ${aHostname}_relations.csv

# gather network related information
ifconfig -a|awk -F' ' -f archi_tech_ifconfig.awk|sort -k 2 -t ';' > ${aHostname}_archi_tech_ifconfig.tmp
ifconfig -a|grep "inet "|sed -e 's/^.*inet //'|cut -d ' ' -f 1|xargs -n 1 host|awk -F' ' -f archi_tech_hosts.awk|sed -e '/\..*;/ s/^[^\.]*//' -e 's/,$//'|sort -k 3 -t ';' > ${aHostname}_archi_tech_hosts.tmp
netstat -rn|grep -e " en[0-9]" -e " lo[0-9]"|grep  -e " U "|tr -s ' '|awk -F' ' '{ print $6 ";" $1 }'|sort -k 1 -t ';' > ${aHostname}_archi_tech_netstat.tmp
join -1 2 -2 3 -t ';' -o "1.1,1.2,2.1,2.2" ${aHostname}_archi_tech_ifconfig.tmp ${aHostname}_archi_tech_hosts.tmp|sort -k 1 -t ';' > ${aHostname}_archi_tech_interim.tmp
join -j 1 -t ';' ${aHostname}_archi_tech_interim.tmp ${aHostname}_archi_tech_netstat.tmp > ${aHostname}_archi_tech.tmp

# Device
for aelem in $(cut -d ';' -f 1 ${aHostname}_archi_tech.tmp|sort|uniq); do echo `uuid_get`";${aelem}"; done > ${aHostname}_archi_tech_uuid.tmp
sort -k 2 -t ';' ${aHostname}_archi_tech_uuid.tmp > ${aHostname}_archi_tech_uuid_sort.tmp
sort -k 1 -t ';' ${aHostname}_archi_tech.tmp > ${aHostname}_archi_tech_sort.tmp
join -1 2 -2 1 -t ";" ${aHostname}_archi_tech_uuid_sort.tmp ${aHostname}_archi_tech_sort.tmp > ${aHostname}_archi_tech.csv
awk -F';' '{ print $2 ";Device;" $1 }' ${aHostname}_archi_tech.csv|sort|uniq|sed -e 's/;/";"/g' -e 's/^/"/' -e 's/$/"/' >> ${aHostname}_elements.csv
cp ${aHostname}_archi_tech_uuid_sort.tmp ${aHostname}_archi_tech_device.uuid

# Path
for aelem in $(cut -d ';' -f 3 ${aHostname}_archi_tech.tmp|sort|uniq); do echo `uuid_get`";${aelem}"; done > ${aHostname}_archi_tech_uuid.tmp
sort -k 2 -t ';' ${aHostname}_archi_tech_uuid.tmp > ${aHostname}_archi_tech_uuid_sort.tmp
sort -k 3 -t ';' ${aHostname}_archi_tech.tmp > ${aHostname}_archi_tech_sort.tmp
join -1 2 -2 3 -t ";" ${aHostname}_archi_tech_uuid_sort.tmp ${aHostname}_archi_tech_sort.tmp > ${aHostname}_archi_tech.csv
awk -F';' '{ print $2 ";Path;" $1 " (" $NF ")" }' ${aHostname}_archi_tech.csv|sort|uniq|sed -e 's/;/";"/g' -e 's/^/"/' -e 's/$/"/' >> ${aHostname}_elements.csv
cp ${aHostname}_archi_tech_uuid_sort.tmp ${aHostname}_archi_tech_path.uuid

# AggregationRelationship
for aelem in $(cut -d ';' -f 2 ${aHostname}_archi_tech.tmp|sort|uniq); do echo `uuid_get`";${aelem}"; done > ${aHostname}_archi_tech_uuid.tmp
sort -k 2 -t ';' ${aHostname}_archi_tech_uuid.tmp > ${aHostname}_archi_tech_uuid_sort.tmp
sort -k 2 -t ';' ${aHostname}_archi_tech.tmp > ${aHostname}_archi_tech_sort.tmp
join -1 2 -2 2 -t ";" ${aHostname}_archi_tech_uuid_sort.tmp ${aHostname}_archi_tech_sort.tmp > ${aHostname}_archi_tech_device.tmp
sort -k 3 -t ";" ${aHostname}_archi_tech_device.tmp > ${aHostname}_archi_tech_sort_device.tmp
join -1 2 -2 3 -t ";" ${aHostname}_archi_tech_device.uuid ${aHostname}_archi_tech_sort_device.tmp > ${aHostname}_archi_tech_path.tmp
sort -k 5 -t ";" ${aHostname}_archi_tech_path.tmp > ${aHostname}_archi_tech_sort_path.tmp
join -1 2 -2 5 -t ";" ${aHostname}_archi_tech_path.uuid ${aHostname}_archi_tech_sort_path.tmp > ${aHostname}_archi_tech.csv
awk -F';' '{ print $6 ";AggregationRelationship;" $5 " (" $7 ");;" $2 ";" $4 }' ${aHostname}_archi_tech.csv|sort|uniq|sed -e 's/;/";"/g' -e 's/^/"/' -e 's/$/"/' >> ${aHostname}_relations.csv
