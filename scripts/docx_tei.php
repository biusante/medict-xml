<?php declare(strict_types=1);

include_once(dirname(__DIR__, 2) . '/teinte_php/vendor/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Filesys, Log, LoggerCli, Parse};
use Oeuvres\Teinte\Format\{Docx};

Log::setLogger(new LoggerCli(LogLevel::DEBUG));



function capuron_docx($docx_file)
{
    // $docx_file = dirname(__DIR__) . '/work/capuron_docx/capuron_p86.docx';
    
    $docx = new Docx();
    $docx->user_template(__DIR__ . "/tmpl.xml");
    
    $dst_dir = dirname(__DIR__) . '/xml/';
    Filesys::mkdir($dst_dir);
    
    $src_name = pathinfo($docx_file, PATHINFO_FILENAME);

    Log::info('Load: ' . $docx_file);
    $docx->load($docx_file);
    // for debug
    $docx->pkg();
    $docx->teilike();
    Log::info('docx -> “tei like”');
    $docx->pcre();
    // file_put_contents($dst_dir . $src_name . "_pcre.xml", $source->xml());
    $docx->tmpl();
    Log::info('“tei like” -> pcre');

    $dst_file = $dst_dir . $src_name . ".xml";
    Log::info('Generate: ' . $dst_file);
    $xml = $docx->xml();
    $preg = Parse::pcre_tsv(__DIR__ . '/capuron_pcre.tsv');
    $xml = preg_replace($preg[0], $preg[1], $xml);

    file_put_contents($dst_file, $xml);
}

function begin_norm()
{
    $src_file = dirname(__DIR__) . '/work/medict61157.xml';

    $preg = Parse::pcre_tsv(__DIR__ . '/begin_pcre.tsv');

    $xml = file_get_contents($src_file);
    $xml = preg_replace($preg[0], $preg[1], $xml);

    $dst_file = dirname(__DIR__) . '/xml/medict61157.xml';
    file_put_contents($dst_file, $xml);
}

function tei_norm()
{
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
}

function james()
{
    $source = new Docx();
    $source->template(__DIR__);

    $glob = dirname(__DIR__) . '/jamesen-docx/*x01_8*.docx';
    $dst_dir = dirname(__DIR__) . '/jamesen-docx/';
    foreach (glob($glob) as $docx_file) {
        $src_name = pathinfo($docx_file, PATHINFO_FILENAME);
        $dst_file = $dst_dir . $src_name . ".xml";
        Log::info($dst_file);
        $source->load($docx_file);
        $source->tei();
        Log::info("done");
        file_put_contents($dst_file, $source->xml());
    }
}