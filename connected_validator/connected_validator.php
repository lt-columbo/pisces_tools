#!/usr/bin/php
<?php
/* --------------------------------------------------------------------------------------------
  ltcolumbo's connected validator information - collects data on connected validator 

    Copyright (C) 2022  ltcolumbo

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/.
-------------------------------------------------------------------------------------------- */

// -----------------------------------------------------------------------------------------
// 
//                       C O N N E C T E D    V A L I D A T O R    I N F O
//
//  This script gathers information on the connected validator a Helium hotspot is connected to.
//  This is useful for seeing how close the validator and hotspot are and how long it takes to
//  send and receive data. It uses the 
//    1. docker miner command to get miner address 
//    2. uses this address to connect to Helium hotspot_for_address api to gather geographic data
//    3. finds the connected validator ip address using netstat
//    4. attempts to ping validator and get round trip time. 
//    5. Searches console log for validator connect message to get validator address
//    6. Uses Helium validator_for_address api to gather validator data
//    7. Uses geographic ip data service ipapi.co to attempt to retrieve geographic
//       data for validator ip.
//    8. Finally displays a summary of this data for you to make a decision on whether to 
//        restart the miner with 'sudo docker restart miner' command
//
//  A caveat in using this tool is that many validatorss seem to be located at AWS (Amazon Web
//   Services) and thos validators do not respond to ping requests.
// -------------------------------------------------------------------------------------------------
      
  

// change to do netstat, trackip address changes
define('PING_COUNT', 6);
define('PING_INTERVAL', 1);
$version = '2022052700';
$console_log_filename = "/home/pi/hnt/miner/log/console.log";

// script log
$find_log_filename = "/home/admin/connected_validator.log";

class logger {
    private $f;
    private $f_is_open = false;

    public function __construct($filename) {
        $result = $this->open_log($filename);
        return $result;
    }

    public function __destruct() {
        $this->close_log();
    }

    public function log_it($log_text) {
        fputs($this->f, strftime("%Y-%m-%d %H:%M:%S") . ' ' . $log_text);
    }

    public function open_log($filename) {
        $result = false;
        $this->f = fopen($filename, 'a');
        if ($this->f) {
            $result = true;
            $this->f_is_open = true;
        }
        return $result;
    }

    public function close_log() {
        if ($this->f_is_open) {
            fclose($this->f);
        }
        $this->f_is_open = false;
    }
} // end logger class

// ==================================================================================================

class heliumApi {
    public $curl_error = '';
    private $logger = null;
    // --------------------------------------
    // constructor
    // --------------------------------------
    public function __construct($logger) {
        if (!is_null($logger)) {
            $this->logger = $logger;
        }
    }
// -------------------------------------------------
// Use api call to helium api for hotspot address
// -------------------------------------------------
    public function hotspot_for_address($hotspot_address) {
        if ('/p2p/' == substr($hotspot_address, 0, 5)) {
            $hotspot_address = substr($hotspot_address, 5);
        }
        $url = sprintf("https://api.helium.io/v1/hotspots/%s", $hotspot_address);
        $json_data = $this->curl_call_api($url);
        if (!empty($json_data) and !empty($json_data['error'])) {
            $this->logger->log_it(sprintf("hotspot_for_address: %s lookup failed: %s \n", $hotspot_address, $json_data['error']));
        }
        if (is_array($json_data) && array_key_exists('data', $json_data)) {
            $json_data['data']['ip_address_data'] = $this->grab_ip_address_and_port($json_data['data']['status']['listen_addrs']);
        }
        return $json_data;
    }

// -------------------------------------------------
// Use api call to helium api for hotspot name
// -------------------------------------------------
    public function hotspot_for_name($hotspot_name) {
        if (!strstr($hotspot_name, '-')) {
            $hotspot_name = str_replace(' ', '-', $hotspot_name);
        }
        $hotspot_name = strtolower($hotspot_name);
        $url = sprintf("https://api.helium.io/v1/hotspots/name/%s", $hotspot_name);
        $json_data = $this->curl_call_api($url);
        if (!empty($json_data) and !empty($json_data['error'])) {
            $this->logger->log_it(sprintf("hotspot_for_name: %s lookup failed: %s \n", $hotspot_name, $json_data['error']));
        }
        if (is_array($json_data) && array_key_exists('data', $json_data)) {
            for ($i = 0; $i < sizeof($json_data['data']); $i++) {
                if (is_array($json_data['data'][$i]) && array_key_exists('listen_addrs', $json_data['data'][$i]['status'])) {
                    $json_data['data'][$i]['ip_address_data'] = $this->grab_ip_address_and_port($json_data['data'][$i]['status']['listen_addrs']);
                }
            }
        }
        return $json_data;
    }
// -------------------------------------------------
// Use api call to helium api for validator address
// -------------------------------------------------
    public function validator_for_address($validator_address) {
        $url = sprintf("https://api.helium.io/v1/validators/%s", $validator_address);
        $json_data = $this->curl_call_api($url);
        if (!empty($json_data) and !empty($json_data['error'])) {
            $this->logger->log_it(sprintf("validator_for_address: %s lookup failed: %s \n", $validator_address, $json_data['error']));
        }
        if (is_array($json_data) && array_key_exists('data', $json_data)) {
            $json_data['data']['ip_address_data'] = $this->grab_ip_address_and_port($json_data['data']['status']['listen_addrs']);
        }
        return $json_data;
    }

// -------------------------------------------------
// Use api call to helium api for validator name
// -------------------------------------------------
    function validator_for_name($validator_name) {
        // -------------------------------------------------------
        // if space separated names, replaces spaces with dashes
        // -------------------------------------------------------
        if (!strstr($validator_name, '-')) {
            $validator_name = str_replace(' ', '-', $validator_name);
        }
        $validator_name = strtolower($validator_name);
        $url = sprintf("https://api.helium.io/v1/validators/name/%s", $validator_name);
        $json_data = $this->curl_call_api($url);
        if (!is_array($json_data) || (!empty($json_data) and !empty($json_data['error']))) {
            $this->logger->log_it(sprintf("validator_for_name: %s lookup failed: %s \n", $validator_name, $json_data['error']));
        }
        if (is_array($json_data) && array_key_exists('data', $json_data)) {
            foreach ($json_data['data'] as $key => $validator_data) {
                if (@array_key_exists('listen_addrs', $validator_data['status'])) {
                    $json_data['data'][$key]['ip_address_data'] = $this->grab_ip_address_and_port($validator_data['status']['listen_addrs']);
                }
            }
        }
        return $json_data;
    }

    // ----------------------------------------------------------------
    // Logger interface - setup on instantiation. if null does nothing
    // ----------------------------------------------------------------
    private function log_it($logdata) {
        if (!is_null($this->logger)) {
            $this->logger->log_it($logdata);
        }
    }
    // ------------------------------------------
    // curl https interface
    // ------------------------------------------
    public function curl_call_api($url, $convert_to_json = true) {
        $this->curl_error = '';
        $result = false;
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:99.0) Gecko/20100101 Firefox/99.0');
        // Disable SSL verification
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        // Will return the response, if false it print the response
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $curl_result = curl_exec($ch);
        $status_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        if (curl_error($ch)) {
            $this->logger->log_it(sprintf("Curl error: %s\n",
                curl_error($ch)));
            $this->curl_error = curl_error($ch);
        }
        curl_close($ch);

        if (200 == $status_code || 404 == $status_code) {
            if ($convert_to_json) {
                $result = json_decode($curl_result, true);
            } else {
                $result = $curl_result;
            }
        }
        return $result;
    }
    // -----------------------------------------------------
    // Format an ip address into ip_address and port
    // input like this: /ip4/104.237.209.115/tcp/2154
    // -----------------------------------------------------
    private function grab_ip_address_and_port($listen_address) {
        $ip_address_data = null;
        if (is_array($listen_address)) {
            foreach ($listen_address as $key => $full_ip_address) {
                $ip_match = preg_match('#.*/ip4\/(.*)\/tcp\/(\d*).*#', $full_ip_address, $matches);
                if ($ip_match) {
                    $ip_address = $matches[1];
                    $port = $matches[2];
                    $ip_address_data[$key] = array('ip_address' => $ip_address, 'port' => $port);
                }
            }
        }
        return $ip_address_data;
    }
} // end class HeliumApi

// ==============================================================================
class unixUtils {
    private $logger = null;
    // --------------------------------------------------------
    // constructor
    // $logger - logger class that implements log_it(string)
    //           may be null for no logging
    // -------------------------------------------------------
    public function __construct($logger = null) {
        if (!is_null($logger) &&
            method_exists($logger, 'log_it')) {
            $this->logger = $logger;
        }
    }
    // -----------------------------------------------------
    // ping a host or ip and return the average time
    // $ip = ip4 address or host name
    // $count = number of ping requests (1 - 10)
    // $interval = seconds between ping requests (1 - 10)
    // returns average ms rounded to int or -1 on error
    // -----------------------------------------------------
    public function ping($ip, $count = 4, $interval = 1) {
        $count = $this->limit($count, 1, 10);
        $interval = $this->limit($interval, 1, 10);
        $cmd = "ping $ip -q -c " . (int) $count . ' -i ' . (int) $interval;
        $cmd_result = $this->run_command($cmd, $cmd_output);
        // rtt min/avg/max/mdev = 15.574/17.526/20.676/2.100 ms
        $time_match = preg_match('#rtt min/avg/max/mdev = (\d+\.\d+)/(\d+\.\d+)/(\d+\.\d+)/(\d+\.\d+) ms#', $cmd_output[4], $matches);
        if (!$time_match) {
            $matches[2] = -1;
        }
        $avg_ms_rounded = (int) round($matches[2]);
        $this->log_it(sprintf("Ping %s count: %d interval %d avg: %s (full result:%s)\n", $ip, $count, $interval, $avg_ms_rounded, $cmd_output[4]));
        return $avg_ms_rounded;
    }
    // -----------------------------------------------------
    // run netstat command to find the validator ip we
    // are connected to. Return the ip or false on failure
    // -----------------------------------------------------
    public function netstat_atn() {
        // tcp        0      0 192.168.30.30:60780     104.237.209.107:8080    ESTABLISHED
        $ip = false;
        $cmd = 'netstat -atn | grep "8080.* ESTABLISHED"';
        $cmd_result = $this->run_command($cmd, $cmd_output);
        // tcp        0      0 192.168.1.1:61780     104.237.209.107:8080    ESTABLISHED
        // in case of multiples, we only look for first ip returned
        $ip_match = preg_match('/^tcp.+\s(\d+\.\d+\.\d+\.\d+):8080.*ESTABLISHED$/', $cmd_output[0], $matches);
        if ($ip_match) {
            $ip = $matches[1];
        } else {
            echo "It doesn't appear miner in connected to a validator. Run 'netstat -atn | grep 8080' to verify connection.\n";
            echo "There should be at least one connection there showing with status 'ESTABLISHED'\n";
            echo "If not, wait 2 minutes and try the netstat command again.\n";
            echo "Possible solutions on Pisces: sudo docker restart miner   -or-  sudo reboot  wither should be effective.\n";
        }
        $this->log_it(sprintf("netstat returned validator ip of %s \n", $ip));
        return $ip;
    }
    // ----------------------------------------------------------
    // Find validator name in the console log based on ip_address
    // returns validator_name or false on failure to find
    // ----------------------------------------------------------
    // 2022-05-28 21:49:20.419 6 [info] <0.1858.0>@miner_poc_grpc_client_statem:connect_validator:{519,17} successfully connected to validator "short-sage-woodpecker" via connection #{client => http2_client,host => <<"104.237.209.107">>,http_connection => <0.1891.0>,scheme => <<"http">>}
    public function tac_console_log($console_log, $ip_address) {
        $validator_name = false;
        // ------------------------------------------------------------
        // search console_log.* for 'connect_validator' and $ip_address
        // using .* doesn't necessarily preserve order so do 1 by 1
        // ------------------------------------------------------------
        $escaped_ip_address = str_replace('.', '\.', $ip_address);
        $cmd = 'tac ' . $console_log . ' | grep -E "connect_validator.*' . $escaped_ip_address . '"';
        $i = 0;
        do {
            unset($cmd_output);
            $cmd_result = $this->run_command($cmd, $cmd_output);
            $cmd = sprintf('tac ' . $console_log . '.%d | grep -E "connect_validator.*%s"', $i, $escaped_ip_address);
            $i++;
        } while (6 > $i && 0 == sizeof($cmd_output));
        // --------------------------------------------------
        // Did we get a match?, if so pull out validator name
        // --------------------------------------------------
        if (0 < sizeof($cmd_output)) {
            $match_regex = '/^.+successfully connected to validator \"([a-zA-Z\-]+).*\"' . $escaped_ip_address . '\".*$/';
            $validator_name_match = preg_match($match_regex, $cmd_output[0], $matches);
            if ($validator_name_match) {
                $validator_name = $matches[1];
                $this->log_it(sprintf("tac_console_log returned validator name of %s \n", $validator_name));
            }
        }
        return $validator_name;
    }
    // -------------------------------------------------------------------------
    // run_command - run a unix shell command
    // $command - full command to run
    // $result = returns the call result_code
    // returns - text output by command as a array 1 element per line of output
    // -------------------------------------------------------------------------
    public function run_command($command, &$output) {
        $this->logger->log_it("Running command $command\n");
        exec($command, $output, $result);
        return $result;
    }
    // -----------------------------------------------
    // limit - limit value to: low <= $value <= $high
    // -----------------------------------------------
    private function limit($value, $low, $high) {
        if ($value < $low) {
            $value = $low;
        }
        if ($value > $high) {
            $value = $high;
        }
        return $value;
    }
    // ----------------------------------------------------------------
    // Logger interface - setup on instantiation. if null does nothing
    // ----------------------------------------------------------------
    private function log_it($logdata) {
        if (!is_null($this->logger)) {
            $this->logger->log_it($logdata);
        }
    }
} // end class unixUtils
// =======================================================
class miner {
    private $logger = null;
    // --------------------------------------
    // constructor
    // --------------------------------------
    public function __construct($logger) {
        if (!is_null($logger)) {
            $this->logger = $logger;
        }
    }
// -------------------------------------------------------
// geto_miner_key - returns miner key obtained from
// docker exec miner miner print_keys command
//[0] => {pubkey,"xxxxxxxxxxxxxxxxxxxxxxxxxxx"}.
//[1] => {onboarding_key,"xxxxxxxxxxxxxxxxxxxxxxxxxxx"}.
//[2] => {animal_name,"miner-name-here"}.
// valid miner_key to request are:
// 'pubkey','onboarding_key','animal_name'
// -------------------------------------------------------
    public function get_miner_key($unix_utils, $miner_key) {
        $result = false;
        $command = 'sudo docker exec miner miner print_keys';
        $command_result = $unix_utils->run_command($command, $command_output);
        foreach ($command_output as $index => $miner_data) {
            if (stristr($miner_data, $miner_key)) {

                // make miner_data into json_data format by replacing
                // ',' with ':' and removing trailing period
                // enclose key in quotes
                $matched_miner_data = str_replace(',', ':', $miner_data);
                $matched_miner_data = str_replace("$miner_key:", "\"$miner_key\":", $matched_miner_data);
                $matched_miner_data = substr($matched_miner_data, 0, -1);
                // decode json data to array, and extract value requested
                $search_key = json_decode($matched_miner_data, true);
                $result = $search_key[$miner_key];
                $this->logger->log_it(sprintf("docker exec miner miner print keys returned key '%s' has value '%s'\n", $miner_key, $result));
            }
        }
        return $result;
    }
    // ---------------------------------------------------------------------------
    // distance_between_points()
    // calculates distance between two points using Haversine Formula
    // https://en.wikipedia.org/wiki/Haversine_formula
    // source: https://www.geeksforgeeks.org/program-distance-two-points-earth
    // returns integer result in kilometers or miles depending on value of $in_km
    // ---------------------------------------------------------------------------
    public function distance_between_points( $latitudeFrom, $longitudeFrom,
                                             $latitudeTo, $longitudeTo, $in_km = true) {
        $long1 = deg2rad($longitudeFrom);
        $long2 = deg2rad($longitudeTo);
        $lat1 = deg2rad($latitudeFrom);
        $lat2 = deg2rad($latitudeTo);

        //Haversine Formula
        $dlong = $long2 - $long1;
        $dlati = $lat2 - $lat1;

        $val = pow(sin($dlati / 2), 2) + cos($lat1) * cos($lat2) * pow(sin($dlong / 2), 2);

        $res = 2 * asin(sqrt($val));

        $radius = 3958.756;
        $distance = $res * $radius;
        if ($in_km) {
            $distance *= 1.6093;
        }
        $distance = (int) round($distance, 0);
        return $distance;
    }
    // ----------------------------------------------
    // get_geo_ip_data_ipapi()
    // calls free service https://ipapi.co/api/#complete-location
    // Free up to 30000 queries a month
    // to get the following data:
    // -----------------------------------------
    public function get_geo_ip_data_ipapi($ip, $helium_api) {
        $result = false;
        //https://ipapi.co/8.8.8.8/json/
        if (filter_var($ip, FILTER_VALIDATE_IP)) {
            $url = "https://ipapi.co/$ip/json/";
            $curl_result = $helium_api->curl_call_api($url, false);
        }
        if ($curl_result) {
            $result_as_array = json_decode($curl_result, true);
            $result['ip_address'] = $result_as_array['ip'];
            $result['organisation'] = $result_as_array['org'];
            $result['asn'] = $result_as_array['asn'];
            $result['asn_link'] = 'https://dnschecker.org/asn-whois-lookup.php?query=' . $result_as_array['asn'];
            $result['country'] = $result_as_array['country_name'];
            $result['region'] = $result_as_array['region'];
            $result['city'] = $result_as_array['city'];
            $result['postal'] = $result_as_array['postal'];
            $result['latitude'] = $result_as_array['latitude'];
            $result['longitude'] = $result_as_array['longitude'];
        }
        return $result;
    }
    // ----------------------------------------------
    // get_geo_ip_data()
    // calls free service api.hackertarget.com
    // to get the following data:
    // IP Address: 192.168.0.0
    // Country: United States
    // State: New York
    // City: New York
    // Latitude: nn.nnnn
    // Longitude: -nn.nnnn
    // -----------------------------------------
    public function get_geo_ip_data($ip, $helium_api) {
        $result = false;
        //https://api.hackertarget.com/geoip/?q=216.127.154.1
        if (filter_var($ip, FILTER_VALIDATE_IP)) {
            $url = 'https://api.hackertarget.com/geoip/?q=' . $ip;
            $curl_result = $helium_api->curl_call_api($url, false);
        }
        if ($curl_result) {
            $ip_match = preg_match('/^IP Address: (.*)\nCountry: (.*)\nState: (.*)\nCity: (.*)\nLatitude: (.*)\nLongitude: (.*)$/', $curl_result, $matches);
            if ($ip_match) {
                $result['ip_address'] = $matches[1];
                $result['country'] = $matches[2];
                $result['region'] = $matches[3];
                $result['city'] = $matches[4];
                $result['latitude'] = $matches[5];
                $result['longitude'] = $matches[6];
            }
        }
        return $result;
    }

    // ----------------------------------------------------------------
    // Logger interface - setup on instantiation. if null does nothing
    // ----------------------------------------------------------------
    private function log_it($logdata) {
        if (!is_null($this->logger)) {
            $this->logger->log_it($logdata);
        }
    }
} // end class miner
// ------------------------------------------
//
// ------------------------------------------
function print_data($data, $title='') {
    if (!empty($title)) {
        echo "\n$title\n";
        echo str_repeat('-',strlen($title)) . "\n";
    }
    foreach ($data as $key => $value) {
        echo "$key: $value\n";
    }
    echo "\n";
}
$miner_longitude = false;
$miner_latitude = false;
$hotspot = false;
$validator = false;

$logger = new logger($find_log_filename);
$logger->log_it(sprintf("Starting Up: Version %d find_local_validator.service\n", $version));
$logger->close_log();
$logger->open_log($find_log_filename);
$helium_api = new heliumApi($logger);
$unix_utils = new unixUtils($logger);
$miner = new miner($logger);


// -----------------------------------------
// Get miner key so we can lookup lat/long
// try 3 times as docker times out at times
// -----------------------------------------
$tries = 0;
do {
    $miner_address_key = $miner->get_miner_key($unix_utils, 'pubkey');
    $tries++;
} while (!$miner_address_key && 3 > $tries);
// --------------------------------------------
// if have miner key, call helium
// 'hotspot for address' api to get miner info
// api can fail, so try up to 3 times
// --------------------------------------------
if ($miner_address_key) {
    $tries = 0;
    do {
        $miner_data = $helium_api->hotspot_for_address($miner_address_key);
    } while (!$miner_data && 3 > $tries);
    if ($miner_data) {
        $hotspot['ip_address'] = $miner_data['data']['ip_address_data'][0]['ip_address'];
        $hotspot['port'] = $miner_data['data']['ip_address_data'][0]['port'];
        $hotspot['address'] = $miner_address_key;
        $hotspot['longitude'] = $miner_data['data']['lng'];
        $hotspot['latitude'] = $miner_data['data']['lat'];
        $hotspot['status'] = $miner_data['data']['status']['online'];
        $hotspot['city'] = $miner_data['data']['geocode']['long_city'];
        $hotspot['state'] = $miner_data['data']['geocode']['long_state'];
        $hotspot['country'] = $miner_data['data']['geocode']['long_country'];
        print_data($hotspot, 'Hotspot Data');
    }
}

$validator_ip = $unix_utils->netstat_atn();
echo "Validator ip = $validator_ip\n";

if (filter_var($validator_ip, FILTER_VALIDATE_IP)) {
    echo "Pinging $validator_ip ... wait\n";
    $ping_time = $unix_utils->ping($validator_ip, 4, 4, $logger);
    if (0 < $ping_time) {
        echo "Average Ping Time = {$ping_time}ms\n";
    } else {
        echo "No response to ping requests from validator $validator_ip\n";
    }
    $validator_name = $unix_utils->tac_console_log($console_log_filename, $validator_ip);
    if ($validator_name) {
        $validator_name_std = ucwords(str_replace('-', ' ', $validator_name));
        echo "Validator Name:  $validator_name_std\n";
        $validator_data = $helium_api->validator_for_name($validator_name);
        // [version_heartbeat] => 10110000
        if ($validator_data) {
            $version_raw = $validator_data['data'][0]['version_heartbeat'];
            $major_version = (int) substr($version_raw, 0, 1);
            $minor_version = (int) substr($version_raw, 2, 2);
            $subversion = (int) substr($version_raw, 4, 4);
            $validator['address'] = $validator_data['data'][0]['address'];
            $validator['ip_address'] = $validator_data['data'][0]['ip_address_data'][0]['ip_address'];
            $validator['port'] = $validator_data['data'][0]['ip_address_data'][0]['port'];
            $validator['name'] = $validator_name;
            $validator['name_standard'] = $validator_name_std;
            $validator['owner'] = $validator_data['data'][0]['owner'];
            $validator['version'] = $major_version . '.' . $minor_version . '.' . $subversion;
            $validator['ping_time']  = $ping_time . 'ms';
            $validator['ping_time_raw']  = $ping_time;
            print_data($validator, 'Validator Data');
        }
    }
}
if ($hotspot && $validator) {
    $validator_geoip_data = $miner->get_geo_ip_data_ipapi($validator_ip, $helium_api);
    print_data($validator_geoip_data, 'Validator GeoIP Data');
    $distance = $miner->distance_between_points($hotspot['latitude'], $hotspot['longitude'],
        $validator_geoip_data['latitude'], $validator_geoip_data['longitude']);
    $validator['distance'] = $distance;
    $validator_geoip_data['distance'] = $distance;
    echo "Distance between hotspot and validator: {$distance}km Ping time: {$ping_time}ms Version: {$validator['version']}\n";
}
