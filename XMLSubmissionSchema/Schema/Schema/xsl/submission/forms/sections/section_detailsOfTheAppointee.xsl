<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:foaf="http://www.gazettes-online.co.uk/ontology/foaf" version="2.0">
  <!-- legalInformation -->
  <xsl:template match="section[@name='detailsOfTheAppointee']" mode="RDFa"/>
  <xsl:template match="section[@name='detailsOfTheAppointee']" mode="content">
    <section id="detailsOfTheAppointee">
      <header>
        <h2>Details of the Appointee</h2>
        <dl>
          <dt>Surname:</dt><dd about="this:{replace(concat(firstname,surname),' ','')}" foaf:familyName="{surname}" id="surName" property="foaf:familyName" typeof="gaz:Person"><xsl:value-of select="surname"/></dd>
          <dt>First name:</dt><dd about="this:{replace(concat(firstname,surname),' ','')}" foaf:firstName="{firstname}" id="foreName" property="foaf:firstName" typeof="gaz:Person"><xsl:value-of select="firstname"/></dd>
          <dt>Middlename:</dt><dd about="this:{replace(concat(firstname,surname),' ','')}" foaf:givenName="{middlename}" id="middleName" property="foaf:givenName" typeof="gaz:Person"><xsl:value-of select="middlename"/></dd>
        </dl>
      </header>
    </section>
  </xsl:template>
</xsl:stylesheet>