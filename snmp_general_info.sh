#!/bin/sh
###############################################################################
#                                                                             #
# A script for getting information from hosts with SNMP                       #
# Written by Farid Joubbi @consign.se 2014-04-16                              #
#                                                                             #
# USAGE:                                                                      #
# Add as a check in Op5/Nagios                                                #
# The check will always return OK.                                            #
#                                                                             #
###############################################################################

#set -x
#set -v

if [ $# == 5 ]; then
  SNMPOPT="-v 3 -a $2 -A $3 -l authPriv -u op5 -x $4 -X $5 $1 -Ov -t 0.5 -Lo"
fi 

if [ $# == 2 ]; then
  SNMPOPT="-v 2c -c $2 $1 -Ov -t 0.5 -Lo"
fi

if [ $# -lt 2 ]; then
  echo "Not enough arguments!"
  echo "Quitting!"
  exit 1
fi


# Handle SNMP error (Usually due to no SNMPv3 support)
hostname=`/usr/bin/snmpget $SNMPOPT SNMPv2-MIB::sysName.0 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
echo "$hostname" | /bin/grep snmpget > /dev/null
if [ $? == 0 ]; then
  hostname="N/A"
  description="N/A"
  location="N/A"
  contact="N/A"
  echo ""$hostname",<br> "$description",<br> "$location",<br> "$contact""
  exit 0  
fi

#hostname=`/usr/bin/snmpget $SNMPOPT SNMPv2-MIB::sysName.0 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
description=`/usr/bin/snmpget $SNMPOPT SNMPv2-MIB::sysDescr.0 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`
location=`/usr/bin/snmpget $SNMPOPT SNMPv2-MIB::sysLocation.0 | /bin/sed -e 's/\STRING: //g' | tr '[<>]' '_'`
contact=`/usr/bin/snmpget $SNMPOPT SNMPv2-MIB::sysContact.0 | /bin/sed -e 's/\STRING: //g' | /bin/sed -e 's/\"//g' | tr '[<>]' '_'`


# Check for empty variables
if [ -z "$hostname" ]; then
  hostname="N/A"
fi
if [ -z "$description" ]; then
  description="N/A"
fi
if [ -z "$location" ]; then
  location="N/A"
fi
if [ -z "$contact" ]; then
  contact="N/A"
fi

echo ""$hostname",<br> "$description",<br> "$location",<br> "$contact""

exit 0
