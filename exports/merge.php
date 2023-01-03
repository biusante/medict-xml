<?php

$jen = tsv_map(__DIR__ . '/01686.tsv');
$jfr = tsv_map(__DIR__ . '/00216.tsv');


$nome = array_keys(array_merge($jfr, $jen));
sort($nome, SORT_LOCALE_STRING);

echo "entrée\tJames EN\tJames FR\n";

foreach($nome as $w) {
    echo $w;
    echo "\t";
    if (isset($jen[$w])) {
        if ($jen[$w] > 1) echo $jen[$w];
        else echo 1;
    }
    echo "\t";
    if (isset($jfr[$w])) {
        if ($jfr[$w] > 1) echo $jfr[$w];
        else echo 1;
    }
    echo "\n";
}

/**
 * Build a map from tsv file where first col is the key.
 */
function tsv_map($file, $sep = "\t")
{

    $ret = array();
    $handle = fopen($file, "r");
    if (!$handle) {
        throw new Exception("$file impossible to open");
    }
    $n = 0;
    while (($data = fgetcsv($handle, 0, $sep)) !== FALSE) {
        $n++;
        if (!$data || !count($data) || !$data[0]) {
            continue; // empty lines
        }
        // comment
        if (substr(trim($data[0]), 0, 1) === '#') {
            continue;
        }
        /* Log ?
        if (isset($ret[$data[0]])) {
            echo $tsvfile,'#',$l,' not unique key:', $data[0], "\n";
        }
        */
        if (!isset($data[1])) {  // shall we log for user
            continue;
        }

        $ret[stripslashes($data[0])] = stripslashes($data[1]);
    }
    fclose($handle);
    return $ret;
}
