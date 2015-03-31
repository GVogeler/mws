<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output indent="yes"/>
    <!-- Das Template setzt voraus, daß 
        * eine im Ausgangsdokument nur milestones stehen
        * diese eine valide XML-Struktur aufbauen
        * die öffnenden milestones eine @xml:id besitzen, auf die die schließenden milestones mit @corresp verweisten
        * die milestones mit @rend='closer' die Struktur schließen
        * keine anderen milestones vorkommen.
    -->
    <xsl:template match="/">
        <xsl:apply-templates select="/text/milestone[1]"/>
    </xsl:template>
    <xsl:template match="milestone">
        <xsl:variable name="id" select="@xml:id/string()"/>
<!-- Meine Struktur besteht aus dem aktuellen milestone und dem closer-Milestone, der mit der aktuellenm xml:id korrespondiert -->
        <xsl:variable name="closer.me" select="following::milestone[@corresp=concat('#',$id) and @rend='closer']"/>
<!-- Innerhalb der Struktur muß ich nach dem ersten Opener suchen, d.h. der erste Opener, dem der aktuelle Closer nicht vorangeht=der nicht hinter dem aktuellen Closer steht=der vor dem aktuellen Closer steht.-->
        <xsl:variable name="opener.inner"
            select="following::milestone[not(preceding::milestone/@corresp=concat('#',$id) and @rend='closer')][1]"/>
        <!-- Beim Verlassen der Struktur muß ich testen, ob es noch weitergeht, d.h. ob auf den aktuellen Closer ein Opener folgt -->
        <xsl:variable name="opener.follow"
            select="$closer.me/following::milestone[not(@rend='closer')][1]"/>
        <xsl:element name="{@unit}">
            <xsl:attribute name="xml:id" select="$id"/>
            <!-- Die Struktur kann mit Text beginnen
            -->
            <xsl:apply-templates select="following::text()[1]" />
            <!-- oder Substrukturen enthalten -->
            <xsl:apply-templates select="$opener.inner[1]" />
        </xsl:element>
        <!-- Folgestrukturen aufbauen:
        Das kann text() sein oder 
        ein neues Element
        -->
        <xsl:apply-templates select="$closer.me/following::text()[1]" />
        <xsl:apply-templates select="$opener.follow[1]" />
    </xsl:template>
    <xsl:template match="text()">
        <xsl:value-of select="."/>
<!--        <xsl:value-of select="substring(.,1,20)"/>...<xsl:value-of select="substring(.,string-length(.)-10,20)"/>-->
        <xsl:text>            
        </xsl:text>
    </xsl:template>
</xsl:stylesheet>
