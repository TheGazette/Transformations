<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="2.0">
  <!-- lastAddressOfDeceased -->
  <xsl:template match="section[@name='locationOfLicensableActivity']" mode="RDFa"/>
  <xsl:template match="section[@name='locationOfLicensableActivity']" mode="content">
    <section xmlns="" id="personAddressDetails">
      <header>
        <h2>Location of Licensable Activity</h2>
      </header>
      <dl>
        <dt>Location of Licensable Activity:</dt>
        <!-- Properly separated when derived from web form -->
        <dd about="this:addressOfLicensableActivity" property="person:houseInformation"><xsl:value-of select="houseNumberOrName"/></dd>
        <dd about="this:addressOfLicensableActivity" property="vcard:street-address"><xsl:value-of select="streetAddress"/></dd>
        <dd about="this:addressOfLicensableActivity" property="vcard:locality"><xsl:value-of select="locality"/></dd>
        <dd about="this:addressOfLicensableActivity" property="vcard:region"><xsl:value-of select="region"/></dd>
        <dd about="this:addressOfLicensableActivity" property="vcard:postalCode"><xsl:value-of select="postcode"/></dd>
      </dl>
    </section>
  </xsl:template>
</xsl:stylesheet>