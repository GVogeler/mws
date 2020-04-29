<?xml version="1.0" encoding="UTF-8"?>
 <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
     <!-- milestone parser
     parst ein XML nach milestone-Elementen, die paarweise verschachtelt gesetzt sind, wobei das abschließende Element mit @rend="closer" markiert ist und das eröffnende eine @xml:id besitzt. Die paarweise Zuordnung wird explizit gemacht, indem dem anschließenden Element ein @corresp auf die zugehörige xml:id vergeben wird.
     
        When creating alternative markup (e.g. for overlap) the TEI suggests to use `milestone` to markup start and end of text ranges. It is sometimes useful to make the correspondence between the two empty elements explicit (e.g. for faster parsing). This xsl adds @corresp into a correctly nested milestone structure, i.e. it assumes that every opening milestone has a corresponding closing milestone and that they form a strict hierarchy. It assumes additionally, that the opening milestone is identified by a @xml:id.
        
        Georg Vogeler, georg.vogeler@uni-graz.at, 2020-04-28
     -->
     
     <!-- ToDo:
     TEI namespace hinzufügen
     
     Wird generischer, wenn man die Markierung von opener und closer parametrisiert (@type z.B.) und wenn man die @unit mit einbezieht
     -->
     
    <xsl:param name="close-identifier"><attributeName>rend</attributeName><attributeValue>closer</attributeValue></xsl:param>
    <xsl:param name="unit"><!-- not yet implemented --></xsl:param>
    
    <xsl:template match="milestone[@*[name()=$close-identifier/attributeName]=$close-identifier/attributeValue]">
     <xsl:variable name="my-opener">
         <xsl:call-template name="find-opener">
             <xsl:with-param name="depth">0</xsl:with-param>
             <xsl:with-param name="current" select="."/>
         </xsl:call-template>
     </xsl:variable>
     <xsl:copy>
         <xsl:apply-templates select="@*"/>
         <xsl:if test="not(@xml:id)"><xsl:attribute name="xml:id" select="generate-id()"/></xsl:if><!-- eine xml:id ist immer praktisch, aber nicht notwendig für den Code -->
         <xsl:attribute name="corresp" select="$my-opener/*/@xml:id"/>
     </xsl:copy>
 </xsl:template>
 
 <!-- die eigentliche Rekursion:
 tests the preceding milestone, if it is a opener to finish the current recursion step by either finishing recursion completely or continue search with next preceding milestone. If preceding milestone is another closer the recursion goes one step deeper -->
 <xsl:template name="find-opener">
     <xsl:param name="depth">0</xsl:param>
     <xsl:param name="current" select="."/>
     <xsl:variable name="prev" select="$current/preceding::milestone[1]"/>
     <xsl:choose>
         <xsl:when test="$prev[@*[name()=$close-identifier/attributeName]=$close-identifier/attributeValue]">
         <!-- der vorangehende milestone ist auch ein closer, also muß ich die Rekursion um eins vertiefen (depth+1) -->
             <xsl:call-template name="find-opener">
                 <xsl:with-param name="depth" select="number($depth) + 1"/>
                 <xsl:with-param name="current" select="$prev"/>
             </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
         <!-- ich habe einen opener gefunden, und muss prüfen, ob das nur einer innerhalb einer Verschachtelung ist (depth > 0), oder schon "meiner" (depth=0) -->
             <xsl:choose>
                 <xsl:when test="number($depth)=0">
                 <!-- Ich habe mit der Rekursion gerade erst angefangen und bin schon fertig: -->
                     <xsl:copy-of select="$prev"/>
                 </xsl:when>
                 <xsl:otherwise>
                 <!-- the found opener corresponds to a closer preceding the closer we are interested in, so we can throw it away (depth-1) and check the milestone preceding this one -->
                     <xsl:call-template name="find-opener">
                         <xsl:with-param name="depth" select="number($depth) - 1"/>
                         <xsl:with-param name="current" select="$prev"/>
                     </xsl:call-template>
                 </xsl:otherwise>
             </xsl:choose>
         </xsl:otherwise>
     </xsl:choose>
 </xsl:template>
 
     <!-- all other nodes can simply be copied -->
     <xsl:template match="node()|@*" priority="-2">
         <xsl:copy>
             <xsl:apply-templates select="@*|node()"/>
         </xsl:copy>
     </xsl:template>
 </xsl:stylesheet>