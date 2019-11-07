<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <!-- legalInformation -->
  <xsl:template match="section[@name='licensingExtras']" mode="RDFa"/>
  <xsl:template match="section[@name='licensingExtras']" mode="content">
    <section id="{@name}">
      <header>
        <h2>License Application Details</h2>
      </header>
      <dl>
        <xsl:apply-templates select="extras" mode="licensingExtras"/>
      </dl>
    </section>
  </xsl:template>
  
  <xsl:template match="extra" mode="licensingExtras">
    <dt>Licensing extra:</dt><dd><xsl:value-of select="."/></dd>
  </xsl:template>
  
</xsl:stylesheet>