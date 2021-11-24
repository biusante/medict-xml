<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
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
  <xsl:param name="mode" select="'html'"/>
  
  <xsl:template match="/">
    <xsl:call-template name="html"/>
  </xsl:template>

  <xsl:template name="html">
    <html>
      <body>
        <xsl:call-template name="glossaire"/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template name="glossaire">
    <xsl:param name="lang">grc</xsl:param>
    <xsl:for-each select="//tei:div[@xml:id='grc']/tei:entryFree">
      <div>
        <xsl:apply-templates select="preceding::tei:pb[1]"/>
        <xsl:text> </xsl:text>
        <xsl:for-each select="tei:form">
          <strong>
            <xsl:apply-templates/>
          </strong>
          <xsl:choose>
            <xsl:when test="position() = last()">.</xsl:when>
            <xsl:otherwise>, </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </div>
      <div style="font-style: italic,">
        <xsl:for-each select="tei:term|tei:gloss">
          <xsl:apply-templates/>
          <xsl:choose>
            <xsl:when test="position() = last()">.</xsl:when>
            <xsl:otherwise>, </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </div>
    </xsl:for-each>
  </xsl:template>
  
  
  <xsl:template name="foreign">
    <xsl:for-each select="//tei:entry[tei:dictScrap/tei:foreign[@xml:lang='grc']]">
      <div>
        <xsl:apply-templates select="preceding::tei:pb[1]"/>
        <xsl:text> </xsl:text>
        <b>
          <xsl:value-of select="@xml:id"/>
        </b>
        <xsl:text> — </xsl:text>
        <xsl:for-each select="tei:dictScrap/tei:foreign[@xml:lang!='grc']">
          <xsl:apply-templates/>
          <xsl:choose>
            <xsl:when test="position() = last()">.</xsl:when>
            <xsl:otherwise>, </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </div>
      <div>
        <xsl:for-each select="tei:dictScrap/tei:foreign[@xml:lang='grc']">
          <xsl:apply-templates/>
          <xsl:choose>
            <xsl:when test="position() != last()"> — </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </div>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="*[@xml:lang='grc']/tei:damage | *[@xml:lang='grc']/tei:unclear">
    <span style="color:red">ΑαωΩ</span>
  </xsl:template>

  <xsl:template match="tei:pb">
    <a class="pb">
      <xsl:attribute name="href">
        <xsl:value-of select="@facs"/>
      </xsl:attribute>
      <xsl:text>[</xsl:text>
      <xsl:text>p. </xsl:text>
      <xsl:value-of select="@n"/>
      <xsl:text>]</xsl:text>
    </a>
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