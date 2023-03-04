<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://relaxng.org/ns/structure/1.0" exclude-result-prefixes="tei">
<xsl:output indent="yes"/>


  <xsl:template match="/">
    <grammar ns="http://www.tei-c.org/ns/1.0" xml:lang="fr">
      <define name="orth61157">
        <choice>
          <xsl:apply-templates select="//tei:orth"/>
        </choice>
      </define>
    </grammar>
  </xsl:template>

  <xsl:template match="tei:orth">
    <value>
      <xsl:variable name="text">
        <xsl:for-each select="text()">
          <xsl:value-of select="."/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="normalize-space($text)"/>
    </value>
  </xsl:template>
</xsl:transform>
