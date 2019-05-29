<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns="http://www.w3.org/1999/xhtml" version="2.0">
  <!-- detailsOfTheDeceased -->
  <xsl:template match="section[@name='deceasedPerson']" mode="additional"/>
  <xsl:template match="section[@name='deceasedPerson']" mode="RDFa">
    <xsl:variable name="personURI" select="concat(concat(firstName,givenName),familyName)"/>
    <xsl:variable name="foafName" select="normalize-space(concat(concat(concat(concat(firstName,' '),givenName),' '),familyName))"/>
    <span about="this:notifiableThing" property="personal-legal:hasEstateOf" resource="this:deceasedPerson"/>
    <span about="this:deceasedPerson" typeof="gaz:Person"/>
    <span about="this:deceasedPerson" content="{$foafName}" foaf:name="{$foafName}" property="foaf:name"/>
  </xsl:template>
  <xsl:template match="section[@name='deceasedPerson']" mode="content">
    <xsl:variable name="personURI" select="concat(concat(personName/forename,personName/middleNames),personName/surname)"/>
    <!-- section id="{@name}">
      <header>
        <h2>Details Of The Deceased</h2>
      </header>
      <dl -->
        <dt>Surname X:</dt><dd about="this:deceasedPerson" property="foaf:familyName" typeof="gaz:Person"><xsl:value-of select="familyName"/></dd>
        <dt>First name:</dt>
        <dd about="this:deceasedPerson" property="foaf:firstName" typeof="gaz:Person"><xsl:value-of select="firstName"/></dd>
        <dt>Middle name:</dt>
        <dd about="this:deceasedPerson" property="foaf:givenName" typeof="gaz:Person"><xsl:value-of select="givenName"/></dd>
        <dt>Maiden name:</dt>
        <dd about="this:deceasedPerson" property="person:hasMaidenName" typeof="gaz:Person"><xsl:value-of select="maidenName"/></dd>
        <xsl:for-each select="alsoKnownAs">
          <dt>Alternative name:</dt>
          <dd about="this:deceasedPerson" property="person:alsoKnownAs" typeof="gaz:Person"><xsl:value-of select="."/></dd>
        </xsl:for-each>
        <dt>Date of death:</dt>
        <xsl:choose>
          <xsl:when test="normalize-space(dateOfDeath) != ''">
            <dd about="this:deceasedPerson" content="{dateOfDeath}" datatype="xsd:date" property="personal-legal:dateOfDeath" typeof="gaz:Person"><time datetime="{dateOfDeath}"><xsl:value-of select="dateOfDeath"/></time></dd>
          </xsl:when>
          <xsl:otherwise>
            <dd><time about="this:deceasedPerson" content="{startDateOfDeath}" datatype="xsd:date" datetime="{startDateOfDeath}" property="personal-legal:startDateOfDeath" typeof="gaz:Person"><xsl:value-of select="startDateOfDeath"/></time></dd>
            <dd><time about="this:deceasedPerson" content="{endDateOfDeath}" datatype="xsd:date" datetime="{endDateOfDeath}" property="personal-legal:endDateOfDeath" typeof="gaz:Person"><xsl:value-of select="endDateOfDeath"/></time></dd>
          </xsl:otherwise>
        </xsl:choose>      <!-- /dl>
    </section -->
  </xsl:template>
</xsl:stylesheet>