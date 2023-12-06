<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  <!-- Upper case letters with diactitics, translate("L'État", $uc, $lc) = "l'état" -->
  <xsl:variable name="uc">ABCDEFGHIJKLMNOPQRSTUVWXYZÆŒÇÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝ</xsl:variable>
  <!-- Lower case letters with diacritics, for translate() -->
  <xsl:variable name="lc">abcdefghijklmnopqrstuvwxyzæœçàáâãäåèéêëìíîïòóôõöùúûüý</xsl:variable>
  <!-- To produce a normalised id without diacritics translate("Déjà vu, 4", $idfrom, $idto) = "dejavu4"  To produce a normalised id -->
  <xsl:variable name="idfrom">ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÄÉÈÊÏÎÔÖÛÜÇàâäéèêëïîöôüû_ ,.'’ #</xsl:variable>
  <xsl:variable name="idto"  >abcdefghijklmnopqrstuvwxyzaaaeeeiioouucaaaeeeeiioouu_</xsl:variable>
  <xsl:variable name="cote" select="/*/@n"/>
  <xsl:key name="key" match="tei:entry" use="translate(tei:form/tei:orth, 
    'ABCDEFGHIJKLMNOPQRSTUVWXYZÆŒÇÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝ_ ,.’ ',
    'abcdefghijklmnopqrstuvwxyzæœçàáâãäåèéêëìíîïòóôõöùúûüý      '
  )"/>
  <xsl:variable name="lf">
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  <xsl:variable name="tab">
    <xsl:text>&#9;</xsl:text>
  </xsl:variable>
  <!-- byid -->
  <xsl:key name="id" match="tei:entry" use="@xml:id" />
  

  
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <!--
  <xsl:variable name="grc" select="document('../corrections/37020d_grc-foreign.xml')/*/tei:foreign"/>
  <xsl:template match="tei:dictScrap[tei:foreign[@xml:lang = 'grc']]">
    <xsl:variable name="id" select="../@xml:id"/>
    <xsl:variable name="ins" select="$grc[@entry = $id]"/>
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <xsl:choose>
        <xsl:when test="$ins = ''">
          <ho/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$ins"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  -->
  
  <xsl:template match="tei:___ref">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="value" select="normalize-space(.)"/>
      <xsl:value-of select="translate(substring($value, 1, 1), $lc, $uc)"/>
      <xsl:value-of select="translate(substring($value, 2), $uc, $lc)"/>
    </xsl:copy>
  </xsl:template>

  
  <xsl:template match="tei:___entryFree[not(@xml:id)]">
    <xsl:copy>
      <xsl:attribute name="xml:id">
        <xsl:value-of select="../@xml:id"/>
        <xsl:number/>
      </xsl:attribute>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- 
  <pb corresp="https://www.biusante.parisdescartes.fr/histmed/medica/page?37020d&amp;p=387" facs="https://www.biusante.parisdescartes.fr/iiif/2/bibnum:37020d:0387/full/full/0/default.jpg" n="0373"/>
  -->
  <xsl:template match="tei:pb[not(@facs)]">
    <xsl:variable name="n" select="number(@n)"/>
    <xsl:variable name="diff" select="16"/>
    <xsl:if test="$n &lt; 1">
      <xsl:message>pb ? <xsl:value-of select="$n"/></xsl:message>
    </xsl:if>
    <xsl:copy>
      <xsl:copy-of select="@n"/>
      <xsl:attribute name="facs">
        <xsl:text>https://www.biusante.parisdescartes.fr/iiif/2/bibnum:</xsl:text>
        <xsl:value-of select="$cote"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="format-number($n +$diff, '0000')" />
        <xsl:text>/full/full/0/default.jpg</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="corresp">
        <xsl:text>https://www.biusante.parisdescartes.fr/histmed/medica/page?</xsl:text>
        <xsl:value-of select="$cote"/>
        <xsl:text>&amp;p=</xsl:text>
        <xsl:value-of select="$n +$diff" />
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>
    
  
  <xsl:template match="tei:___ref[not(@target)]">
    <xsl:variable name="key">
      <xsl:variable name="norm" select="normalize-space(.)"/>
      <xsl:choose>
        <xsl:when test="substring($norm, string-length($norm)) = 's'">
          <xsl:value-of select="translate(substring($norm, 1, string-length($norm)-1) , $idfrom, $idto)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(normalize-space(.) , $idfrom, $idto)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:choose>
        <xsl:when test="key('id', $key)">
          <xsl:variable name="id" select="key('id', $key)/@xml:id"/>
          <xsl:attribute name="target">
            <xsl:value-of select="key('id', $key)/@xml:id"/>
          </xsl:attribute>
          <xsl:value-of select="translate(substring($id, 1, 1), $lc, $uc)"/>
          <xsl:value-of select="translate(substring($id, 2), $uc, $lc)"/>
        </xsl:when>
        <xsl:when test="key('orth', $key)">
          <xsl:attribute name="target">
            <xsl:value-of select="key('orth', $key)/ancestor::tei:entry/@xml:id"/>
          </xsl:attribute>
          <xsl:value-of select="translate(substring(key('orth', $key), 1, 1), $lc, $uc)"/>
          <xsl:value-of select="translate(substring(key('orth', $key), 2), $uc, $lc)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="value" select="normalize-space(.)"/>
          <xsl:value-of select="translate(substring($value, 1, 1), $lc, $uc)"/>
          <xsl:value-of select="translate(substring($value, 2), $uc, $lc)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <!-- Corresp -->
  <xsl:variable name="littre1873" select="document('medict37020d.xml', .)"/>
  <xsl:template match="tei:___entry[not(@corresp)]">
    <xsl:variable name="id" select="@xml:id"/>
    <xsl:variable name="corresp">
      <xsl:for-each select="$littre1873">
        <xsl:value-of select="key('id', $id)/tei:form/tei:orth"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
    <xsl:if test="$corresp != ''">
      <xsl:attribute name="corresp">medict37020d.xml</xsl:attribute>
    </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  
  <xsl:template match="tei:__entry[not(@xml:id)]">
      <!-- identifiant -->
      <xsl:variable name="entry" select="."/>
      <xsl:variable name="key" select="
translate(
  tei:form/tei:orth, 
  concat($uc, '_ ,.’ #()°'), 
  concat($lc, '          ')
)
"/>
        <!--
        -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xml:id">
        <xsl:value-of select="translate(normalize-space($key), ' ', '_')"/>
        <xsl:choose>
          <!-- seul -->
          <xsl:when test="count(key('key', $key)) = 1"/>
          <!-- premier = bon -->
          <xsl:when test="count(key('key', $key)[1]|$entry) = 1"/>
          <xsl:otherwise>
            <!-- numéroter -->
            <xsl:for-each select="key('key', $key)">
              <xsl:if test="count(.|$entry) = 1">
                <xsl:value-of select="position()"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
</xsl:transform>