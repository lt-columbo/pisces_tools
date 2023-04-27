#!/bin/bash

FIRMWARE_VERSION="0.60"
GATEWAY_RS_PATH="/etc/helium_gateway"
GATEWAY_VERSION="v1.0.2"
GATEWAY_FILE="helium-gateway-1.0.2-armv7-unknown-linux-musleabihf.tar.gz"
DISTRIB_DATE="2023.04.14"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root - use sudo in front" 
   exit 1
fi

if [ ! -d "$GATEWAY_RS_PATH" ] 
then 
    echo "Does not appear that gateway 1.0.0 is installed because"       
    echo "directory $GATEWAY_RS_PATH DOES NOT exists." 
    exit 9999 # die with error code 9999 
fi

old_version=$(/etc/helium_gateway/helium_gateway --version)
echo "Helium Gateway version installed now is $old_version"

echo "Updating to $GATEWAY_VERSION"

# Download the gateway_rs program into $GATEWAY_RS_PATH 
wget "https://github.com/helium/gateway-rs/releases/download/$GATEWAY_VERSION/$GATEWAY_FILE" -P "$GATEWAY_RS_PATH/"

# Unzip the gz file into the /tmp
# move helium_gateway into place so we don't messup settings.toml (region settings)
tar -xvf "$GATEWAY_RS_PATH/$GATEWAY_FILE" -C /tmp helium_gateway
te=$?
if [ "$te" -eq 0 ]; then  

   mv /tmp/helium_gateway "$GATEWAY_RS_PATH/"
   
   # Delete the gz file 
   rm "$GATEWAY_RS_PATH/$GATEWAY_FILE"

   # Stop the service of helium
   service helium stop 

   # Start up the service
   service helium start

   echo "Helium_gateway running and updated, or so we think. See actual version below."

   # Update the lsb_release file
   echo "DISTRIB_RELEASE=$DISTRIB_DATE" | sudo tee /etc/lsb_release
fi

# Show version and running status
version=$(/etc/helium_gateway/helium_gateway --version)
echo "Helium Gateway version now on system is $version"
echo "VERIFY Helium_gateway is running with command below:"
echo "systemctl status helium"
