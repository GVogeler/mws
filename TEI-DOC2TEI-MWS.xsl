<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mws="http://gams.uni-graz.at/mws"
    xmlns:t="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs t" version="2.0">
    <!-- Das Stylesheet kopiert alle XML Element und fügt an Stellen, an denen der Inhalt von $milestone vorkommt ein Element ein, das den Wert von $milestone bekommt. Es prüft, ob ein Asterisk vorangeht oder folgt. -->
    <xsl:variable name="milestone">E2</xsl:variable>
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|comment()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@*|*[empty(.)]" priority="-2">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="text()">
        <xsl:call-template name="milestone">
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="milestone">
        <xsl:param name="text"/>
        <xsl:choose>
            <xsl:when test="matches($text,$milestone)">
                <xsl:variable name="following" select="./substring-after($text,$milestone)"/>
                <xsl:variable name="preceding" select="substring-before($text,$milestone)"/>
                <xsl:value-of select="substring-before($preceding,'*')"/>
                <xsl:element name="{$milestone}">
                    <xsl:attribute name="type">
                        <xsl:choose>
                            <xsl:when test="starts-with($following,'*')">opener</xsl:when>
                            <xsl:when test="ends-with($preceding,'*')">closer</xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:element>
                <xsl:call-template name="milestone">
                    <xsl:with-param name="text" select="substring-after($following,'*')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
</xsl:stylesheet>
