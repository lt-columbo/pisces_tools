#!/bin/bash
echo "--------------------------------------------------------------------------------"
echo " Installing connected validator script.                                         "
echo "--------------------------------------------------------------------------------"
wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/connected_validator/connected_validator.php -O /home/admin/connected_validator.php
chmod ugo+x /home/admin/connected_validator.php
echo "--------------------------------------------------------------------------------"
echo " To run: type sudo connected_validator_info.php                                  "
echo "--------------------------------------------------------------------------------"