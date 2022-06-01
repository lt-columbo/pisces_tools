#!/bin/bash
echo "\n"
echo "---------------------------------------------------------------------------\n"
echo " Installing connected validator script.\n"
echo " If this script stalls after downloading sudo is waiting on password.\n"
echo " Simply type password in and press enter.\n"
echo "---------------------------------------------------------------------------\n"
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/connected_validator/connected_validator.php -O /home/admin/connected_validator.php
chmod ugo+x /home/admin/connected_validator.php
chown admin:admin /home/admin/connected_validator.php
echo "----------------------------------------------------------------------------\n"
echo " To run: type sudo connected_validator_info.php\n"
echo "----------------------------------------------------------------------------\n"
