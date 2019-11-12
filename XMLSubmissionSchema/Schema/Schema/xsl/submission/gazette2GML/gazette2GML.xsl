<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:u="http://www.williamslea.com/ns/updates" xmlns:wlf="http://www.williamslea.com/xslt/functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:x="http://www.w3.org/1999/xhtml" xmlns:gz="http://www.tso.co.uk/assets/namespace/gazette" xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata" xmlns:wgs84="http://www.w3.org/2003/01/geo/wgs84_pos" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:personal-legal="http://www.thegazette.co.uk/def/personal-legal" xmlns:leg="http://www.thegazette.co.uk/def/legislation" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:gzc="http://www.tso.co.uk/assets/namespace/gazette/LGconfiguration" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:saxon="http://saxon.sf.net/" xmlns:tso="http://www.tso.co.uk/econtent/namespaces/tso" xmlns="http://www.tso.co.uk/assets/namespace/gazette" version="2.0" exclude-result-prefixes="#all">

  <xsl:param name="form">false</xsl:param>

  <!-- Hard coding for the time being, to be London, but it needs to be considered on the form submission -->
  <xsl:param name="edition" as="xs:string" required="no">London</xsl:param>

  <xsl:param name="bundleId" required="no">0</xsl:param>
  <xsl:param name="noticeId" as="xs:string" required="no">0</xsl:param>
  <xsl:param name="status" as="xs:string" required="no">0</xsl:param>
  <xsl:param name="version-count" as="xs:string" required="no">0</xsl:param>
  <xsl:param name="user-submitted" as="xs:string" required="no">0</xsl:param>
  <xsl:param name="pageNumber" required="no">0</xsl:param>
  <xsl:param name="issue" required="no">0</xsl:param>
  <xsl:param name="issue-isbn" as="xs:string" required="no">0</xsl:param>
  <xsl:param name="organisationId" as="xs:string" required="no">0</xsl:param>
  <xsl:param name="debug">false</xsl:param>

  <xsl:param name="updates" as="node()">
    <form noticeTypeCode="2903" draftURI="/my-gazette/draft/2801" draftTitle="Petitions to Wind Up (Companies): Meanwood Widgets Limited">
      <entry about="issue" property="gaz:hasEdition">London</entry>
      <entry about="noticeid:" property="gaz:earliestPublicationDate">2014-01-12</entry>
      <entry about="this:notifiableThing" property="personal-legal:hasClaimDeadline">2014-12-12</entry>
      <entry about="this:notifiableThing" property="gaz:claimNumber">102394</entry>
      <entry about="this:deceasedPerson" property="foaf:familyName">Brown</entry>
      <entry about="this:deceasedPerson" property="foaf:firstName">James</entry>
      <entry about="this:deceasedPerson" property="foaf:givenName">Joseph</entry>
      <entry about="this:deceasedPerson" property="person:hasMaidenName"/>
      <entry about="this:deceasedPerson" property="person:alsoKnownAs">Johnny</entry>
      <entry about="this:deceasedPerson" property="person:alsoKnownAs">Alias 4:30</entry>
      <entry about="this:deceasedPerson" property="person:alsoKnownAs"/>
      <entry about="this:deceasedPerson" property="personal-legal:dateOfDeath">2013-10-20</entry>
      <entry about="this:deceasedPerson" property="personal-legal:startDateOfDeath"/>
      <entry about="this:deceasedPerson" property="personal-legal:endDateOfDeath"/>
      <entry about="this:occupationOfDeceased" property="person:jobTitle">Land Driller</entry>
      <entry about="this:deceased-address-1" property="vcard:street-address">1 London Street</entry>
      <entry about="this:deceased-address-1" property="vcard:extended-address">London</entry>
      <entry about="this:deceased-address-1" property="vcard:locality">Camden</entry>
      <entry about="this:deceased-address-1" property="vcard:region">Norther Sea Side</entry>
      <entry about="this:deceased-address-1" property="vcard:country-name">England</entry>
      <entry about="this:deceased-address-1" property="vcard:postal-code">SE15 1ND</entry>
      <entry about="this:estateExecutor" property="foaf:familyName">John</entry>
      <entry about="this:estateExecutor" property="foaf:firstName">Son</entry>
      <entry about="this:estateExecutor" property="foaf:givenName">Executor</entry>
      <entry about="this:addressOfExecutor-1" property="vcard:street-address">9 Dad's House</entry>
      <entry about="this:estateExecutor" property="vcard:extended-address">House</entry>
      <entry about="this:addressOfExecutor-1" property="vcard:locality">Family Place</entry>
      <entry about="this:addressOfExecutor-1" property="vcard:region">Where we leave</entry>
      <entry about="this:addressOfExecutor-1" property="vcard:country-name">Nothern Ireland</entry>
      <entry about="this:addressOfExecutor-1" property="vcard:postal-code">SE15 1ND</entry>
      <entry about="this:deceased-address-2" property="vcard:street-address">9 Manchester Street</entry>
      <entry about="this:deceased-address-2" property="vcard:extended-address">Manchester</entry>
      <entry about="this:deceased-address-2" property="vcard:region">Southern Scotland</entry>
      <entry about="this:deceased-address-2" property="vcard:country-name">Scotland</entry>
      <entry about="this:deceased-address-2" property="vcard:postal-code">SE15 1ND</entry>
      <entry about="this:deceased-address-3" property="vcard:street-address">45 Sammy Close</entry>
      <entry about="this:deceased-address-3" property="vcard:extended-address">Duesbury</entry>
      <entry about="this:deceased-address-3" property="vcard:region">Lincolnshire</entry>
      <entry about="this:deceased-address-3" property="vcard:country-name">United Kingdom</entry>
      <entry about="this:deceased-address-3" property="vcard:postal-code">MA4 RTG</entry>
    </form>
  </xsl:param>

  <!-- local functions -->

  <xsl:function name="wlf:increment">
    <xsl:param name="propertytoincrement"/>
    <xsl:variable name="numeric" select="number(substring-before(substring-after($propertytoincrement,'['),']')) + 1"/>
    <xsl:variable name="baseproperty" select="substring-before($propertytoincrement,'[')"/>
    <xsl:variable name="newproperty"><xsl:value-of select="$baseproperty"/>[<xsl:value-of select="$numeric"/>]</xsl:variable>
    <xsl:value-of select="$newproperty"/>
  </xsl:function>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="@*">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="ukm:Metadata">
    <ukm:Metadata>
    <xsl:apply-templates/>
    </ukm:Metadata>
  </xsl:template>

  <xsl:template match="ukm:TimeStamp">
    <ukm:TimeStamp><xsl:value-of select="replace(string(current-time()),'Z','')"/></ukm:TimeStamp>
  </xsl:template>

  <xsl:template match="gz:span">
    <xsl:variable name="currentAbout" select="@about"/>
    <xsl:variable name="currentProperty" select="@property"/>
    <xsl:variable name="followOnText" select="."/>
    <xsl:choose>
      <xsl:when test="($updates//*/@property = $currentProperty) and ($updates//*[@property = $currentProperty]/@about = $currentAbout)">
        <xsl:variable name="contents" select="$updates//*/.[@property = $currentProperty and @about = $currentAbout]/text()"/>
        <xsl:if test="$contents!=''"><xsl:value-of select="$contents"/><xsl:value-of select="$followOnText"/></xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="node()[not(self::text()) and not(name()=('ukm:TimeStamp','span'))]">

    <xsl:variable name="currentAbout" select="@about"/>
    <xsl:variable name="currentProperty" select="@property"/>

        <xsl:choose>
          <xsl:when test="($updates//*/@property = $currentProperty) and ($updates//*[@property = $currentProperty]/@about = $currentAbout)">
            <xsl:variable name="contents" select="$updates//*/.[@property = $currentProperty and @about = $currentAbout]/text()"/>
            <xsl:if test="$contents!=''">
              <xsl:copy>
                <xsl:choose>
                  <xsl:when test="$debug = 'true'"><xsl:apply-templates select="@*"/></xsl:when>
                  <xsl:otherwise><xsl:apply-templates select="@*[not(name()='about') and not(name()='property')]"/></xsl:otherwise>
                </xsl:choose>
                
                <xsl:if test="$debug='true'">|||</xsl:if>
                <xsl:choose>
                  <xsl:when test="@datatype = 'xsd:dateTime' and ($updates//*/.[@about=$currentAbout and @property = $currentProperty]/text() != '')"><xsl:value-of select="$updates//*/.[@about=$currentAbout and @property = $currentProperty]/text()"/>T<xsl:value-of select="$updates//*/.[@about=$currentAbout and @property = concat($currentProperty,'WITHtime')]/text()"/>:00</xsl:when>
                  <xsl:otherwise><xsl:value-of select="$contents"/></xsl:otherwise>
                </xsl:choose>
                <xsl:if test="$debug='true'">|||</xsl:if>
              </xsl:copy>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy>
              <xsl:apply-templates select="@* | node()"/>
            </xsl:copy>
          </xsl:otherwise>
        </xsl:choose>

  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="area[not(node())]|bgsound[not(node())]|br[not(node())]|hr[not(node())]|img[not(node())]|input[not(node())]|param[not(node())]">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@*"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>