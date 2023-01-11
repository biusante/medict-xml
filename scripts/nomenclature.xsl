<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform exclude-result-prefixes="tei" version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output encoding="UTF-8" indent="yes" method="text"/>
  <xsl:template match="/">
    <xsl:text>cote&#9;entry&#9;term&#10;</xsl:text>
    <xsl:apply-templates select="/*/tei:text/tei:body/tei:entryFree[tei:p/tei:orth = 'BOTANY']"/>
  </xsl:template>
  <xsl:template match="tei:entryFree">
    <xsl:variable name="cote" select="/*/@n"/>
    <xsl:variable name="orth">
      <xsl:for-each select="tei:p / tei:orth">
        <xsl:if test="position() != 1">, </xsl:if>
        <xsl:value-of select="."/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select=".//tei:term">
      <xsl:value-of select="$cote"/>
      <xsl:text>&#9;</xsl:text>
      <xsl:value-of select="$orth"/>
      <xsl:text>&#9;</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>
</xsl:transform>
