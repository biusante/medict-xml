<?php
/**
 * Part of Medict https://github.com/biusante/medict_xml
 * Copyright (c) 2021 Université de Paris, BIU Santé
 * MIT License https://opensource.org/licenses/mit-license.php
 */

declare(strict_types=1);


// liste des fichiers finalisés
$tei_files = [
    "medict00152.xml",
    "medict00216x01.xml",
    "medict00216x02.xml",
    "medict00216x03.xml",
    "medict00216x04.xml",
    "medict00216x05.xml",
    "medict00216x06.xml",
    // "medict00216x06~matieres.xml",
    // "medict00216x06~planches.xml",
    // "medict01686x01.xml",
    // "medict01686x02.xml",
    // "medict01686x03.xml",
    "medict07399.xml",
    "medict27898.xml",
    "medict37019.xml",
    "medict37020d.xml",
    "medict37020d~deu.xml",
    "medict37020d~eng.xml",
    "medict37020d~grc.xml",
    "medict37020d~ita.xml",
    "medict37020d~lat.xml",
    "medict37020d~spa.xml",
    "medict61157.xml",
];

Medict::init();
foreach ($tei_files as $basename) {
    Medict::tei_tsv($basename);
}

class Medict {
    static  $proc;

    public static function init()
    {
        libxml_use_internal_errors(true); // keep XML error for this process
        $xsl = new DOMDocument;
        $xsl->load(__DIR__ . '/medict_tei_tsv.xsl');
        self::$proc = new XSLTProcessor;
        self::$proc->importStyleSheet($xsl);
    }

    public static function tei_tsv($tei_file)
    {
        $tei_name = pathinfo($tei_file, PATHINFO_FILENAME);
        $tei_name = preg_replace('@^medict@', '', $tei_name);
        echo "Transform " . $tei_name;
        // XML -> tsv, suite plate d’événements pour l’insertion
        $xml = new DOMDocument;
        // avoid 
        $xml->load(__DIR__ . '/xml/' .$tei_file);
        self::libxml_log(libxml_get_errors());
        $tsv = self::$proc->transformToXML($xml);

        $dst_file = __DIR__ . '/build_tsv/' . $tei_name.'.tsv';
        if (!file_exists(dirname($dst_file))) mkdir(dirname($dst_file), 0777, true);

        file_put_contents($dst_file, $tsv);
        echo " => " . $dst_file . "\n";
    }

    /**
     * Output the relevant libxml messages
     */
    public static function libxml_log(array $errors)
    {
        foreach ($errors as $error) {
            $message = "";
            if ($error->file) {
                $message .= $error->file;
            }
            $message .= "  " . ($error->line) . ":" . ($error->column) . " \t";
            $message .= "err:" . $error->code . " — ";
            $message .= trim($error->message);
            /* xslt error could be other than message
            if ($error->code == 1) { // <xsl:message>
                Log::info("<xsl:message> " . trim($error->message));
            } */
            
            if ($error->level == LIBXML_ERR_WARNING) {
                // strip warnings 
            } else if (strpos($message, "err:513 — ID") !== false) {
                // strip warnings for repeated ids
            } else if ($error->level == LIBXML_ERR_ERROR) {
                echo $message . "\n";
            } else if ($error->level ==  LIBXML_ERR_FATAL) {
                echo $message . "\n";
            }
        }
        libxml_clear_errors();
    }
}
