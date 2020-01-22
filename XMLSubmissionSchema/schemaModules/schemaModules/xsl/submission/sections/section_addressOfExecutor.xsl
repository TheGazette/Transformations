<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">
  
  <!-- detailsOfTheExecutor -->
  <xsl:template match="section[@name='addressOfExecutor']" mode="additional"/>
  <xsl:template match="section[@name='addressOfExecutor']" mode="RDFa">
    <span about="this:notifiableThing" property="personal-legal:hasPersonalRepresentative" resource="this:estateExecutor"/>
    <span resource="this:addressOfExecutor" typeof="vcard:Address"/>
    <span resource="this:estateExecutor" typeof="foaf:Agent"/>
    <span about="this:estateExecutor" property="vcard:adr" resource="this:addressOfExecutor"/>
  </xsl:template>
  <xsl:template match="section[@name='addressOfExecutor']" mode="content">
    <xsl:variable name="personURI" select="concat(concat(//form/section[@name='executorDetails']/personName/forename,//form/section[@name='executorDetails']/personName/middleNames),//form/section[@name='executorDetails']/personName/surname)"/>
    <!-- section id="{@name}">
      <header>
        <h2>Address of Executor</h2>
      </header>
        <dl -->
        <!-- xsl:for-each select="address">
          <xsl:variable name="count">
            <xsl:choose>
              <xsl:when test="position() = 1"></xsl:when>
              <xsl:otherwise><xsl:value-of select="position()"/></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="position() = 1"><dt>Executor address details:</dt></xsl:when>
            <xsl:otherwise><dt>Executor alternate address details:</dt></xsl:otherwise>
          </xsl:choose -->
          <dd about="this:addressOfExecutor" property="vcard:street-address"><xsl:value-of select="street-address"/></dd>
          <xsl:if test="extended-address != ''">
            <dd about="this:addressOfExecutor" property="vcard:extended-address"><xsl:value-of select="extended-address"/></dd>
          </xsl:if>
          <dd about="this:addressOfExecutor" property="vcard:locality"><xsl:value-of select="locality"/></dd>
          <dd about="this:addressOfExecutor" property="vcard:region"><xsl:value-of select="region"/></dd>
          <dd about="this:addressOfExecutor" property="vcard:country-name"><xsl:value-of select="country-name"/></dd>
          <dd about="this:addressOfExecutor" property="vcard:postal-code"><xsl:value-of select="postal-code"/></dd>
        <!-- /xsl:for-each -->
        
      <!-- /dl -->
      
      <!-- dl><dt>Executor:</dt><dd about="this:estateAdministrator" id="executor" property="personal-legal:executorDetails" typeof="foaf:{executorType}"><xsl:value-of select="noticeResponsesDisplayAddress"/></dd></dl -->
    <!-- /section -->
  </xsl:template>
  
</xsl:stylesheet>