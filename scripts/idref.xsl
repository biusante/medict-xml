<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  <!-- Upper case letters with diactitics, translate("L'État", $uc, $lc) = "l'état" -->
  <xsl:variable name="uc">ABCDEFGHIJKLMNOPQRSTUVWXYZÆŒÇÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝ ’</xsl:variable>
  <!-- Lower case letters with diacritics, for translate() -->
  <xsl:variable name="lc">abcdefghijklmnopqrstuvwxyzæœçàáâãäåèéêëìíîïòóôõöùúûüý__</xsl:variable>
  <xsl:key name="ids" match="tei:entry" use="translate(tei:form/tei:orth, 
    'ABCDEFGHIJKLMNOPQRSTUVWXYZÆŒÇÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝ ’', 
    'abcdefghijklmnopqrstuvwxyzæœçàáâãäåèéêëìíîïòóôõöùúûüý__'
    )"/>
  <xsl:variable name="lf">
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  <xsl:variable name="tab">
    <xsl:text>&#9;</xsl:text>
  </xsl:variable>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:entry">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="key" select="translate(tei:form/tei:orth, $uc, $lc)"/>
      <xsl:variable name="entry" select="."/>
      <xsl:variable name="id">
        <xsl:choose>
          <xsl:when test="count(key('ids', $key)) = 1">
            <xsl:value-of select="$key"/>
          </xsl:when>
          <xsl:when test="count(key('ids', $key)[1]|$entry) = 1">
            <xsl:value-of select="$key"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$key"/>
            <xsl:for-each select="key('ids', $key)">
              <xsl:if test="count(.|$entry) = 1">
                <xsl:value-of select="position()"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="xml:id">
        <xsl:value-of select="$id"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
</xsl:transform>