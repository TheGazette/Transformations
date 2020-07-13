<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="2.0">
  <!-- legalInformation -->
  <xsl:template match="section[@name='licenseApplicationDetails']" mode="RDFa"/>
  <xsl:template match="section[@name='licenseApplicationDetails']" mode="content">
    <section xmlns="" id="{@name}">
      <header>
        <h2>License Application Details</h2>
      </header>
      <dl>
        <dt>Name of business or applicant:</dt><dd><xsl:value-of select="nameOfBusinessOrApplicant"/></dd>
        <xsl:apply-templates select="licensableActivities" mode="licensableActivities"/>
      </dl>
    </section>
  </xsl:template>
  
  <xsl:template match="activity" mode="licensableActivities">
    <dt>Licensable activity:</dt><dd><xsl:value-of select="."/></dd>
  </xsl:template>
  
</xsl:stylesheet>