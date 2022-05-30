## processlogslora.php

**This is a revised version of the lora packet analyzer
by Inigo Flores from here: [Lora Packet Analyzer Original](https://github.com/inigoflores/lora-packet-forwarder-analyzer)

This version adds a new -f=follow option to follow the log file.. If first runs the command as if l was provided, then follows. A change was made in how line data was parsed so the code is reused by the -l and -f options.

This code is [licenced under the MIT license](LICENSE.md) applied to the original code by Inigo Flores.

## To Install
Please first install the original lora packet analyzer [Lora Packet Analyzer Original by Inigo Flores](https://github.com/inigoflores/lora-packet-forwarder-analyzer)

Then run this command:

wget https://raw.githubusercontent.com/lt-columbo/pisces_tools/main/lorapacketforwarder/install.sh -O - | sudo bash
