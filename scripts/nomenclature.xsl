<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:output method="text" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/">
    <xsl:text>@xml:id&#9;orth&#10;</xsl:text>
    <xsl:apply-templates select="//tei:entry"/>
  </xsl:template>
  <xsl:template match="tei:entry">
    <xsl:variable name="id" select="@xml:id"/>
    <xsl:for-each select="tei:form / tei:orth">
      <xsl:value-of select="$id"/>
      <xsl:text>&#9;</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>

</xsl:transform>