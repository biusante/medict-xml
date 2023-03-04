<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://relaxng.org/ns/structure/1.0" exclude-result-prefixes="tei">
<xsl:output method="text" encoding="UTF-8"/>
  <xsl:key name="orth" match="tei:orth" use="normalize-space(text())"/>

  <xsl:template match="/">
    <xsl:text>Vedette&#9;Renvoi&#9;Lien mort ?&#10;</xsl:text>
    <xsl:apply-templates select="//tei:ref"/>
  </xsl:template>

  <xsl:template match="tei:ref">
    <xsl:value-of select="(ancestor::tei:entryFree//tei:orth)[1]"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>&#9;</xsl:text>
    <xsl:choose>
      <xsl:when test="key('orth', string(.))"/>
      <xsl:otherwise>???</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
</xsl:transform>
