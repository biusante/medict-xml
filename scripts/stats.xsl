<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:output method="text" encoding="UTF-8"/>
  <!-- Upper case letters with diactitics, translate("L'État", $uc, $lc) = "l'état" -->
  <xsl:variable name="uc">ABCDEFGHIJKLMNOPQRSTUVWXYZÆŒÇÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝ</xsl:variable>
  <!-- Lower case letters with diacritics, for translate() -->
  <xsl:variable name="lc">abcdefghijklmnopqrstuvwxyzæœçàáâãäåèéêëìíîïòóôõöùúûüý</xsl:variable>
  <xsl:variable name="lf">
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  <xsl:variable name="tab">
    <xsl:text>&#9;</xsl:text>
  </xsl:variable>
  <xsl:param name="mode"/>
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$mode = 'orthList'">
        <xsl:call-template name="orthList"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="orthList"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="orthList">
    <xsl:for-each select="/tei:TEI/tei:text/tei:body//tei:orth">
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:value-of select="$lf"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="tsv">
    <xsl:text>rang</xsl:text>
    <xsl:value-of select="$tab"/>
    <xsl:text>vedette</xsl:text>
    <xsl:value-of select="$tab"/>
    <xsl:text>taille (c.)</xsl:text>
    <xsl:value-of select="$lf"/>
    <xsl:for-each select="/tei:TEI/tei:text/tei:body/tei:entry">
      <xsl:sort select="string-length(normalize-space(.))" order="descending" data-type="number"/>
      <xsl:value-of select="position()"/>
      <xsl:value-of select="$tab"/>
      <xsl:value-of select="tei:form/tei:orth[1]"/>
      <xsl:value-of select="$tab"/>
      <xsl:value-of select="string-length(normalize-space(.))"/>
      <xsl:value-of select="$lf"/>
    </xsl:for-each>
  </xsl:template>
</xsl:transform>