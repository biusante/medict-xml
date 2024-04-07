<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
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
  <xsl:key name="l2" match="tei:entryFree[@type='l2']" use="preceding::tei:pb[1]/@n"/>
  <xsl:key name="medict" match="tei:entryFree[@type='medict']" use="preceding::tei:pb[1]/@n"/>
  
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:entryFree[@type='medict']">
    <xsl:variable name="position">
      <xsl:number/>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates select="/tei:TEI/tei:text/tei:div[@xml:id='l2']/tei:entryFree[position() = $position]/node()"/>
      <xsl:processing-instruction name="old"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:div[@xml:id='l2']"/>
  
  
</xsl:transform>