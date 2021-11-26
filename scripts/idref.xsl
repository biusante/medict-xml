<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  <!-- Upper case letters with diactitics, translate("L'État", $uc, $lc) = "l'état" -->
  <xsl:variable name="uc">ABCDEFGHIJKLMNOPQRSTUVWXYZÆŒÇÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝ ’</xsl:variable>
  <!-- Lower case letters with diacritics, for translate() -->
  <xsl:variable name="lc">abcdefghijklmnopqrstuvwxyzæœçàáâãäåèéêëìíîïòóôõöùúûüý__</xsl:variable>
  <!-- To produce a normalised id without diacritics translate("Déjà vu, 4", $idfrom, $idto) = "dejavu4"  To produce a normalised id -->
  <xsl:variable name="idfrom">ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÄÉÈÊÏÎÔÖÛÜÇàâäéèêëïîöôüû_ ,.'’ #</xsl:variable>
  <xsl:variable name="idto"  >abcdefghijklmnopqrstuvwxyzaaaeeeiioouucaaaeeeeiioouu_</xsl:variable>
  <xsl:key name="id" match="tei:entry" use="translate(@xml:id, 
    'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÄÉÈÊÏÎÔÖÛÜÇàâäéèêëïîöôüû_ ,.’ ',
    'abcdefghijklmnopqrstuvwxyzaaaeeeiioouucaaaeeeeiioouu_'
  )"/>
  <xsl:key name="orth" match="tei:orth" use="translate(., 
    'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÄÉÈÊÏÎÔÖÛÜÇàâäéèêëïîöôüû_ ,.’ ',
    'abcdefghijklmnopqrstuvwxyzaaaeeeiioouucaaaeeeeiioouu_'
    )"/>
  <xsl:variable name="lf">
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  <xsl:variable name="tab">
    <xsl:text>&#9;</xsl:text>
  </xsl:variable>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:entryFree[not(@xml:id)]">
    <xsl:copy>
      <xsl:attribute name="xml:id">
        <xsl:value-of select="../@xml:id"/>
        <xsl:number/>
      </xsl:attribute>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:pbTMP[not(@facs)]">
    <xsl:variable name="n" select="@n"/>
    <xsl:if test="$n &lt; 1">
      <xsl:message>pb ? <xsl:value-of select="$n"/></xsl:message>
    </xsl:if>
    <xsl:copy>
      <xsl:copy-of select="@n"/>
      <xsl:attribute name="facs">
        <xsl:text>//www.biusante.parisdescartes.fr/images/livres/37020d/</xsl:text>
        <xsl:value-of select="format-number($n +14, '0000')" />
        <xsl:text>.jpg</xsl:text>
        <!--
        <xsl:text>https://iiif.archivelab.org/iiif/BIUSante_37020d$</xsl:text>
        <xsl:value-of select="$n + 13"/>
        <xsl:text>/full/full/0/default.jpg</xsl:text>
        -->
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>
    
  
  <xsl:template match="tei:refTMP[not(@target)]">
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
  
  
  <xsl:template match="tei:refDONE">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="value" select="normalize-space(.)"/>
      <xsl:value-of select="translate(substring($value, 1, 1), $lc, $uc)"/>
      <xsl:value-of select="translate(substring($value, 2), $uc, $lc)"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:entry[not(@xml:id)]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="key" select="translate(tei:form/tei:orth, $uc, $lc)"/>
      <xsl:variable name="entry" select="."/>
      <xsl:variable name="id">
        <xsl:value-of select="$key"/>
        <!--
        <xsl:choose>
          <xsl:when test="count(key('ids', $key)) = 1">
            <xsl:value-of select="$key"/>
          </xsl:when>
          <xsl:when test="count(key('ids', $key)[1]|$entry) = 1">
            <xsl:value-of select="$key"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$key"/>
            <xsl:for-each select="key('ids', $key)">
              <xsl:if test="count(.|$entry) = 1">
                <xsl:value-of select="position()"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
        -->
      </xsl:variable>
      <xsl:attribute name="xml:id">
        <xsl:value-of select="$id"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
</xsl:transform>