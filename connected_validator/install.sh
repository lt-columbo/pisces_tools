#!/bin/bash
echo "\n"
echo "---------------------------------------------------------------------------"
echo " Installing connected validator script"
echo "---------------------------------------------------------------------------"
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/connected_validator/connected_validator.php -O /home/admin/connected_validator.php
chmod ugo+x /home/admin/connected_validator.php
apt install -y curl php-cli php7.3-curl
chown admin:admin /home/admin/connected_validator.php
echo "---------------------------------------------------------------------------"
echo " To run: type ./connected_validator_info.php"
echo "----------------------------------------------------------------------------"
