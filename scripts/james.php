<?php declare(strict_types=1);

include_once(dirname(__DIR__, 2) . '/teinte_php/vendor/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Filesys, Log, LoggerCli, Parse};
use Oeuvres\Teinte\Format\{Docx};

Log::setLogger(new LoggerCli(LogLevel::DEBUG));



$preg = Parse::pcre_tsv(__DIR__ . '/jamesfr_norm.tsv');
$dst_dir = dirname(__DIR__) . '/work/';
Filesys::mkdir($dst_dir);
$glob = dirname(__DIR__) . '/xml/medict00216x??.xml';
foreach (glob($glob) as $src_tei) {
    $dst_tei = $dst_dir . basename($src_tei);
    $xml = file_get_contents($src_tei);
    $xml = preg_replace($preg[0], $preg[1], $xml);
    file_put_contents($dst_tei, $xml);
}


function docx_tei()
{
    $source = new Docx();
    $source->template(__DIR__);

    $glob = dirname(__DIR__) . '/jamesen-docx/*.docx';
    $dst_dir = dirname(__DIR__) . '/jamesen-docx/';
    foreach (glob($glob) as $docx_file) {
        $src_name = pathinfo($docx_file, PATHINFO_FILENAME);
        $dst_file = $dst_dir . $src_name . ".xml";
        Log::info($dst_file);
        $source->load($docx_file);
        $source->tei();
        file_put_contents($dst_file, $source->xml());
    }
}