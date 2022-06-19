<?php
// This file resides in dashboard at /var/dashboard/pages/cpu_temp.php
// requires: gd for php: sudo apt install php7.3-gd
// -------------------------------------------------------------------------------------------------
// tailCustom
// * Slightly modified version of http://www.geekality.net/2011/05/28/php-tail-tackling-large-files/
// * @author Torleif Berger, Lorenzo Stanco
// * @link http://stackoverflow.com/a/15025877/995958
// * @license http://creativecommons.org/licenses/by/3.0/
// -------------------------------------------------------------------------------------------------
function tailCustom($filepath, $lines = 1, $adaptive = true) {

    $result = false;
    // Open file
    $f = @fopen($filepath, "rb");

    if ($f !== false) {


        // Sets buffer size, according to the number of lines to retrieve.
        // This gives a performance boost when reading a few lines from the file.
        if (!$adaptive) {
            $buffer = 4096;
        } else {
            $buffer = ($lines < 2 ? 64 : ($lines < 10 ? 512 : 4096));
        }

        // Jump to last character
        fseek($f, -1, SEEK_END);

        // Read it and adjust line number if necessary
        // (Otherwise the result would be wrong if file doesn't end with a blank line)
        if (fread($f, 1) != "\n") {
            $lines -= 1;
        }

        // Start reading
        $output = '';
        $chunk = '';

        // While we would like more
        while (ftell($f) > 0 && $lines >= 0) {

            // Figure out how far back we should jump
            $seek = min(ftell($f), $buffer);

            // Do the jump (backwards, relative to where we are)
            fseek($f, -$seek, SEEK_CUR);

            // Read a chunk and prepend it to our output
            $output = ($chunk = fread($f, $seek)) . $output;

            // Jump back to where we started reading
            fseek($f, -strlen($chunk, '8bit'), SEEK_CUR);

            // Decrease our line counter
            $lines -= substr_count($chunk, "\n");

        }

        // While we have too many lines
        // (Because of buffer size we might have read too many)
        while ($lines++ < 0) {

            // Find first newline and remove all text before that
            $output = substr($output, strpos($output, "\n") + 1);

        }
        // Close file and return
        fclose($f);
        $result = trim($output);
    }
    return $result;

}

//Include the plot class
require_once 'includes/phplot.php';
define('FILENAME_CPU_TEMP_LOG', '/var/dashboard/logs/cpu-temp.log');
define('FILENAME_CPU_TEMP_HISTORY_LOG', '/var/dashboard/logs/cpu-temp-history.log');
define('CPU_LOG_LINES_PER_DAY', 96);
define('GRAPH_WIDTH_IN_PIXELS',1024);
define('GRAPH_HEIGHT_IN_PIXELS',769);
// Graph Data -- last 25 samples (about 6 hours 15 minutes)
$f = fopen(FILENAME_CPU_TEMP_LOG, 'r');
while ($row = fgetcsv($f, 4092)) {
    $data[] = array($row[2], $row[0]);
    $lastDate = $row[1];
}
fclose($f);
// High/Low and Average over last 24 HOURS
$historyData = explode("\n", tailCustom(FILENAME_CPU_TEMP_HISTORY_LOG, CPU_LOG_LINES_PER_DAY, $adaptive = true));
$tempSum = 0;
$highTemp = null;
$highDate = '';
$lowTemp = null;
$lowDate = '';
foreach ($historyData as $key => $value) {
    $row = explode(',', $value);
    $thisTemp = str_replace('.', '', $row[0]);
    $tempSum += str_replace('.', '', $thisTemp);
    if (is_null($highTemp) || ($highTemp <= $thisTemp)) {
        $highTemp = $thisTemp;
        $highDate = date('Y-m-d', strtotime($row[1])) . ' ' . $row[2];
    }
    if (is_null($lowTemp) || ($lowTemp >= $thisTemp)) {
        $lowTemp = $thisTemp;
        $lowDate = date('Y-m-d', strtotime($row[1])) . ' ' . $row[2];
    }
}
$averageTemp = (float) $tempSum / count($historyData) / 10;
$highTemp = number_format($highTemp / 10, 1);
$lowTemp = number_format($lowTemp / 10, 1);
// get our plotter setup
$plot = new PHPlot(GRAPH_WIDTH_IN_PIXELS, GRAPH_HEIGHT_IN_PIXELS);
//Set titles
$dateFormatted = date('Y-m-d', strtotime($lastDate));
$title = "CPU Temp over Time\n" .
    "Ending on $dateFormatted\n" .
    "24 Hr Avg: " . number_format($averageTemp, 2) . "'C\n" .
    "24 Hr High: $highTemp'C @ $highDate\n24 Hr Low: $lowTemp'C @ $lowDate";
$plot->SetTitle($title);
$plot->SetXTitle('Time');
$plot->SetYTitle('Temp C');
//Define some data

$plot->SetTransparentColor('grey');
$plot->SetDataColors('black'); // Use same color for all data sets
$plot->SetDrawPlotAreaBackground(True);
$plot->SetBackgroundColor('grey');
$plot->SetDataValues($data);
//$plot->SetYDataLabelPos('plotin');
$plot->SetXLabelAngle(90);
//Turn off X axis ticks and labels because they get in the way:
$plot->SetXTickLabelPos('none');
$plot->SetXTickPos('none');
$plot->SetPlotBgColor('grey');
$plot->SetLightGridColor('white');
//Draw it
$plot->DrawGraph();
