<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="2.0">
  <!-- noticeDetails -->
  <xsl:template match="section[@name='notifiableThing']" mode="additional"/>
  <xsl:template match="section[@name='notifiableThing']" mode="RDFa">
    <xsl:variable name="nId" select="$noticeId"/>
    <span about="https://www.thegazette.co.uk/id/notice/{$nId}" property="dc11:publisher" content="TSO (The Stationery Office), St Crispins, Duke Street, Norwich, NR3 1PD, 01603 622211, customer.services@tso.co.uk"/>			
    <span about="https://www.thegazette.co.uk/id/notice/{$nId}" property="gaz:isAbout" resource="this:notifiableThing"/>
    <span resource="https://www.thegazette.co.uk/id/notice/{$nId}" typeof="gaz:Notice"/>
    <span about="https://www.thegazette.co.uk/id/notice/{$nId}" property="prov:has_provenance" resource="https://www.thegazette.co.uk/id/notice/{$nId}/provenance"/>
    <span about="https://www.thegazette.co.uk/id/notice/{$nId}" property="gaz:earliestPublicationDate" content="{../section/earliestPublicationDate}" datatype="xsd:date"/>
    <xsl:choose>
      <xsl:when test="//form/@noticeTypeCode = '2903'">
        <!-- Common to all 2903 notices -->
        <span resource="https://www.thegazette.co.uk/id/notice/{$nId}" typeof="gaz:DeceasedEstatesNotice gaz:WillsAndProbateNotice"/>
        <span resource="this:notifiableThing" typeof="personal-legal:NoticeForClaimsAgainstEstate"/>
        <span about="https://www.thegazette.co.uk/id/notice/{$noticeId}" property="gaz:isRequiredByLegislation" resource="http://www.legislation.gov.uk/id/ukpga/Geo5/15-16/19/section/27"/>
        <!-- span about="this:notifiableThing" property="personal-legal:hasPersonalRepresentative" resource="this:estateAdministrator"></span>
        <span resource="this:addressOfAdministrator" typeof="vcard:Address"></span>
        <span resource="this:estateAdministrator" typeof="foaf:Agent"></span>
        <span about="this:estateAdministrator" property="vcard:adr" resource="this:addressOfAdministrator"></span -->
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="section[@name='notifiableThing']" mode="content">
    <xsl:variable name="nId" select="$noticeId"/>
    <!-- section id="{@name}">
      <header>
        <h2>Notifiable Thing</h2>
      </header>
      <dl -->
        <dt>Notice type:</dt>
        <!-- For all notice types -->
        <dd about="https://www.thegazette.co.uk/id/notice/{$nId}" property="gaz:hasNoticeCode" datatype="xsd:integer"><xsl:value-of select="/form/@noticeTypeCode"/></dd>
        <dt>Notice ID:</dt>
        <dd about="https://www.thegazette.co.uk/id/notice/{$nId}" property="gaz:hasNoticeID"><xsl:value-of select="$nId"/></dd>
        <!-- dt>Notice number:</dt>
        <dd id="noticeNumber" about="http://www.thegazette.co.uk/id/notice/{$nId}" property="gaz:hasNoticeNumber" datatype="xsd:integer">1019636</dd -->
        <dt>Publication date:</dt>
        <dd about="https://www.thegazette.co.uk/id/notice/{$nId}" content="{//form/section/earliestPublicationDate}" datatype="xsd:date" property="gaz:hasPublicationDate dc:issued"><time datetime="{/form/section/earliestPublicationDate}"><xsl:value-of select="//form/section/earliestPublicationDate"/></time></dd>
        <!-- customizations for specific notice types - this issue really needs to be handled by the incoming schema, not the transform -->
        <xsl:if test="//form/@noticeTypeCode = '2903'">
          <dt>Claim expires:</dt>
          <dd about="this:notifiableThing" content="{hasClaimDeadline}" datatype="xsd:date" property="personal-legal:hasClaimDeadline"><time datetime="{hasClaimDeadline}"><xsl:value-of select="hasClaimDeadline"/></time></dd>
        </xsl:if>
      <!-- /dl>
    </section -->
  </xsl:template>
  
</xsl:stylesheet>