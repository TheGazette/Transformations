<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <!-- noticeDetails -->
  <xsl:template match="section[@name='noticeDetails']" mode="RDFa">
    <xsl:variable name="nId" select="$noticeId"/>
    <span about="http://www.thegazette.co.uk/id/notice/{$nId}" property="dc11:publisher" content="TSO (The Stationery Office), customer.services@thegazette.co.uk"/>			
    <span about="http://www.thegazette.co.uk/id/notice/{$nId}" property="gaz:isAbout" resource="this:notifiableThing"/>
    <span resource="http://www.thegazette.co.uk/id/notice/{$nId}" typeof="gaz:Notice"/>
    <xsl:choose>
      <xsl:when test="//form/@noticeTypeCode = '2903'">
        <!-- Common to all 2903 notices -->
        <span resource="http://thegazette.co.uk/id/notice/{$nId}" typeof="gaz:DeceasedEstatesNotice gaz:WillsAndProbateNotice"/>
        <span resource="this:notifiableThing" typeof="personal-legal:NoticeForClaimsAgainstEstate"/>
        <span about="this:notifiableThing" property="gaz:isRequiredByLegislation" resource="www.legislation.gov.uk/id/ukpga/Geo5/15-16/19/section/27"/>
        <!-- span about="this:notifiableThing" property="personal-legal:hasPersonalRepresentative" resource="this:estateAdministrator"></span>
        <span resource="this:addressOfAdministrator" typeof="vcard:Address"></span>
        <span resource="this:estateAdministrator" typeof="foaf:Agent"></span>
        <span about="this:estateAdministrator" property="vcard:adr" resource="this:addressOfAdministrator"></span -->
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="section[@name='noticeDetails']" mode="content">
    <xsl:variable name="nId" select="$noticeId"/>
    <section id="{@name}">
      <header>
        <h2>Notice details</h2>
      </header>
      <dl>
        <dt>Notice type:</dt>
        <!-- For all notice types -->
        <dd id="noticeType" about="http://www.thegazette.co.uk/id/notice/{$nId}" property="gaz:hasNoticeCode" datatype="xsd:integer"><xsl:value-of select="../@notice-type"/></dd>
        <dt>Notice number:</dt>
        <dd id="noticeNumber" about="http://www.thegazette.co.uk/id/notice/{$nId}" property="gaz:hasNoticeNumber" datatype="xsd:integer">1019636</dd>
        <dt>Publication date:</dt>
        <dd id="publishDate" about="http://www.thegazette.co.uk/id/notice/{$nId}" content="{earliestPublishDate}" datatype="xsd:date" property="gaz:hasPublicationDate"><time datetime="{earliestPublishDate}"><xsl:value-of select="earliestPublishDate"/></time></dd>
        <!-- customizations for specific notice types - this issue really needs to be handled by the incoming schema, not the transform -->
        <xsl:if test="../@notice-type = '2903'">
          <dt>Claim expires:</dt>
          <dd id="dateOfClaimExpire"><time about="this:notifiableThing" content="{claimDeadlineDate}" datatype="xsd:date" datetime="{claimDeadlineDate}" property="gaz:hasClaimDeadline"><xsl:value-of select="claimDeadlineDate"/></time></dd>
        </xsl:if>
      </dl>
    </section>
  </xsl:template>
  
</xsl:stylesheet>