#!/bin/bash
echo "--------------------------------------------------------------------------------"
echo " Installing connected validator script.                                         "
echo " If this script stalls after downloading sudo is waiting on password.           "
echo " Simply type password in and press enter.                                       "
echo "--------------------------------------------------------------------------------"
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/connected_validator/connected_validator.php -O /home/admin/connected_validator.php
chmod ugo+x /home/admin/connected_validator.php
chown admin:admin /home/admin/connected_validator.php
echo "--------------------------------------------------------------------------------"
echo " To run: type sudo connected_validator_info.php                                 "
echo "--------------------------------------------------------------------------------"
