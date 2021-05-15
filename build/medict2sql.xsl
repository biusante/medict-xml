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

  <xsl:template match="/">
    <xsl:text>object</xsl:text>
    <xsl:value-of select="$tab"/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="text()"/>
    

  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:TEI">
    <xsl:text>volume</xsl:text>
    <xsl:value-of select="$tab"/>
    <xsl:value-of select="@n"/>
    <xsl:value-of select="$tab"/>
    <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:profileDesc/tei:creation/tei:date/@when"/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates/>
  </xsl:template>
  

  <xsl:template match="tei:pb">
    <xsl:value-of select="local-name()"/>
    <xsl:value-of select="$tab"/>
    <xsl:value-of select="@n"/>
    <xsl:value-of select="$tab"/>
    <xsl:value-of select="@facs"/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:entry">
    <xsl:value-of select="local-name()"/>
    <xsl:value-of select="$tab"/>
    <xsl:value-of select="@xml:id"/>
    <xsl:value-of select="$tab"/>
    <xsl:value-of select="count(.//tei:pb)"/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:orth">
    <xsl:value-of select="local-name()"/>
    <xsl:value-of select="$tab"/>
    <xsl:value-of select="."/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:sense[starts-with(., '–') or starts-with(., '=')]/tei:emph[1]">
    <xsl:text>term</xsl:text>
    <xsl:value-of select="$tab"/>
    <xsl:value-of select="."/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:ref[@target]">
    <xsl:value-of select="local-name()"/>
    <xsl:value-of select="$tab"/>
    <xsl:value-of select="@target"/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates/>
  </xsl:template>
  

</xsl:transform>