<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform exclude-result-prefixes="tei" version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output encoding="UTF-8" indent="yes" method="text"/>
  <xsl:template match="/">
    <xsl:text>cote&#9;entry&#9;grec&#10;</xsl:text>
    <xsl:apply-templates select="//tei:entry"/>
  </xsl:template>
  <xsl:template match="tei:entry">
    <xsl:if test="not(@corresp)">
      <xsl:text>_27898</xsl:text>
      <xsl:text>&#9;</xsl:text>
      <xsl:for-each select="tei:form / tei:orth">
        <xsl:if test="position() != 1">, </xsl:if>
        <xsl:value-of select="."/>
      </xsl:for-each>
      <xsl:text>&#9;</xsl:text>
      <xsl:for-each select="tei:dictScrap / tei:foreign[@xml:lang = 'grc']">
        <xsl:if test="position() != 1">, </xsl:if>
        <xsl:value-of select="."/>
      </xsl:for-each>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>
</xsl:transform>
