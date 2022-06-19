#!/usr/bin/php
<?php
// Crontab:
// */15 * * * * / /var/dashboard/services/log-cpu-temp.php
define('MAX_CPU_TEMP_RECORDS',96); // in 'daily' file, there is a permanent file too
define('FILENAME_CPU_TEMP_LOG','/var/dashboard/logs/cpu-temp.log');
define('FILENAME_CPU_TEMP_HISTORY_LOG','/var/dashboard/logs/cpu-temp-history.log');

if (!$f = fopen(FILENAME_CPU_TEMP_LOG, 'r')) {
            error_log('1. PHP Error in dashboard processing. Cannot open file for reading (check permissions). Script: ' . $_SERVER['PHP_SELF'] . ' File: ' . FILENAME_CPU_TEMP_LOG);
        exit;
    }
$data = array();
while ($str = fgets($f)) {
    $data[] = $str;
}
fclose($f);
// remove entries from log that are over our retention count
$deleteCount = count($data) - MAX_CPU_TEMP_RECORDS + 1;
for ($i=0;$i < $deleteCount; $i++) {
    unset($data[$i]);
}
exec('vcgencmd measure_temp', $output, $returnVal);
$temp = preg_match('/temp\=([0-9]*\.[0-9]*).*/', $output[0], $match);
$logData[0] = $match[1];
$logData[1] = date('Y-m-d');
$logData[2] = date('H:i');
if (is_writable(FILENAME_CPU_TEMP_LOG)) {
    if (!$f = fopen(FILENAME_CPU_TEMP_LOG, 'w')) {
        error_log('2. PHP Error in dashboard processing. Cannot open file (check permissions). Script: ' . $_SERVER['PHP_SELF'] . ' File: ' . FILENAME_CPU_TEMP_LOG);
        exit;
    }
    // write old data (less trimmed off old data)
    foreach ($data as $rowNum => $dataValues) {
        fwrite($f,$dataValues);
    }
    // write our new temp,data,time data set
    fputcsv($f, $logData);
    fclose($f);
} else {
    error_log('3. PHP Error in dashboard processing. File is not writeable (check permissions). Script: ' . $_SERVER['PHP_SELF'] . ' File: ' . FILENAME_CPU_TEMP_LOG);
}
// Write to permanent history log
if (is_writable(FILENAME_CPU_TEMP_HISTORY_LOG)) {
    $f = fopen(FILENAME_CPU_TEMP_HISTORY_LOG, 'a');
    fputcsv($f, $logData);
    fclose($f);
} else {
    error_log('4. PHP Error in dashboard processing. File is not writeable (check permissions). Script: ' . $_SERVER['PHP_SELF'] . ' File: ' . FILENAME_CPU_TEMP_HISTORY_LOG);
}
