<?php
mb_internal_encoding("UTF-8");
/**
 * Différents outils de restructuration des fichiers après conversion docx > TEI
 */

 /*
$xml_file = dirname(__DIR__) . '/xml/medict37019.xml';
$xml = Tagger::orth_norm($xml_file);
file_put_contents($xml_file, $xml);
*/
Tagger::orth_diff('37019');
exit();



// Tagger::facs(dirname(__DIR__) . "/xml/medict00216x06.xml", "00216x06", 2);

/* James authors

<persName>BLANCARD</persName>
<persName>BOERHAAVE</persName>
<persName>CASTELLI</persName>
<persName>COWPER</persName>
<persName>DALE</persName>
<persName>DIOSCORIDE</persName>
<persName>FŒSIUS</persName>
<persName>GALIEN</persName>
<persName>GEOFFROY</persName>
<persName>GORRÆUS</persName>
<persName>HIPPOCRATE</persName>
<persName>HOFFMAN, F.</persName>
<persName>JOHNSON</persName>
<persName>LEMERY</persName>
<persName>PARACELSE</persName>
<persName>RULAND</persName>
<persName>TOURNEFORT</persName>
<persName>WINSLOW</persName>

*/

class Tagger
{
    public static $HOME;
    static function init()
    {
        $path = dirname(dirname(__FILE__)) . '/';
        self::$HOME = $path;
    }

    /** filepath */
    private $_src;
    /** XML string */
    private $_xml;
    /** TEI/XML DOM Document to process */
    private $_dom;
    /** Xpath processor */
    private $_xpath;
    /** filename without extension */
    private $_filename;
    /** file freshness */
    private $_filemtime;
    /** file size */
    private $_filesize;


    /**
     * Constructor, load a file and prepare work
     */
    public function __construct($src, $logger = null)
    {
        $this->_logger = $logger;
        $this->_xml = file_get_contents($src);
        $this->_src = $src;
        $this->_filemtime = filemtime($src);
        $this->_filesize = filesize($src); // ?? URL ?
        $this->_filename = pathinfo($src, PATHINFO_FILENAME);
        $this->_dom = Build::dom($src);
        // loading error, do something ?
        if (!$this->_dom) throw new Exception("BAD XML");
        $this->_xpath = Build::xpath($this->_dom);
    }

    /**
     * ajouter des ids
     */
    public function ids()
    {
        return Build::transformDoc($this->_dom, dirname(__FILE__) . '/idref.xsl');
    }

    public static function prefix($file, $tag)
    {
        $pattern = '@([\p{L}]+\.?) *'. $tag .'@u';
        $subject = file_get_contents($file);
        preg_match_all($pattern, $subject, $matches);
        $found = $matches[1];
        $found = array_count_values($found);
        arsort($found);
        return $found;
    }

    public static function orth_norm($file)
    {
        $xml = file_get_contents($file);
        $xml = preg_replace_callback(
            '/<orth>(.)([^<]+)/u',
            function($matches) {
                $orth = 
                  mb_convert_case($matches[1], MB_CASE_UPPER)
                . mb_convert_case($matches[2], MB_CASE_LOWER);
                $orth = Normalizer::normalize($orth);
                return "<orth>" . $orth;
            },
            $xml
        );
        return $xml;
    }

    /**
     * Cette méthode doit être identique à celle utilisée à l’indexation
     */
    public static function deform($s)
    {
        $s = trim($s);
        // bas de casse
        $s = mb_convert_case($s, MB_CASE_FOLD, "UTF-8");
        // décomposer lettres et accents
        $s = Normalizer::normalize($s, Normalizer::FORM_D);
        // ne conserver que les lettres et les espaces, et les traits d’union
        $s = preg_replace("/[^\p{L}\-\s]/u", '', $s);
        // ligatures
        $s = strtr(
            $s,
            array(
                'œ' => 'oe',
                'æ' => 'ae',
                '’' => "'",
            )
        );
        // normaliser les espaces
        $s = preg_replace('/[\s\-]+/', ' ', trim($s));
        return $s;
    }

    static $orth_tr = [
        "Α" => "A",
        "À" => "A",
        "Λ" => "A",
        "λ" => "A",
        "α" => "A",
        "Β" => "B", // grc
        "β" => "B",
        "Ε" => "E",
        "ε" => "E",
        "έ" => "É",
        "Η" => "H", // gr 
        "η" => "H",
        "ι" => "I",
        "Ι" => "I",
        "1" => "I",
        "l" => "L",
        "Î" => "I",
        "t" => "I",
        "Κ" => "K", // grc
        "Μ" => "M", // gr
        "μ" => "M",
        "ν" => "N",
        "Ν" => "N",
        "\u039F" => "O", // gr
        "ο" => "O",
        "0" => "O",
        "Ρ" => "P", // gr
        "ρ" => "P",
        "κ" => "R",
        "8" => "S",
        "τ" => "T",
        "Τ" => "T",
        "Γ" => "T",
        "υ" => "U",
        "ü" => "U",
        "Χ" => "X", // grc
        "χ" => "X",
        "Υ" => "Y", // grc
        "γ" => "Y",
        "Ζ" => "Z", // grc
        "ζ" => "Z",
    ];

    public static function orth_clean($cote)
    {
        $xml_file = dirname(__DIR__)."/xml/medict$cote.xml";
        $xml = file_get_contents($xml_file);
        $re_callback = array(
            '@<orth[^>]*>([^<]+)</orth>@' => function ($matches) 
            {
                $orth = $matches[1];
                return ''
                 . '<orth>' 
                 // . strtr($matches[1], self::$orth_tr)
                 . mb_strtoupper(mb_substr($orth, 0, 1))
                 . '</orth>';
            }
        );
        $xml = preg_replace_callback_array($re_callback, $xml);
        file_put_contents($xml_file, $xml);

    }

    /**
     * Charger une nomenclature d’un fichier tsv
     */
    public static function tsv_orths($tsv_file)
    {
        $handle = fopen($tsv_file, "r");
        $forms = [];
        $entry = null;
        while (($row = fgetcsv($handle, null, "\t")) !== FALSE) {
            $command = $row[0];
            if ($command == 'entry') {
                // insert last entry if no form found before
                if ($entry) {
                    $forms[] = $entry;
                } 
                $entry = $row[1];
            }
            else if ($command == 'orth') {
                $entry = null;
                $form[] = $row[1];
            }
        }
        return $forms;
    }

    /**
     * Comparer avec l’ancienne indexation
     */
    public static function orth_old($cote)
    {
        $src_file = dirname(__DIR__)."/xml/medict$cote.xml";
        $xml = file_get_contents($src_file);
        // keep original
        $orths = self::tsv_orths(__DIR__ . "/$cote.tsv", "r");
        $forms = array_flip($orths);
        /*
        $deforms = [];
        foreach($orths as $f) {
            $deforms[self::deform($f)] = $f;
        }
        */
        $n = 0;
        $re_callback = array(
            '@<orth[^>]*>([^<]+)</orth>@' => function ($matches) 
            use (&$forms, &$orths, &$n) {
                $form = $matches[1];
                if (isset($forms[$form])) {
                    $n = $forms[$form];
                    return  '<orth>' . $form . '</orth>';
                }
                $n++;
                $ret = '';
                if (isset($orths[$n])) $ret .= '<!--' . $orths[$n] . '-->';
                $ret .= '<orth>' . $form . '</orth>';
                return $ret;


                /*
                $deform = self::deform($form);
                if (isset($deforms[$deform])) {
                    return  '<orth>' . $deforms[$deform]. '</orth>';
                }
                */
                /*
                $targets = [];
                echo $form;
                foreach($orths as $orth) {
                    $lev = levenshtein($form, $orth);  
                    if ($lev > 2) continue;
                    $targets[] = $orth;
                    echo ", $orth $lev";
                }
                echo "\n";
                if (count($targets) == 1) {
                    return "<!--" . $targets[0] . "-->" . "<orth>" . $form  . "</orth>"; 
                }
                */
            }
        );
        $xml = preg_replace_callback_array($re_callback, $xml);
        file_put_contents($src_file, $xml);
        
        /*
        echo "\n== NOT FOUND ==\n\n";
        // AE > Æ
        $notfound = implode("|", array_keys($notfound));
        $notfound = strtr(
            $notfound,
            array(
                'oe' => 'œ',
                'ae' => 'æ',
                ' ' => '[ \-]'
            )
        );
        $notfound = mb_strtoupper($notfound, "UTF-8");
        echo $notfound;
        */
    }

        /**
     * Comparer avec l’ancienne indexation
     */
    public static function ref($cote)
    {
        $xml_file = dirname(__DIR__)."/xml/medict$cote.xml";
        $xml = file_get_contents($xml_file);
        $deform = [];
        $form = [];
        // load <orth>
        preg_replace_callback(
            '@<orth>(.+?)</orth>@',
            function ($matches) 
            use (&$form, &$deform) {
                $form[$matches[1]] = true;
                $key = preg_replace('@</?[^>]+>@', '', $matches[1]);
                $key = self::deform($key);
                $deform[$key] = $matches[1];
            },
            $xml
        );
        // work <ref>
        $xml = preg_replace_callback(
            '@<ref>(.+?)</ref>@',
            function ($matches) 
            use (&$form, &$deform) {
                if (isset($form[$matches[1]])) {
                    return $matches[0];
                }
                $key = preg_replace('@</?[^>]+>@', '', $matches[1]);
                $key = self::deform($key);
                if (isset($deform[$key])) {
                    $ret = "<ref>" . $deform[$key] . "</ref>";
                    // echo $ret . "\n";
                    return $ret;
                }
                $input =  mb_strtoupper($matches[1], "UTF-8") ;
                echo $input;
                $targets = [];
                foreach($form as $word => $v) {
                    $lev = levenshtein($input, $word);  
                    if ($lev > 2) continue;
                    $targets[] = $word;
                    echo ", $word $lev";
                }
                echo "\n";
                if (count($targets) == 1) {
                    // return "<ref>" . $targets[0] . "</ref>"; 
                }
                return "<ref>" . $input . "</ref>";
            },
            $xml
        );
        file_put_contents($xml_file, $xml);
    }
    /**
     * Comparer avec l’ancienne indexation
     */
    public static function orth_diff($cote)
    {
        $xml_file = dirname(__DIR__)."/xml/medict$cote.xml";
        $xml = file_get_contents($xml_file);
        $orths = self::tsv_orths(__DIR__ . "/$cote.tsv", "r");
        $old = array_flip($orths);
        $new = [];
        $re_callback = array(
            '@<orth[^>]*>(.+?)</orth>@' => function ($matches) 
            use (&$old, &$new, &$orths) {
                $key = $matches[1];
                // $key = preg_replace('@</?[^>]+>@', '', $matches[1]);
                // $key = self::deform($key);
                if (isset($old[$key])) {
                    unset($old[$key]);
                }
                else {
                    // echo $key . " " . array_search($key, $orths) . "\n";
                    $new[] = $matches[1];
                }
                return $matches[0];
            }
        );
        $xml = preg_replace_callback_array($re_callback, $xml);
        // merge not found in old with new, and sort
        $old = array_flip($old);
        $tsv = "Indexation\tVedette";
        $tsv .= "\nAnaïs\t";
        $tsv .= implode("\nAnaïs\t", $old);
        $tsv .= "\nXML/TEI\t";
        $tsv .= implode("\nXML/TEI\t", $new);

        // $merge = array_merge(array_values($old), $new);
        file_put_contents($cote . "_diff.tsv", $tsv);
    }

    /**
     * Vérifier l’ordre alphabétique des entrées
     */
    public function orthalpha()
    {


        $last;
        $re_callback = array(
            '@<form><orth>([^<]+)</orth>@' => function ($matches) use (&$last) {
                // dégrecer
                $degrec = array(
                    'Α' => 'A',
                    'Β' => 'B',
                    'Ε' => 'E',
                    'Η' => 'H',
                    'Ι' => 'I',
                    'Κ' => 'K',
                    'Μ' => 'M',
                    'Ν' => 'N',
                    'Ο' => 'O',
                    'Ρ' => 'P',
                    'Τ' => 'T',
                    'Ζ' => 'Z',
                );
                $matches[1] = strtr($matches[1], $degrec);
                $orth = strtr($matches[1], array(
                    '-' => '',
                    ' ' => '',
                    '.' => '',
                    "'" => '',
                    '’' => '',
                    'Æ' => 'AE',
                    'Â' => 'A',
                    'À' => 'A',
                    'Ç' => 'C',
                    'É' => 'E',
                    'È' => 'E',
                    'Ê' => 'E',
                    'Ë' => 'E',
                    'Ï' => 'I',
                    'Î' => 'I',
                    'Œ' => 'OE',
                    'Ô' => 'O',
                    'Û' => 'U',
                ));
                $ret = '<form><orth>' . $matches[1] . "</orth>";
                // peut être égal, ex : ABIÉTINE, ABIÉTINÉ
                if (strcmp($last, $orth) > 0) {
                    echo $matches[1] . "\t\t-" . $last . '- -' . $orth . '-   ' . strcmp($last, $orth) . "\n";
                    $ret = '<form><orth cert="low">' . $matches[1] . "</orth>";
                }
                $last = $orth;
                return $ret;
            },
        );
        $xml = preg_replace_callback_array($re_callback, $this->_xml);
        $dst = self::$HOME . "work/" . $this->_filename . ".xml";
        file_put_contents($dst, $xml);
    }



    /**
     * Insérer les no de pages
     */
    public static function pages($file)
    {
        $n = 0;
        $re_callback = array(
            '@<pb( n="(\d+)")?/>@u' => function ($matches) use (&$n) {
                $n++;
                $ret = "";
                if (isset($matches[2])) {
                    $val = 0 + $matches[2];
                    if ($n != $val) {
                        echo "found=" . $matches[0] . " calculate=" . $n . PHP_EOL;
                        $ret .= "<!-- page error " . $n . "!=" . $val . " -->";
                        $n = $val;
                    }
                }
                $ret = '<pb n="' . sprintf('%04d', $n) . '"/>';
                return $ret;
            },
        );
        $xml = file_get_contents($file);
        $xml = preg_replace_callback_array($re_callback, $xml);
        file_put_contents($file, $xml);
    }

    /**
     * Ajouter des url au no de page vérifiés 
     */
    public static function facs($file, $cote, $delta)
    {
        $xml = file_get_contents($file);
        $re_callback = array(
            '@<pb n="(\d+)"/>@u' => function ($matches) use ($cote, $delta) {
                $refimg = sprintf('%04d', $delta + 1 + ($matches[1]-1) / 2); // ! james FR cols
                $ret = '<pb n="' . $matches[1] . '"
    facs="https://www.biusante.parisdescartes.fr/iiif/2/bibnum:' . $cote . ':' . $refimg . '/full/full/0/default.jpg"
    corresp="https://www.biusante.parisdescartes.fr/histmed/medica/page?' . $cote . '&amp;p=' . $refimg . '"/>';
                return $ret;
            },
        );
        $xml = preg_replace_callback_array($re_callback, $xml);
        file_put_contents($file, $xml);
    }
}


function rewrite1()
{

    $re1 = array(
        // '@<teiHeader>.*?</teiHeader>@su' => "",
        "@­@u" => "", // trait d’union invisible
        "@ xml:lang=\"[^\"]+\"@u" => "",
        '@\n<lb type="line"/>@u' => '', // lignes vides
        '@<space rend="tab">    </space>@u' => '', //
        '@<seg rend="texteducorps">(.*)</seg>@' => '$1', // scorie
        '@^.*?<body>@su' => "",
        '@</body>.*?$@su' => "",
        '@<p rend=".*?">@u' => "<p>", // supprimer le rendu de para
        '@ *&lt; *</(hi|emph)>@u' => "</$1>", // bruit
        '@\[[Pp][\. ]*(\d+)[ \.]*\]@u' => '<pb n="$1"/>', // page
        '@<p>(<pb n="\d+"/>)</p>@u' => '$1',
        '@\[[fF][iî]g[\. ]*(\d+)[ \.]*\]@u' => '<graphic n="$1"/>', // figure
        '@<p>(<graphic[^>]*/>)</p>@u' => '$1',
        '@<hi rend="sup">;</hi>@u' => "’",
        '@<hi rend="sup">([1-9]+)[Oo]@u' => '<hi rend="sup">${1}0',
        '@<hi rend="sup">[Oo]([1-9]+)</hi>@u' => '<hi rend="sup">0$1</hi>',
        '@<hi rend="sup">([1-9]+)[S]@u' => '<hi rend="sup">${1}5',
        '@<hi rend="sup">m,n</hi>@u' => '<hi rend="sup">mm</hi>',
        '@([0-9])<hi rend="sup">u</hi>@u' => '$1°',
        '@([A-Z])<hi rend="sup">,@u' => '$1<hi rend="sup">1',
        '@([A-Z])<hi rend="sup">(l0|lo)</hi>@u' => '$1<hi rend="sup">10</hi>',
        '@<hi rend="sup">ί@u' => '<hi rend="sup">1',
        '@([A-Z])<hi rend="sup">(U|π|n|il)</hi>@u' => '$1<hi rend="sup">11</hi>',
        '@(\p{Lu})ü(\p{Lu})@u' => "$1U$2",
        '@(\p{Lu})1(\p{Lu})@u' => "$1I$2",
        '@(\p{Lu})—(\p{Lu})@u' => "$1-$2",
        '@S\. m\.@u' => "s. m.", // substantif masculin
        '@adj,@u' => "adj.", // adjectif
        '@ail\. @u' => "all. ",
        '@—[  ]*(\d+)@u' => "-$1", // tirets -15
        '@<hi rend="sup">[z]</hi>—@u' => "’-", // P<hi rend="sup">z</hi>—<emph>p</emph>
        '@<emph>([^\n<\[\]\{\}\(\)]+)([\[\]\{\}\(\)\.;]+)([^\n<]+)</emph>@u' => "<emph>$1</emph>$2<emph>$3</emph>", // sortir les ponctuations enclosantes de l’italique
        '@<emph>([^\n<\[\]\{\}\(\)]+)([\[\]\{\}\(\)\.;]+)([^\n<]+)</emph>@u' => "<emph>$1</emph>$2<emph>$3</emph>", // sortir les ponctuations enclosantes de l’italique
        '@([\.,\]\[\(\) }—\- =]+)</(hi|emph|orth)>@u' => "</$2>$1", // sortir après balise
        '@<(emph|hi|orth)>([\[(—  =]+)@u' => "$2<$1>", // sortir avant balise
        '@<emph>( *<hi rend="sc">[^<\n]+</hi> *)@u' => "$1<emph>", // les petites caps ne sont pas en italique
        "@[ ']+[XNVY][\. ]+</emph> *@u" => '</emph> V. ', // V.
        '@<hi rend="sc">[VNY]\. *@u' => 'V. <hi rend="sc">', // V.
        '@[N]\. *<hi rend="sc"> *@u' => 'V. <hi rend="sc">', // V.
        '@<emph>([^\pL]*)</emph>@u' => "$1", // nettoyer l’italique vide (fin <emph>)
        '@<hi rend="[^"]+">([^\pL]*)</hi>@u' => "$1", // typo vide
        '@<emph>(\p{L}[’\'·]?)</emph>@u' => "$1", // tant pis pour l’italique sur une lettre dans les formules
        // '@ ([A-Za-z][’\']?)[  ]?—[  ]?([A-Za-z]) @u' => " $1-$2 ", // tirets moins P'-p
        // '@\[([A-Za-z])\]@u' => "($1)", // légende
        '@■@u' => "", // cacographie apparement insignifiante
        '@—·@u' => "—", // cas rare ?
        // '@<hi rend="b">([^<]+)</hi>@u' => "<orth>$1</orth>",
        // */
    );

    $re_callback2 = array(
        '@<hi rend="sup">([0-9egrm]+)</hi>@u' => function ($matches) {
            $s = $matches[1];
            $s = str_replace(
                array('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'e', 'g', 'm', 'n', 'r'),
                array('⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹', 'ᵉ', 'ᵍ', 'ᵐ', 'ⁿ', 'ʳ'),
                $s
            );
            return $s;
        },
        '@<hi rend="sub">([0-9aemnr]+)</hi>@u' => function ($matches) {
            $s = $matches[1];
            $s = str_replace(
                array('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'e', 'm', 'n', 'r'),
                array('₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉', 'ₐ', 'ₑ', 'ₘ', 'ₙ', 'ᵣ'),
                $s
            );
            return $s;
        },

    );

    $re3 = array(

        /*
    // '@<p rend="lmarg1">(.*?)</p>@u' => "<list>$1</list>", // noise
    '@<p rend="[^"]*legendedelimage[^"]*">(.*?)</p>@u' => "<figDesc>$1</figDesc>", // Légende
    // '@<emph>([^<\n]+)(<hi rend="sc">[^<\n]+</hi>)@u' => "<emph>$1</emph>$2<emph>",// <emph>— Turbith nitreux. <hi rend="sc">N. Azotate</hi> de potasse. — Vapeurs nitreuses. N.</emph>
    '@<orth>([-\p{Lu}]+)([^\n\p{Lu}<]+)@u' => "<orth>$1</orth>$2<orth>", // <p><hi rend="b">NAPIFORME. adj. V. NAPACÉ.</hi></p>
    // '@<seg rend="texteducorps">([^<\n]+)</seg>@u' => "$1", // reste
    // "@-\n<lb/>@u" => "", // ?? bug
    // "@\n<lb/>@u" => " ", // ?? bug
    '@(\pL)\n (\pL)@u' => "$1 $2", // sauts de ligne bizarres
    '@([ \.\p{Ll}]*)V</orth>\.@u' => "</orth>$1V.", // <hi rend="b">CROCIDISME, ou CROCYDISME. S. m. V.</hi>
    // '@ *V\. (\p{Lu}+)</orth>@u' => "</orth> V. <ref>$1</ref>", // <p><hi rend="b">NAPIFORME. adj. V. NAPACÉ.</hi></p>
    '@ *[NyY]</emph>. (<hi rend="sc">|<orth>)@u' => "</emph> V. $1",
    '@([\.,\[\]\(\) }— =]+)</(emph)>@u' => "</$2>$1", // renettoyer les <emph> créés
    '@<(emph|orth)>([^\pL\n]*?)</\1>@u' => "$2", // nettoyer des balises vides


    // Sauts de lignes qui peuvent casser des balises

    '@(<orth>[^\[\n]*?)(adj\. et s\. f\.|s. f. et adj.|adj\. et s\. m\.|adj\.|s\. f\.|[s]\. m\.)@u' => "\n<form>$1$2</form>", // saut de ligne autour de la vedette
    '@(<emph>[^<]+)(</form>)@u' => "$1</emph>$2", // italique cassé dans la vedette
    '@(</form>) *(\[[^\]\n]+?)(\]\.?|\}\.|\)\.)@u' => "$1\n<dictScrap>$2].</dictScrap>\n    ", // saut de ligne après l’étymologie
    '@(<emph>[^<]+)(\]\.</dictScrap>)@u' => "$1</emph>$2", // italique cassé dans l’étymologie
    '@<emph>([^<\n]+) *<dictScrap>\[([^<\n]+)</emph>@u' => "<emph>$1</emph> <dictScrap>[<emph>$2</emph>", // italique cassé dans l’étymologie
    '@<dictScrap>\[([^<\n]+)</emph>@u' => "<dictScrap>[<emph>$1</emph>", // italique cassé dans l’étymologie
    '@ *—[  ]*@u' => "\n    — ", // normalisation des tirets
    '@ *=+[  ]([\p{Lu}]|<)@u' => "\n    == $1", // normalisation des tirets double
    '@(<emph>[^<\n]+) *\n@u' => "$1</emph>\n", // italique en fin de ligne
    '@(\n    — )([^<\n]+</emph>)@u' => "$1<emph>$2",
    '@(\n    )\PL?</emph> *@u' => "$1",
    '@(    )([^<\n]+)</emph>@u' => "$1<emph>$2</emph>", // italique en début de ligne sans tiret
    "@<(emph)>([\[(—  ]+)@u" => "$2<$1>", // sortir avant balise
    '@<hi rend="sc">V. ([^<]+)</hi>@u' => 'V. <ref>$1</ref>', // renvoi simple
    '@(\PL+)</ref>@u' => "</ref>$1", // nettoyer les <ref>
    '@<p>@u' => "<entry>",
    '@</p>@u' => "\n</entry>",

    // structuration sémantique

    '@\n    (.*)@u' => "\n....<sense>$1</sense>",
    */);

    $fp = fopen(Tagger::$HOME . "xml/medict27898.xml", "w");
    fwrite($fp, '<?xml version="1.0" encoding="UTF-8"?>
  <?xml-model href="../schema/medict27898.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
  <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:lang="fr">
    <teiHeader/>
    <text>
      <body>
  ');

    foreach (glob(Tagger::$HOME . "docx/*.xml") as $srcfile) {
        echo $srcfile, ' in=', filesize($srcfile);
        $xml = file_get_contents($srcfile);
        // $dstfile = $HOME . 'test/' . basename($srcfile);
        $xml = preg_replace(array_keys($re1), array_values($re1), $xml);
        $xml = preg_replace_callback_array($re_callback2, $xml);
        $xml = preg_replace(array_keys($re3), array_values($re3), $xml);
        echo ' out=', strlen($xml), "\n";
        fwrite($fp, "\n\n<pb>" . $srcfile . "</pb>\n\n");
        fwrite($fp, $xml);
    }

    fwrite($fp, '
      </body>
    </text>
  </TEI>
  ');

    fclose($fp);
}
