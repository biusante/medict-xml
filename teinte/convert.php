<?php declare(strict_types=1);

include_once(dirname(__DIR__, 2) . '/teinte_php/vendor/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Filesys, Log, LoggerCli};
use Oeuvres\Teinte\Format\{Docx};

Log::setLogger(new LoggerCli(LogLevel::DEBUG));
$source = new Docx();
$source->template(__DIR__);

$glob = dirname(__DIR__) . '/jamesfr-docx/*.docx';
$dst_dir = dirname(__DIR__) . '/jamesfr-docx/';
foreach (glob($glob) as $docx_file) {
    $src_name = pathinfo($docx_file, PATHINFO_FILENAME);
    $dst_file = $dst_dir . $src_name . ".xml";
    Log::info($dst_file);
    $source->load($docx_file);
    $source->tei();
    file_put_contents($dst_file, $source->xml());
}

