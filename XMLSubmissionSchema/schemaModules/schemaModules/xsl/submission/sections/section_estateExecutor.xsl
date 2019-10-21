<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns="http://www.w3.org/1999/xhtml" version="2.0">
  
  <!-- detailsOfTheExecutor -->
  <xsl:template match="section[@name='estateExecutor']" mode="additional"/>
  <xsl:template match="section[@name='estateExecutor']" mode="RDFa">
    <span about="this:notifiableThing" property="personal-legal:hasPersonalRepresentative" resource="this:estateExecutor"/>
    <span resource="this:addressOfExecutor" typeof="vcard:Address"/>
    <span resource="this:estateExecutor" typeof="foaf:Agent"/>
    <span about="this:estateExecutor" property="vcard:adr" resource="this:addressOfExecutor"/>
  </xsl:template>
  <xsl:template match="section[@name='estateExecutor']" mode="content">
    <xsl:variable name="personURI" select="concat(concat(//form/section[@name='executorDetails']/personName/forename,//form/section[@name='executorDetails']/personName/middleNames),//form/section[@name='executorDetails']/personName/surname)"/>
    <!-- section id="{@name}">
      <header>
        <h2>Details of the executor</h2>
      </header>
      
      <dl -->
        <dt>Surname:</dt>
        <dd about="this:estateExecutor" foaf:familyName="{familyName}" property="foaf:familyName" typeof="gaz:Person">
          <xsl:value-of select="familyName"/>
        </dd>
        <dt>First name:</dt>
        <dd about="this:estateExecutor" foaf:firstName="{firstName}" property="foaf:firstName" typeof="gaz:Person">
          <xsl:value-of select="firstName"/>
        </dd>
        <dt>Middle name:</dt>
        <dd about="this:estateExecutor" foaf:givenName="{givenName}" property="foaf:givenName" typeof="gaz:Person">
          <xsl:value-of select="givenName"/>
        </dd>
        
        <xsl:for-each select="address">
          <xsl:variable name="count">
            <xsl:choose>
              <xsl:when test="position() = 1"/>
              <xsl:otherwise><xsl:value-of select="position()"/></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="position() = 1"><dt>Executor address details:</dt></xsl:when>
            <xsl:otherwise><dt>Executor alternate address details:</dt></xsl:otherwise>
          </xsl:choose>
          <dd about="this:addressOfExecutor{$count}" property="person:houseInformation"><xsl:value-of select="addressLine1"/></dd>
          <xsl:if test="addressLine2 != ''">
            <dd about="this:addressOfDeceased{$count}" property="vcard:street-address"><xsl:value-of select="addressLine2"/></dd>
          </xsl:if>
          <dd about="this:addressOfExecutor{$count}" property="vcard:locality"><xsl:value-of select="locality"/></dd>
          <dd about="this:addressOfExecutor{$count}" property="vcard:region"><xsl:value-of select="region"/></dd>
          <dd about="this:addressOfExecutor{$count}" property="vcard:postalCode"><xsl:value-of select="postcode"/></dd>
        </xsl:for-each>
        
      <!-- /dl -->
      
      <!-- dl><dt>Executor:</dt><dd about="this:estateAdministrator" id="executor" property="personal-legal:executorDetails" typeof="foaf:{executorType}"><xsl:value-of select="noticeResponsesDisplayAddress"/></dd></dl -->
    <!-- /section -->
  </xsl:template>
  
</xsl:stylesheet>