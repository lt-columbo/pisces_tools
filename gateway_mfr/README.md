# Pisces Miner gateway_mfr provision Docker image

The image is a gzipped tar file even though it's not named using the usual convention of having .tar in its name.

**To download to your miner**

Here we use git, it will pull a directory down. Inside the directory will be two files, this one you are reading (README.md) and the gateway_mfr image.

1. cd  /home/admin then use

2. git clone lt-columbo/gateway_mfr

to pull this file to your miner.

**To Load:**

3. cd  ~/gateway_mfr
4. load --input gateway_mfr:arm64.img.gz

**To Run**

This is uncertain. I am not a Docker person. 

This may prove helpful but **_it's untested, use at your own risk_**:

sudo docker run -d --init --restart always --net default -e OTP_VERSION=22.3.2 -e REBAR3_VERSION=3.13.1 --name provision --device /dev/i2c-0:/dev/i2c-1 gateway_mfr:arm64

You can always stop the running image with a) sudo docker gateway_mfr stop then remove the image with b) docker image rm xxxx (where xxxx=container id of the image). Don't get confused.

## Some useful things to do with this image

1. sudo docker exec provision gateway_mfr ecc test

Results look like:
```
+--------------------+------+
|        name        |result|
+--------------------+------+
|     serial_num     |  ok  |
|{zone_locked,config}|  ok  |
| {zone_locked,data} |  ok  |
|    slot_config     |  ok  |
|     key_config     |  ok  |
|     miner_key      |  ok  |
+--------------------+------+
```

2. sudo docker exec provision gateway_mfr ecc onboarding

Prints your miner key
