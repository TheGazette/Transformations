<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <!-- legalInformation -->
  <xsl:template match="section[@name='legalInformation']" mode="RDFa"/>
  <xsl:template match="section[@name='legalInformation']" mode="content">
    <section id="{@name}">
      
    </section>
  </xsl:template>
</xsl:stylesheet>