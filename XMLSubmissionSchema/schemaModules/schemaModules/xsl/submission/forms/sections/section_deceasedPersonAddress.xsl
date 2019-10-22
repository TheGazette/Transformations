<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <!-- lastAddressOfDeceased -->
  
  <xsl:template match="section[@name='deceasedPersonAddress']" mode="RDFa">
    <xsl:variable name="personURI" select="concat(concat(//form/section[@name='deceasedPerson']/personName/forename,//form/section[@name='deceasedPerson']/personName/middleNames),//form/section[@name='deceasedPerson']/personName/surname)"/>
    <xsl:for-each select="address">
      <xsl:variable name="count">
        <xsl:choose>
          <xsl:when test="position() = 1"/>
          <xsl:otherwise><xsl:value-of select="position()"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="previous">
        <xsl:choose>
          <xsl:when test="$count = ''"/>
          <xsl:otherwise>Previous</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <span resource="this:addressOfDeceased{$count}" typeof="vcard:Address"/>
      <span about="this:{$personURI}" property="person:has{$previous}Address" resource="this:addressOfDeceased{$count}"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="section[@name='deceasedPersonAddress']" mode="content">
    <section id="personAddressDetails">
      <header>
        <h2>Former home address of the deceased</h2>
      </header>
      <dl>
        <xsl:for-each select="address">
          <xsl:variable name="count">
            <xsl:choose>
              <xsl:when test="position() = 1"/>
              <xsl:otherwise><xsl:value-of select="position()"/></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="position() = 1"><dt>Person address details:</dt></xsl:when>
            <xsl:otherwise><dt>Person former address details:</dt></xsl:otherwise>
          </xsl:choose>
          <dd about="this:addressOfDeceased{$count}" property="person:houseInformation"><xsl:value-of select="addressLine1"/></dd>
          <xsl:if test="addressLine2 != ''">
            <dd about="this:addressOfDeceased{$count}" property="vcard:street-address"><xsl:value-of select="addressLine2"/></dd>
          </xsl:if>
          <dd about="this:addressOfDeceased{$count}" property="vcard:locality"><xsl:value-of select="locality"/></dd>
          <dd about="this:addressOfDeceased{$count}" property="vcard:region"><xsl:value-of select="region"/></dd>
          <dd about="this:addressOfDeceased{$count}" property="vcard:postalCode"><xsl:value-of select="postcode"/></dd>
        </xsl:for-each>
      </dl>
    </section>
  </xsl:template>
</xsl:stylesheet>