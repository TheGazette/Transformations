<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <!-- legalInformation -->
  <xsl:template match="section[@name='detailsOfTheAppointment']" mode="RDFa"/>
  <xsl:template match="section[@name='detailsOfTheAppointment']" mode="content">
    <section id="{@name}">
      <header>
        <h2>Details of the Appointment</h2>
      </header>
      <dl>
        <dt>Appointment title:</dt><dd><xsl:value-of select="appointmentTitle"/></dd>
        <dt>Authority name:</dt><dd><xsl:value-of select="authorityName"/></dd>
      </dl>
    </section>
  </xsl:template>
</xsl:stylesheet>