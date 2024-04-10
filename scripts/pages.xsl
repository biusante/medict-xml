<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">
  <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
  <xsl:key name="pb" match="tei:pages/tei:pb" use="@n"/>
  
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

<!-- 
<pb n="1" facs="https://www.biusante.parisdescartes.fr/iiif/2/bibnum:37019:0017/full/full/0/default.jpg" corresp="https://www.biusante.parisdescartes.fr/histmed/medica/page?37019&amp;p=17"/>

  -->
  <xsl:template match="tei:pb">
    <xsl:variable name="n" select="@n"/>
    <pb n="{$n}" facs="https://www.biusante.parisdescartes.fr/iiif/2/bibnum:37019:{format-number($n + 16, '0000')}/full/full/0/default.jpg" corresp="https://www.biusante.parisdescartes.fr/histmed/medica/page?37019&amp;p={$n+16}"/>
  </xsl:template>

  <xsl:template match="tei:pages"/>
  
  
</xsl:transform>