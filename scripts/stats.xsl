<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:output method="text" encoding="UTF-8"/>
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
  <xsl:param name="mode" select="'glossLa'"/>
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$mode = 'etym'">
        <xsl:call-template name="etym"/>
      </xsl:when>
      <xsl:when test="$mode = 'orthList'">
        <xsl:call-template name="orthList"/>
      </xsl:when>
      <xsl:when test="$mode = 'dicLa'">
        <xsl:call-template name="dicLa"/>
      </xsl:when>
      <xsl:when test="$mode = 'glossLa'">
        <xsl:call-template name="glossLa"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="dicLa"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="orthList">
    <xsl:for-each select="/tei:TEI/tei:text/tei:body//tei:orth">
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:value-of select="$lf"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="dicLa">
    <xsl:for-each select="/tei:TEI/tei:text/tei:body/tei:entry/tei:dictScrap/tei:foreign[@xml:lang = 'la']">
      <xsl:value-of select="."/>
      <xsl:value-of select="$tab"/>
      <xsl:for-each select="ancestor::tei:entry/tei:form/tei:orth">
        <xsl:value-of select="."/>
        <xsl:choose>
          <xsl:when test="position() = last()">.</xsl:when>
          <xsl:otherwise>, </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:value-of select="$lf"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="glossLa">
    <xsl:for-each select="/tei:TEI/tei:text/tei:body/tei:div[@xml:id='la']/tei:entryFree/tei:form">
      <xsl:value-of select="."/>
      <xsl:value-of select="$tab"/>
      <xsl:for-each select="ancestor::tei:entryFree/tei:term">
        <xsl:value-of select="."/>
        <xsl:choose>
          <xsl:when test="position() = last()">.</xsl:when>
          <xsl:otherwise>, </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:value-of select="$lf"/>
    </xsl:for-each>
  </xsl:template>
  


  <xsl:template name="etym">
    <xsl:text>vedette</xsl:text>
    <xsl:value-of select="$tab"/>
    <xsl:text>inversée</xsl:text>
    <xsl:value-of select="$tab"/>
    <xsl:text>étymologie avec grec</xsl:text>
    <xsl:value-of select="$lf"/>
    <xsl:for-each select="/tei:TEI/tei:text/tei:body/tei:entry/tei:dictScrap/tei:etym[@xml:lang = 'grc']">
      <xsl:variable name="id" select="ancestor::tei:entry/@xml:id"/>
      <xsl:value-of select="$id"/>
      <xsl:value-of select="$tab"/>
      <xsl:call-template name="reverse">
        <xsl:with-param name="string" select="translate($id, '0123456789', '')"/>
      </xsl:call-template>
      <xsl:value-of select="$tab"/>
      <xsl:variable name="etym">
        <xsl:apply-templates/>
      </xsl:variable>
      <xsl:value-of select="normalize-space($etym)"/>
      <xsl:value-of select="$lf"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="tei:damage">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="@xml:lang"/>
    <xsl:text>???]</xsl:text>
  </xsl:template>
  
  <xsl:template name="reverse">
    <xsl:param name="string" select="normalize-space(.)"/>
    <xsl:variable name="length" select="string-length($string)"/>
    <xsl:choose>
      <xsl:when test="$string = ''"/>
      <xsl:otherwise>
        <xsl:value-of select="substring($string, $length)"/>
        <xsl:call-template name="reverse">
          <xsl:with-param name="string" select="substring($string, 1, $length - 1)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

  <xsl:template name="tsv">
    <xsl:text>rang</xsl:text>
    <xsl:value-of select="$tab"/>
    <xsl:text>vedette</xsl:text>
    <xsl:value-of select="$tab"/>
    <xsl:text>taille (c.)</xsl:text>
    <xsl:value-of select="$lf"/>
    <xsl:for-each select="/tei:TEI/tei:text/tei:body/tei:entry">
      <xsl:sort select="string-length(normalize-space(.))" order="descending" data-type="number"/>
      <xsl:value-of select="position()"/>
      <xsl:value-of select="$tab"/>
      <xsl:value-of select="tei:form/tei:orth[1]"/>
      <xsl:value-of select="$tab"/>
      <xsl:value-of select="string-length(normalize-space(.))"/>
      <xsl:value-of select="$lf"/>
    </xsl:for-each>
  </xsl:template>
</xsl:transform>