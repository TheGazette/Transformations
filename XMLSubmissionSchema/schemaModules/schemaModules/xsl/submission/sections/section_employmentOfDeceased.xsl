<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">
  <!-- detailsOfTheDeceased -->
  <xsl:template match="section[@name='employmentOfDeceased']" mode="additional"/>
  <xsl:template match="section[@name='employmentOfDeceased']" mode="RDFa">
    <!-- xsl:variable name="personURI" select="concat(concat(../section[@name='deceasedPerson']/firstName,../section[@name='deceasedPerson']/givenName),../section[@name='deceasedPerson']/familyName)"/>
    <xsl:variable name="foafName" select="normalize-space(concat(concat(concat(concat(../section[@name='deceasedPerson']/firstName,' '),../section[@name='deceasedPerson']/givenName),' '),../section[@name='deceasedPerson']/familyName))"/-->
    <span about="this:deceasedPerson" property="person:hasEmployment" resource="this:employmentOfDeceased"/>
  </xsl:template>
  <xsl:template match="section[@name='employmentOfDeceased']" mode="content">
    <!-- xsl:variable name="personURI" select="concat(concat(personName/forename,personName/middleNames),personName/surname)"/ -->
    <!-- section id="{@name}">
      <header>
        <h2>Employment of Deceased</h2>
      </header>
      <dl -->
        <dt>Former occupation</dt>
        <dd about="this:employmentOfDeceased" property="person:jobTitle" typeof="person:Employment"><xsl:value-of select="jobTitle"/></dd>
      <!-- /dl -->
    <!-- /section -->
  </xsl:template>
</xsl:stylesheet>