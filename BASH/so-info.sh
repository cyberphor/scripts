#!/bin/bash
clear
header() { echo "$(tput setaf 4)$*$(tput setaf 9)"; }

HOSTNAME=$(hostname)

SERVICES=$(sudo service nsm status && sudo docker ps)
BRO=$(echo $SERVICES | grep -o 'Bro')
IDS=$(echo $SERVICES | grep -o 'alert')
ELASTICSEARCH=$(echo $SERVICES | grep -o 'elasticsearch' | uniq)
LOGSTASH=$(echo $SERVICES | grep -o 'logstash' | uniq)
KIBANA=$(echo $SERVICES | grep -o 'kibana' | uniq)
if [[ $KIBANA ]] && [[ $BRO ]] && [[ $IDS ]] && [[ $ELASTICSEARCH ]] && [[ $LOGSTASH ]]; then
  ROLE='Stand-alone'
elif [[ $KIBANA ]]; then
  ROLE='Master'
elif [[ $BRO ]] && [[ $IDS ]] && [[ $ELASTICSEARCH ]] && [[ $LOGSTASH ]]; then
  ROLE='Heavy Node'
elif [[ $BRO ]] && [[ $IDS ]]; then
  ROLE='Forward Node'
elif [[ $ELASTICSEARCH ]] && [[ $LOGSTASH ]]; then
  ROLE='Storage Node'
else 
  ROLE='Analyst Workstation'
fi

if [[ $ROLE = 'Stand-alone' ]] || [[ $ROLE = 'Master' ]]; then
  MASTER_IP=$(ip address | grep 'inet ' | grep -v 'host\|172.18.\|172.17.' | awk {'print $2'} | cut -d'/' -f1)
  SENSOR_IP=$MASTER_IP
elif [[ $ROLE = 'Analyst Workstation' ]]; then
  MASTER_IP='n/a'
  SENSOR_IP=$(ip address | grep 'inet ' | grep -v 'host\|172.18.\|172.17.' | awk {'print $2'} | cut -d'/' -f1 | sed -z 's/\n/\n  /g' | head -n -1)
else 
  MASTER_IP=$(sudo cat /etc/salt/minion.d/onionsalt.conf | grep 'master' | awk '{print $2}')
  SENSOR_IP=$(ip address | grep 'inet ' | grep -v 'host\|172.18.\|172.17.' | awk {'print $2'} | cut -d'/' -f1 | sed -z 's/\n/\n  /g' | head -n -1)
fi

if [[ $ROLE = 'Storage Node' ]] || [[ $ROLE = 'Analyst Workstation' ]]; then
  MGMT_NIC=$(ip link | grep ": <" | cut -d":" -f2 | tr -d ' ' | grep -v 'lo\|br*\|docker*\|veth*' | tr ' ' '\n'  | sed -z 's/\n/\n      /g' | head -n -1)
  SNIFFING_NICS='n/a'
  IDS_ENGINE='n/a'
  ADMINISTRATORS=$(sudo getent group | grep sudo | cut -d ':' -f4 | sed -z 's/,/\n  /g')
  ANALYSTS='n/a'
else
  NICS=$(ip link | grep ": <" | cut -d":" -f2 | tr -d ' ' | grep -v 'lo\|br*\|docker*\|veth*' | tr ' ' '\n')
  MGMT_NIC=""
  SNIFFING=""
  for NIC in $NICS
  do
    if [[ $(ip link show $NIC | grep -o 'PROMISC') ]]; then
      SNIFFING+="$NIC,"
    else
      MGMT_NIC=$NIC
    fi	
  done
  SNIFFING_NICS=$(echo $SNIFFING | sed -z 's/,/\n      /g' | head -n -1)
  IDS_ENGINE=$(sudo cat /etc/nsm/securityonion.conf | grep 'ENGINE' | cut -d'=' -f2)
  if [[ $IDS_ENGINE == 'snort' ]]; then
    IDS_VERSION=$(cat /etc/nsm/*/snort.conf | grep VERSIONS | uniq | cut -d':' -f2 | tr -d ' ')
  elif [[ $IDS_ENGINE == 'suricata' ]]; then
    IDS_VERSION=$(suricata -V | cut -d' ' -f5)
  fi
  ADMINISTRATORS=$(sudo getent group | grep sudo | cut -d ':' -f4 | sed -z 's/,/\n  /g')
  ANALYSTS=$(sudo so-user-list | tail -n +2 | awk {'print $2'} | sed -z 's/\n/\n  /g' | head -n -1)
  if [[ -z $ANALYSTS ]]; then
    ANALYSTS='None'
  fi
fi

header "Hostname:"
echo -e "  $HOSTNAME"
header "Role:"
echo -e "  $ROLE"
header "Master"
echo -e "  $MASTER_IP"
header "Sensor:"
echo -e "  $SENSOR_IP"
header "    Management interface(s):" 
echo -e "      $MGMT_NIC"
header "    Sniffing interface(s):" 
echo -e "      $SNIFFING_NICS"
header "IDS: "
echo -e "  $IDS_ENGINE $IDS_VERSION"
header "Administrator(s):"
echo -e "  $ADMINISTRATORS"
header "Analysts(s)"
echo -e "  $ANALYSTS"
