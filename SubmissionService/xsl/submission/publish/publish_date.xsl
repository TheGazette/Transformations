<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" 
  xmlns:x="http://www.w3.org/1999/xhtml" 
  xmlns:gzm="http://www.gazettes.co.uk/metadata" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="2.0" exclude-result-prefixes="#all">

  <xsl:param name="date"/>
  
  <xsl:output exclude-result-prefixes="#all"/>

  <xsl:template match="*:dt[following-sibling::*:dd[1]/*:span[@property = 'gaz:earliestPublicationDate']]">
    <dt>Publication date:</dt>
  </xsl:template>

  <xsl:template match="node()[@property='gaz:earliestPublicationDate']">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*[not(. = 'gaz:earliestPublicationDate')]"/>
      <xsl:attribute name="property" select="'gaz:hasPublicationDate'"/>
      <xsl:attribute name="content" select="$date"/>
      <time datetime="{$date}"><xsl:value-of select="format-dateTime($date,'[D] [MNn] [Y]')"/></time>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/ | @* | 
    node()[not(@property='gaz:earliestPublicationDate') 
    and not(following-sibling::*[1]/*:span[@property = 'gaz:earliestPublicationDate'])]">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="//gzm:publication-date/text()"><xsl:value-of  select="$date" /></xsl:template>

</xsl:stylesheet>