<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:output method="xml" encoding="UTF-8"/>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:entry">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:if test="preceding-sibling::tei:entry[1]/@xml:id = @xml:id">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="@xml:id"/>
          <xsl:text>2</xsl:text>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:transform>