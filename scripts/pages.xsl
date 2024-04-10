<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
  <xsl:key name="pb" match="tei:pages/tei:pb" use="@n"/>
  
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:text//tei:pb">
    <xsl:variable name="n" select="@n"/>
    <xsl:copy-of select="key('pb', $n)"/>
  </xsl:template>

  <xsl:template match="tei:pages"/>
  
  
</xsl:transform>