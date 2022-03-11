#!/bin/bash

#==============================================================================
# filename            : vpn_and_mount.sh
# description         : Establish a VPN connection and mount a smb share
# author              : Maximilian Fries
# email               : maxfries@t-online.de
# date                : 2022-03-11
# version             : 0.0.1
# license             : MIT
#==============================================================================

target=192.168.2.105
target_share=//$target/homes/max

# Check if target is already presenet
# Return 0 if it is present, 1 else
is_target_present(){
if ping -c 1 $target &> /dev/null
then
  echo "Target is reachable. Looks like VPN is already up."
  return 0
else
  echo "Target is not reachable. Starting VPN tunnel."
  return 1
fi
}

# Check if target share is already present
# Return 0 is is mounted, 1 else
is_share_mounted(){
if grep -qs "$target_share " /proc/mounts
then
  echo "Target share is mounted."
  return 0
else 
  echo "Target share is not yet mounted."
  return 1
fi
}

mount_smb_share(){
  sudo mount -t cifs $target_share /mnt/smb/ds918/max -o credentials=/root/.smbcredentials,iocharset=utf8,vers=2.0,rw,auto,dir_mode=0777,file_mode=0777,nounix,_netdev
}

connect_vpn(){
  sudo service openvpn@ds918 start
  sleep 3
}

# Print success message and exit program
all_done(){
  echo "all work done :)"
  exit 0
}

# Print error message and exit program
err(){
  echo "There went something wrong :("
  exit 1
}

### main ###

if is_share_mounted; then
  all_done
fi

if is_target_present; then
  mount_smb_share
else
  connect_vpn
fi

if is_share_mounted; then
  all_done
else
  sleep 3
  mount_smb_share
fi

if is_share_mounted; then
  all_done
else
  err
fi

# This shall never be reached :)
err
