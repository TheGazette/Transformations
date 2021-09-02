<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:foaf="http://xmlns.com/foaf/0.1/" version="2.0">
  <!-- detailsOfTheDeceased -->
  <xsl:template match="section[@name='deceasedPerson']" mode="RDFa">
    <xsl:variable name="personURI" select="concat(concat(personName/forename,personName/middleNames),personName/surname)"/>
    <xsl:variable name="foafName" select="normalize-space(concat(concat(concat(concat(personName/forename,' '),personName/middleNames),' '),personName/surname))"/>
    <span about="this:notifiableThing" property="personal-legal:hasEstateOf" resource="this:{$personURI}"/>
    <span about="this:{$personURI}" typeof="gaz:Person"/>
    <span about="this:{$personURI}" content="{$foafName}" foaf:name="{$foafName}" property="foaf:name"/>
    <span about="this:{$personURI}" property="person:hasEmployment" resource="this:occupationOfDeceased"/>
  </xsl:template>
  <xsl:template match="section[@name='deceasedPerson']" mode="content">
    <xsl:variable name="personURI" select="concat(concat(personName/forename,personName/middleNames),personName/surname)"/>
    <section id="{@name}">
      <header>
        <h2>Details Of The Deceased</h2>
      </header>
      <dl><dt>Surname:</dt><dd about="this:{$personURI}" foaf:familyName="{personName/surname}" id="surName" property="foaf:familyName" typeof="gaz:Person"><xsl:value-of select="personName/surname"/></dd>
        <dt>First name:</dt>
        <dd about="this:{$personURI}" foaf:firstName="{personName/forename}" id="foreName" property="foaf:firstName" typeof="gaz:Person"><xsl:value-of select="personName/forename"/></dd>
        <dt>Middle name:</dt>
        <dd about="this:{$personURI}" foaf:givenName="{personName/middleNames}" id="middleName" property="foaf:givenName" typeof="gaz:Person"><xsl:value-of select="personName/middleNames"/></dd>
        <dt>Maiden name:</dt>
        <dd about="this:{$personURI}" property="foaf:hasMaidenName" typeof="gaz:Person"><xsl:value-of select="personName/maidenname"/></dd>
        <dt>Alternative name:</dt>
        <dd about="this:{$personURI}" property="person:alsoKnownAs" typeof="gaz:Person"><xsl:value-of select="alsoKnownAs[1]"/></dd>
        <dt>Date of death:</dt>
        <dd id="startDateOfDeath"><time about="this:{$personURI}" content="{deathDetails/betweenDates/fromDate}" datatype="xsd:date" datetime="{deathDetails/betweenDates/fromDate}" property="personal-legal:startDateOfDeath" typeof="gaz:Person"><xsl:value-of select="deathDetails/betweenDates/fromDate"/></time></dd>
        <dd id="endDateOfDeath"><time about="this:{$personURI}" content="{deathDetails/betweenDates/toDate}" datatype="xsd:date" datetime="{deathDetails/betweenDates/toDate}" property="personal-legal:endDateOfDeath" typeof="gaz:Person"><xsl:value-of select="deathDetails/betweenDates/toDate"/></time></dd>
        <dt>Former occupation</dt>
        <dd about="this:occupationOfDeceased" property="person:jobTitle" typeof="person:Employment"><xsl:value-of select="occupation"/></dd>
      </dl>
    </section>
  </xsl:template>
</xsl:stylesheet>