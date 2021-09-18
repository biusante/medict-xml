<?php
/**
 * Different tools to build html sites
 */
Etym::cli();
class Etym
{
  static public function cli()
  {
    $pb;
    $pbseen;
    $entry;
    $etym;
    $n = 0;
    $handle = fopen(dirname(dirname(__FILE__)).'/xml/medict37020d.xml', "r");
    echo "<body>\n";
    while (($line = fgets($handle)) !== false) {
      // <pb n="0001" facs="//www.biusante.parisdescartes.fr/images/livres/37020d/0015.jpg"/>
      if(preg_match('@<pb n="(\d+)" facs="[^"]+/([^/]+)/([^/]+)\.jpg"/>@', $line, $matches)) {
        $pb = '<a class="page" href="https://www.biusante.parisdescartes.fr/histoire/medica/resultats/index.php?do=zoom&amp;cote=37020d&amp;p='.(0+$matches[3]).'">p. '.(0+$matches[1]).'</a>';
        $pbseen = false;
      }
      // <entry xml:id="abre">
      else if(preg_match('@<entry xml:id="([^"]+)">@', $line, $matches)) {
        $entry = "<b>".$matches[1]."</b> ";
      }
      // <dictScrap>
      else if(preg_match('@<dictScrap>@', $line) && preg_match('@\p{Greek}@u', $line)) {
        if (!$pbseen) {
          echo "<div>",$pb,"</div>\n";
          $pbseen = true;
        }
        $etym = preg_replace(array('@<(/?)dictScrap>@', '@<(/?)emph>@'), array('', '<$1em>'), trim($line));
        $n++;
        echo "<p>",$entry,$etym,"</p>\n"; // ,$n,'. '
      }
    }
    echo "</body>\n";
    fclose($handle);
    echo $n,"\n";
  }

}
?>
