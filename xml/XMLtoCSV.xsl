<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="1.0">
    
    <!-- Définir la sortie comme texte pour générer un CSV -->
    <xsl:output method="text" encoding="UTF-8"/>
    
    <!-- Racine de la transformation -->
    <xsl:template match="/">
        
        <!-- Ajouter un BOM pour l'encodage UTF-8 -->
        <xsl:text>&#xFEFF;</xsl:text>
        
        <!-- En-tête du CSV -->
        <xsl:text>Vedettes;POS;Renvois;Traductions;Italique&#10;</xsl:text>
        
        <!-- Variables pour compter les occurrences -->
        <xsl:variable name="totalEntries" select="count(//tei:entry)"/>
        <xsl:variable name="totalOrth" select="count(//tei:orth)"/>
        <xsl:variable name="totalGram" select="count(//tei:gram)"/>
        <xsl:variable name="totalRef" select="count(//tei:ref)"/>
        <xsl:variable name="totalForeign" select="count(//tei:foreign)"/>
        <xsl:variable name="totalHi" select="count(//tei:hi)"/>
        <xsl:variable name="totalPb" select="count(//tei:pb)"/>
        
        <!-- Parcourir chaque élément entry dans l'espace de noms TEI -->
        <xsl:for-each select="//tei:entry">
            <!-- Extraction et concaténation de toutes les orth -->
            <xsl:variable name="orths">
                <xsl:for-each select=".//tei:orth">
                    <xsl:value-of select="normalize-space(.)"/>
                    <xsl:if test="position() != last()">
                        <xsl:text> | </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            
            <!-- Extraction et concaténation de toutes les gram -->
            <xsl:variable name="grams">
                <xsl:for-each select=".//tei:gram">
                    <xsl:value-of select="normalize-space(.)"/>
                    <xsl:if test="position() != last()">
                        <xsl:text> | </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            
            <!-- Extraction et concaténation de toutes les ref -->
            <xsl:variable name="refs">
                <xsl:for-each select=".//tei:ref">
                    <xsl:value-of select="normalize-space(.)"/>
                    <xsl:if test="position() != last()">
                        <xsl:text> | </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            
            <!-- Extraction et concaténation de toutes les foreign -->
            <xsl:variable name="foreigns">
                <xsl:for-each select=".//tei:foreign">
                    <xsl:value-of select="normalize-space(.)"/>
                    <xsl:if test="position() != last()">
                        <xsl:text> | </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            
            <!-- Extraction et concaténation de toutes les hi -->
            <xsl:variable name="his">
                <xsl:for-each select=".//tei:hi">
                    <xsl:value-of select="normalize-space(.)"/>
                    <xsl:if test="position() != last()">
                        <xsl:text> | </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            
            <!-- Génération de la ligne CSV -->
            <xsl:value-of select="concat($orths, ';', $grams, ';', $refs, ';', $foreigns, ';', $his, '&#10;')"/>
        </xsl:for-each>
        
        <!-- Affichage du résumé des éléments dans la console -->
        <xsl:text>&#10;--- Résumé ---&#10;</xsl:text>
        <xsl:text>Entrées: </xsl:text><xsl:value-of select="$totalEntries"/><xsl:text>&#10;</xsl:text>
        <xsl:text>Vedettes et doublets: </xsl:text><xsl:value-of select="$totalOrth"/><xsl:text>&#10;</xsl:text>
        <xsl:text>Catégories grammaticales: </xsl:text><xsl:value-of select="$totalGram"/><xsl:text>&#10;</xsl:text>
        <xsl:text>Renvois: </xsl:text><xsl:value-of select="$totalRef"/><xsl:text>&#10;</xsl:text>
        <xsl:text>Mots étrangers: </xsl:text><xsl:value-of select="$totalForeign"/><xsl:text>&#10;</xsl:text>
        <xsl:text>Mots en italique: </xsl:text><xsl:value-of select="$totalHi"/><xsl:text>&#10;</xsl:text>
        <xsl:text>Pages: </xsl:text><xsl:value-of select="$totalPb"/><xsl:text>&#10;</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>