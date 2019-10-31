<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gz="http://www.tso.co.uk/assets/namespace/gazette" xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata" xmlns:wgs84="http://www.w3.org/2003/01/geo/wgs84_pos" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:personal-legal="http://www.thegazette.co.uk/def/personal-legal" xmlns:gzc="http://www.tso.co.uk/assets/namespace/gazette/LGconfiguration" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:fnx="http://www.tso.co.uk/xslt/functions" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xs html" version="2.0">
  <xsl:output method="xml" omit-xml-declaration="yes" indent="no" encoding="UTF-8"/>

 <!-- <xsl:param name="issueNumber" as="xs:string" required="yes"/>-->
  <xsl:param name="edition" as="xs:string" required="yes"/>
  <xsl:param name="legalInformation" required="yes"/>
 <xsl:param name="issueNumber"  required="no"/>
 <xsl:param name="pageNumber" as="xs:string">0</xsl:param>
  <!-- Parameters to create metadata info -->
  <xsl:param name="bundleId" as="xs:string" required="yes"/>
  <xsl:param name="noticeId" as="xs:string" required="yes"/>
  <xsl:param name="status" as="xs:string" required="yes"/>
  <xsl:param name="version-count" as="xs:string" required="yes"/>
  <xsl:param name="user-submitted" as="xs:string" required="yes"/>
  <xsl:param name="mapping" as="node()" required="yes"/>
 
  <xsl:variable name="paramConfigXml" select="if (doc-available('../../configuration/LGconfiguration.xml')) then doc('../../configuration/LGconfiguration.xml') else ()"/>
  <xsl:variable name="gaz">https://www.thegazette.co.uk/</xsl:variable>
  <xsl:variable name="osPostcode" as="xs:string*">http://data.ordnancesurvey.co.uk/ontology/postcode/</xsl:variable>
  <xsl:variable name="osPostcodeUnit" as="xs:string*">http://data.ordnancesurvey.co.uk/id/postcodeunit/</xsl:variable>
  <xsl:variable name="noticeType" select="//gz:Notice/@Type"/>
  <xsl:variable name="noticeNo" select="//gz:Notice/@Reference"/>
  <xsl:variable name="idURI" select="concat($gaz,'id','/notice/', $noticeId)"/>
  <xsl:variable name="documentURI" select="concat($gaz,'notice/', $noticeId)"/>
  <xsl:variable name="publishDate" select="//ukm:PublishDate"/>
  <xsl:variable name="noticeURI" select="concat($gaz,'id','/notice/', $noticeId)"/>

  <xsl:variable name="fullName">
    <xsl:value-of select="//gz:Person/gz:PersonName/gz:Forename"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="//gz:Person/gz:PersonName/gz:MiddleNames"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="//gz:Person/gz:PersonName/gz:Surname"/>
  </xsl:variable>
  <xsl:variable name="personFullName" select="replace($fullName,'\s+',' ')"/>
  <xsl:variable name="personURI" select="string-join(('this:','deceasedPerson'),'')"/>
  
   <xsl:variable name="category">
     <xsl:sequence select="$mapping//*:Map[@Code = $noticeType]/*"/>
   </xsl:variable>
  
  <xsl:template match="/">
    <xsl:variable name="noticeContents">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:call-template name="displayNoticeData">
      <xsl:with-param name="noticeContents" select="$noticeContents"/>
    </xsl:call-template>

  </xsl:template>

  <xsl:template name="displayNoticeData">
    <xsl:param name="noticeContents" required="yes"/>
    <xsl:variable name="noticeContentswithSection">
      <article>
        <xsl:for-each-group select="$noticeContents/html:article/*" group-adjacent="boolean(self::html:dl)">
          <xsl:choose>
            <xsl:when test="current-grouping-key()">
              <dl>
                <xsl:for-each select="current-group()">
                  <xsl:copy-of select="*"/>
                </xsl:for-each>
              </dl>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="current-group()">
                <xsl:copy-of select="."/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
      </article>
    </xsl:variable>
    <html prefix="gaz: https://www.thegazette.co.uk/def/publication#       person: https://www.thegazette.co.uk/def/person#         personal-legal: https://www.thegazette.co.uk/def/personal-legal#        org: http://www.w3.org/ns/org# this: {$idURI}# prov: http://www.w3.org/ns/prov#">
      <xsl:attribute name="DocumentURI" select="$documentURI"/>
      <xsl:attribute name="IdURI" select="$idURI"/>
      <xsl:attribute name="version">XHTML+RDFa 1.1</xsl:attribute>
      <head>
        <title>
          <xsl:value-of select="$paramConfigXml//gzc:Notice[@Code = $noticeType]/gzc:Name"/>
        </title>
        <!-- metadata-->
        <gazette-metadata xmlns="http://www.gazettes.co.uk/metadata">
          <bundle-id><xsl:value-of select="$bundleId"/></bundle-id>
          <notice-id><xsl:value-of select="$noticeId"/></notice-id>
          <status><xsl:value-of select="$status"/></status>
          <version-count>
            <xsl:value-of select="$version-count"/>
          </version-count>
          <notice-code>
            <xsl:value-of select="$noticeType"/>
          </notice-code>
          <xsl:sequence select="$category"/>
          <notice-capture-method>gazette-schema-xml</notice-capture-method>
          <notice-logo>
             <xsl:value-of select="//*[local-name()='Image']"/>
          </notice-logo>          
          <edition>
            <xsl:value-of select="$edition"/>
          </edition>
          <xsl:if test="$issueNumber">
            <issue>
              <xsl:value-of select="$issueNumber"/>
            </issue>
            <page-number>
              <xsl:value-of select="$pageNumber"/>
            </page-number>
          </xsl:if>
          <legacy-notice-number>
            <xsl:value-of select="$noticeNo"/>
          </legacy-notice-number>
          <user-submitted>
            <xsl:value-of select="$user-submitted"/>
          </user-submitted>
        </gazette-metadata>
      </head>
      <body>
        <article>
          <!-- loop for putting all dd/dt inside single dd inside <secion> structure-->
          <xsl:for-each select="$noticeContentswithSection/html:article/*">
            <xsl:choose>
              <xsl:when test="self::html:section">
                <section>
                  <xsl:copy-of select="@*"/>
                  <xsl:for-each-group select="./*" group-adjacent="boolean(self::html:dl)">
                    <xsl:choose>
                      <xsl:when test="current-grouping-key()">
                        <div class="content">
                          <dl>
                            <xsl:for-each select="current-group()">
                              <xsl:copy-of select="*"/>
                            </xsl:for-each>
                          </dl>
                        </div>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:for-each select="current-group()">
                          <xsl:choose>
                            <!-- For nested <section> structure-->
                            <xsl:when test="self::html:section">
                              <section>
                                <xsl:copy-of select="@*"/>
                                <xsl:for-each-group select="./*" group-adjacent="boolean(self::html:dl)">
                                  <xsl:choose>
                                    <xsl:when test="current-grouping-key()">
                                      <div class="content">
                                        <dl>
                                          <xsl:for-each select="current-group()">
                                            <xsl:copy-of select="*"/>
                                          </xsl:for-each>
                                        </dl>
                                      </div>
                                    </xsl:when>
                                    <xsl:otherwise>
                                      <xsl:for-each select="current-group()">
                                        <xsl:copy-of select="."/>
                                      </xsl:for-each>
                                    </xsl:otherwise>
                                  </xsl:choose>
                                </xsl:for-each-group>
                              </section>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:copy-of select="."/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:for-each>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each-group>
                </section>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </article>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="gz:Notice">
    <xsl:variable name="noticeNo" select="@Reference"/>
    <xsl:variable name="noticeCode" select="@Type"/>
    <xsl:variable name="editionURI" select="concat($gaz,'id/','edition/',$edition)"/>
    <xsl:variable name="noticeDate" select="ukm:Metadata/ukm:PublishDate"/>
    <xsl:variable name="personSurname" select="gz:Person/gz:PersonName/gz:Surname"/>
    <xsl:variable name="personForename" select="gz:Person/gz:PersonName/gz:Forename"/>
    <xsl:variable name="personMiddleNames" select="gz:Person/gz:PersonName/gz:MiddleNames"/>
    <xsl:variable name="personAddress" select="gz:Person/gz:PersonDetails"/>
    <xsl:variable name="oldNoticeURI" select="concat($gaz,'id/','edition/',$edition,'/issue/',$issueNumber,'/notice/', $noticeNo)"/>
    <xsl:variable name="issueURI" select="concat($gaz,'id/','edition/',$edition,'/issue/',$issueNumber)"/>
    
    <xsl:variable name="deathDate" select="gz:Person/gz:DeathDetails/gz:Date/@Date"/>
    <xsl:variable name="birthDate" select="gz:Person/gz:BirthDetails/gz:Date/@Date"/>
    <xsl:variable name="deathDateText" select="gz:Person/gz:DeathDetails/gz:Date"/>

    <xsl:variable name="claimsDate" select="gz:Person/gz:DeathDetails/gz:NoticeOfClaimsDate/@Date"/>
    <xsl:variable name="claimsDateText" select="gz:Person/gz:DeathDetails/gz:NoticeOfClaimsDate"/>
    <article>
      <!-- h1>
        <xsl:value-of select="$paramConfigXml//gzc:Notice[@Code = $noticeType]/gzc:Name"/>
      </h1 -->
      <!-- Notice -->
      <div class="rdfa-data">
        <!-- Needed for all notices -->
        <span about="{$noticeURI}" property="dc11:publisher" content="TSO (The Stationery Office), customer.services@thegazette.co.uk"/>
        <span about="{$noticeURI}" property="gaz:isAbout" resource="this:notifiableThing"/>
        <!-- <span about="{$noticeURI}" property="owl:sameAs" resource="https://www.thegazette.co.uk/id/notice/{$noticeId}"/>-->
        <span about="{$noticeURI}" property="prov:has_provenance" resource="https://www.thegazette.co.uk/id/notice/{$noticeId}/provenance"/>
      
        <span resource="{$editionURI}" typeof="gaz:Edition"/>

        <span about="https://www.thegazette.co.uk/id/notice/{$noticeId}" property="gaz:hasNoticeNumber" datatype="xsd:integer" content="{$noticeNo}"/>

        <xsl:if test="$issueNumber">
          <span about="{$noticeURI}" property="gaz:isInIssue" resource="{$issueURI}"/>
          <span resource="{$issueURI}" typeof="gaz:Issue"/>
          <span about="{$issueURI}" property="gaz:hasEdition" resource="{$editionURI}"/>
          <span about="{$issueURI}" content="{$issueNumber}" datatype="xsd:string" property="gaz:hasIssueNumber"/>
          <span about="https://www.thegazette.co.uk/id/notice/{$noticeId}" property="owl:sameAs" resource="https://www.thegazette.co.uk/id/edition/{$edition}/issue/{$issueNumber}/notice/{$noticeNo}" typeof="gaz:Notice"/>
          <span about="https://www.thegazette.co.uk/id/notice/{$noticeId}" property="prov:alternateOf" resource="http://www.{lower-case($edition)}-gazette.co.uk/id/issues/{$issueNumber}/notices/{$noticeNo}" typeof="gaz:Notice"/>
          <span about="https://www.thegazette.co.uk/id/notice/{$noticeId}" property="gaz:hasNoticeNumber" datatype="xsd:integer" content="{$noticeNo}"/>
        </xsl:if>

        <span about="{$noticeURI}" property="gaz:isRequiredByLegislation" resource="http://www.legislation.gov.uk/ukpga/Geo5/15-16/19/section/27"/>
        <!-- Common to all 2903 notices -->
        <xsl:choose>
          <xsl:when test="$noticeCode = '2903'">
            <span resource="this:notifiableThing" typeof="personal-legal:NoticeForClaimsAgainstEstate/"/>

            <span about="this:notifiableThing" property="personal-legal:hasPersonalRepresentative" resource="this:estateExecutor"/>
            <span resource="this:addressOfDeceased-address-1" typeof="vcard:Address"/>
            <span resource="this:addressOfExecutor" typeof="vcard:Address"/>
            <span resource="this:estateExecutor" typeof="foaf:Agent"/>
            <span about="this:estateExecutor" property="vcard:adr" resource="this:addressOfExecutor"/>
            <!-- Needed for all 2903 notices -->
            <span resource="{$noticeURI}" typeof="gaz:DeceasedEstatesNotice gaz:WillsAndProbateNotice gaz:Notice"/>
            <span about="this:notifiableThing" property="personal-legal:hasEstateOf" resource="{$personURI}"/>
            <span about="{$personURI}" typeof="gaz:Person"/>
            <span about="{$personURI}" property="person:hasAddress" resource="this:addressOfDeceased-address-1"/>
            <span about="{$personURI}" content="{$personFullName}" property="foaf:name"/>
          </xsl:when>

        </xsl:choose>

      </div>

      <dl>
        <!--Notice Details -->

        <dt>Notice type:</dt>
        <dd property="gaz:hasNoticeCode" datatype="xsd:integer" about="{$noticeURI}">
          <xsl:value-of select="$noticeCode"/>
        </dd>
      </dl>
      <xsl:apply-templates select="gz:Person/gz:DeathDetails/gz:NoticeOfClaimsDate"/>
      <dl>
        <dt>Edition:</dt>
        <dd>
			<xsl:text>The </xsl:text>
			<span about="{$editionURI}" property="gaz:editionName" datatype="xsd:string">
			  <xsl:value-of select="$edition"/>
			</span>
			<xsl:text> Gazette</xsl:text>
        </dd>
        <xsl:if test="$issueNumber">
          <dt>Issue number:</dt>
          <dd about="{$issueURI}" property="gaz:hasIssueNumber" datatype="xsd:string">
            <xsl:value-of select="$issueNumber"/>
          </dd>
           <dt>Page number:</dt>
          <dd data-gazettes="page-number">
            <xsl:value-of select="$pageNumber"/>
          </dd>
        </xsl:if>

        <dt>Notice ID:</dt>
        <!-- updated to add  attribute gz:hasNoticeNumber-->
        <dd about="{$noticeURI}" property="gaz:hasNoticeID">
          <xsl:value-of select="$noticeId"/>
        </dd>
      </dl>
     
      <!-- details from Metadata-->
      <xsl:apply-templates select="ukm:Metadata/ukm:PublishDate"/>
      <!-- Paul Relfe: it's all admin metadata so ok to lose/ditch
                 <xsl:apply-templates select="ukm:Metadata/ukm:KeyedBy"/>
                <xsl:apply-templates select="ukm:Metadata/ukm:SupplierNoticeID"/>-->

      <xsl:apply-templates/>
      <xsl:if test="$legalInformation != ''">
        <section>
          <h2>Legal information</h2>
          <p>
            <xsl:value-of select="$legalInformation"/>
          </p>
        </section>
      </xsl:if>
    </article>
  </xsl:template>

  <xsl:template match="ukm:Metadata"/>

  <!-- Metadata Details-->
  <xsl:template match="ukm:PublishDate">
    <dl>
      <dt>Publication date:</dt>
	  <xsl:variable name="publishDate" select="concat(.,'T',(if (following-sibling::ukm:TimeStamp) then fnx:getTimeStamp(following-sibling::ukm:TimeStamp) else '01:00:00'))"/>
      <dd about="{$noticeURI}" property="gaz:hasPublicationDate" content="{$publishDate}" datatype="xsd:dateTime">
        <time datetime="{$publishDate}">
          <xsl:value-of select="format-dateTime(xs:dateTime($publishDate),'[D] [MNn] [Y] [h]:[m]:[s] [P]')"/>
        </time>
      </dd>
    </dl>
  </xsl:template>



  <!--New Mapping -->

  <xsl:template match="gz:NoticeHeading">
    <dl>
      <dt>Notice heading:</dt>
      <dd id="noticeHeading">
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:Substitution">
    <dl>
      <dt>Substitution:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:Retraction">
    <dl>
      <dt>Retraction:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:Authority">
    <dl>
      <dt>Authority:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:Title">
    <dl>
      <dt>Title:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:DefinedAs">
    <dl>
      <dt>Defined as:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <!-- Person Details -->
  <xsl:template match="gz:Person">

    <xsl:apply-templates select="* except(gz:PersonDetails,gz:PersonAddress)"/>
    <xsl:apply-templates select="gz:PersonDetails | gz:DeathDetails/gz:NoticeOfClaims | gz:PersonAddress"/>
  </xsl:template>
  <!-- updated to add  attribute foaf:familyName -->
  <xsl:template match="gz:Surname">
    <dl>
      <dt>Surname:</dt>
      <dd property="foaf:familyName" typeof="gaz:Person" about="{$personURI}">
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <!-- updated to add  attribute foaf:firstName-->
  <xsl:template match="gz:Forename">
    <dl>
      <dt>First name:</dt>
      <dd property="foaf:firstName" typeof="gaz:Person" about="{$personURI}">
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:Initials">
    <dl>
      <dt>Initials:</dt>
      <dd id="initials">
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:Salutation">
    <dl>
      <dt>Salutation:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <!-- updated to add  attribute foaf:givenName-->
  <xsl:template match="gz:MiddleNames">
    <dl>
      <dt>Middle name(s):</dt>
      <dd property="foaf:givenName" typeof="gaz:Person" about="{$personURI}">
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:AlsoKnownAs">
    <dl>
      <dt>Alternative name</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:PersonDetails">


    <dl>
      <dt>Person address details:</dt>
      <dd about="this:addressOfDeceased-address-1" typeof="vcard:Address" property="vcard:address">
        <xsl:apply-templates/>
      </dd>
    </dl>

  </xsl:template>
  <xsl:template match="gz:PersonStatus">
    <dl>
      <dt>Person status:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:Occupation">
    <dl>
      <dt>Former occupation:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:PersonAddress">

    <dl>
      <dt>
        <xsl:value-of select="if ($noticeType='2903') then 'Former home address of the deceased:' else 'Former home address of the person:'"/>
      </dt>
      <dd about="this:addressOfDeceased-address-1" typeof="vcard:Address" property="vcard:address">
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <!-- birth Details -->
  <xsl:template match="gz:BirthDetails">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="gz:BirthDetails/gz:Date">
    <dl>
      <dt>Date of birth:</dt>
      <dd property="personal-legal:bornOn" typeof="gaz:Person" datatype="xsd:date" about="{$personURI}" content="{@Date}">
        <time datetime="{@Date}">
          <xsl:apply-templates/>
        </time>
      </dd>
    </dl>
  </xsl:template>

  <!-- Death Details-->
  <xsl:template match="gz:DeathDetails">
    <xsl:apply-templates select="* except(gz:NoticeOfClaimsDate,gz:NoticeOfClaims)"/>
  </xsl:template>
  <xsl:template match="gz:DeathDetails/gz:Date">
    <dl>
      <dt>Date of death:</dt>
      <dd property="personal-legal:dateOfDeath" typeof="gaz:Person" datatype="xsd:date" about="{$personURI}" content="{@Date}">
        <time datetime="{@Date}">
          <xsl:apply-templates/>
        </time>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:NoticeOfClaims">

    <dl>
      <dt>Executor/Administrator:</dt>
      <dd about="this:estateExecutor" property="foaf:name" typeof="foaf:Agent">
        <xsl:apply-templates/>
      </dd>
    </dl>

  </xsl:template>
  <xsl:template match="gz:NoticeOfClaimsDate">
    <dl>
      <dt>Claim expires:</dt>
      <dd about="this:notifiableThing" property="personal-legal:hasClaimDeadline" datatype="xsd:date" content="{@Date}">
        <time datetime="{@Date}">
          <xsl:apply-templates/>
        </time>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:Legislation">
    <dl>
      <dt>Legislation:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:LegislationType">
    <dl>
      <dt>Legislation type:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:LegislationSubType">
    <dl>
      <dt>Legislation Sub type:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <!--- Company Details-->
  <xsl:template match="gz:Company">

    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="gz:CompanyName">
    <dl>
      <dt>Company name:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:CompanyOtherNames">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="gz:TradingAs">
    <dl>
      <dt>Trading as:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:CompanyPrevious">

    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="gz:CompanyRegisteredCountries">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="gz:CompanyRegisteredCountry">
    <dl>
      <dt>Company registered country:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:CompanyNumber">
    <dl>
      <dt>Company number:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <!-- check for span, character, Addressline-->
  <xsl:template match="gz:CompanyRegisteredOffice">
    <dl>
      <dt>Registered office:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <!-- check for span, character, Addressline-->
  <xsl:template match="gz:PrincipalTradingAddress">
    <dl>
      <dt>Principal trading address:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:CompanyStatus">
    <dl>
      <dt>Company status:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:NatureOfBusiness">
    <dl>
      <dt>Nature of business:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:TradeClassification">
    <dl>
      <dt>Trade classification:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:CompanyGroup">

    <xsl:apply-templates/>
  </xsl:template>

  <!-- Parternership Details -->
  <xsl:template match="gz:Partnership">

    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="gz:PartnershipName">
    <dl>
      <dt>Partnership name:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <!-- check for span, character, Addressline-->
  <xsl:template match="gz:PartnershipAddress">
    <dl>
      <dt>Partnership address:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <!--EmphasisBasicStructure-->
  <xsl:template match="gz:PartnershipNumber">
    <dl>
      <dt>Partnership number:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <!--type="InlineFullStructure"-->
  <xsl:template match="gz:PartnershipDetails">
    <dl>
      <dt>Partnership details:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:PartnershipPrevious">

    <xsl:apply-templates/>
  </xsl:template>
  <!-- Trading Details-->
  <xsl:template match="gz:TradingDetails">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="gz:TradingPrevious">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="gz:TradingAddress">
    <dl>
      <dt>Trading address:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <!--- Socitey Details-->
  <xsl:template match="gz:Society">

    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="gz:SocietyName">
    <dl>
      <dt>Society name:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:SocietyNumber">
    <dl>
      <dt>Society number:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <!--- Court Details-->
  <xsl:template match="gz:Court">

    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="gz:CourtName">
    <dl>
      <dt>Court name:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:CourtDistrict">
    <dl>
      <dt>Court district:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:CourtNumber">
    <dl>
      <dt>Court number:</dt>
      <dd>
        <xsl:choose>
          <xsl:when test="@Number">
            <xsl:value-of select="@Number"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:Court/gz:CourtPrevious">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="gz:PetitionFilingDate">
    <dl>
      <dt>Petition filing date:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:BankruptcyOrderDate">
    <dl>
      <dt>Bankruptcy order date:</dt>
      <dd id="bankruptcyOrderDate">
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:BankruptcyOrderTime">
    <dl>
      <dt>Bankruptcy order time:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:BankruptcyRestrictions">
    <dl>
      <dt>Bankruptcy restrictions:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:WindingUpOrderDate">
    <dl>
      <dt>WindingUp order date:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:VolWindingUpResolutionDate">
    <dl>
      <dt>VolWindingUp resolution date:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:IVAdate">
    <dl>
      <dt>IVA date:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:DateOfAnnulment">
    <dl>
      <dt>Date of annulment:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:GroundsOfAnnulment">
    <dl>
      <dt>Grounds of annulment:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:DateOfDischarge">
    <dl>
      <dt>Date of discharge:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:DateOfCertificateOfDischarge">
    <dl>
      <dt>Date of certificate of discharge:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:TypeOfPetition">
    <dl>
      <dt>Type of petition:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:Petitioner">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="gz:PetitionerName">
    <dl>
      <dt>Petitioner name:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:PetitionerAddress">
    <dl>
      <dt>Petitioner address</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:RelatedCase">

    <xsl:apply-templates/>
  </xsl:template>

  <!-- Para Structure-->
  <xsl:template match="gz:P | gz:P1group | gz:P2group | gz:P3group | gz:P4group | gz:P1 | gz:P2 | gz:P3 | gz:P4 | gz:P1para | gz:P2para | gz:P3para | gz:P4para | gz:ForceP">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="gz:Text">
    <xsl:choose>
      <xsl:when test="text() and not(child::* except(gz:Strong,gz:Emphasis,gz:Span))">
        <p data-p="{name(parent::node())}">
          <xsl:apply-templates/>
        </p>
      </xsl:when>
      <xsl:when test="text() and child::*">
        <p data-p="{name(parent::node())}">
          <xsl:apply-templates/>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="gz:Text/*">
    <span data-p="{name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="gz:Pnumber">
    <p data-p="{name()}">
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <!-- Table structure details-->
  <!-- Parent - Notice -->
  <xsl:template match="gz:Tabular">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="gz:Number">
    <dl>
      <dd>Number:</dd>
      <dt>
        <xsl:apply-templates/>
      </dt>
    </dl>
  </xsl:template>
  <xsl:template match="gz:TableText">
    <dl>
      <dd>Table text:</dd>
      <dt>
        <xsl:apply-templates/>
      </dt>
    </dl>
  </xsl:template>
  <xsl:template match="html:table">
    <table>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  <xsl:template match="html:caption">
    <caption>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </caption>
  </xsl:template>
  <xsl:template match="html:colgroup">
    <colgroup>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </colgroup>
  </xsl:template>
  <xsl:template match="html:col">
    <col>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </col>
  </xsl:template>
  <xsl:template match="html:thead">
    <thead>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </thead>
  </xsl:template>
  <xsl:template match="html:tfoot">
    <tfoot>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </tfoot>
  </xsl:template>
  <xsl:template match="html:tbody">
    <tbody>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </tbody>
  </xsl:template>
  <xsl:template match="html:tr">
    <tr>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>
  <xsl:template match="html:td">
    <td>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>
  <xsl:template match="html:th">
    <th>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </th>
  </xsl:template>


  <!--Note Details-->
  <xsl:template match="gz:Note">
    <xsl:apply-templates/>
  </xsl:template>

  <!--- Administration Details-->
  <xsl:template match="gz:Administration">
    <!--<dt>Details of the administrator</dt>-->

    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="gz:Appointer">
    <dl>
      <dt>Apponiter:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:AdministrationOrderMade">
    <dl>
      <dt>Order mode:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:DateOfAppointment">
    <dl>
      <dt>Date of appointment:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:Administrator">
    <xsl:choose>
      <xsl:when test="text() and not(child::*)">
        <dl>
          <dt>Administrator:</dt>
          <dd>
            <xsl:apply-templates/>
          </dd>
        </dl>
      </xsl:when>
      <xsl:when test="not(text()) and child::*">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="text() and child::*">
        <p data-p="{name()}">
          <xsl:value-of select="replace(.,'\s+',' ')" disable-output-escaping="no"/>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="gz:AdditionalContact">
    <dl>
      <dt>Additional contact:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:OfficeHolderNumbers">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="gz:OfficeHolderNumber">
    <dl>
      <dt>Office holder number:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:OfficeHolderCapacity">
    <dl>
      <dt>Office holder capacity:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="gz:DateSigned">
    <dl>
      <dt>Date signed:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>

  <!--- Parant-Notice-->
  <xsl:template match="gz:Pblock | gz:PsubBlock">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="gz:Ref">
    <dl>
      <dd>Ref:</dd>
      <dt>
        <xsl:apply-templates/>
      </dt>
    </dl>
  </xsl:template>

  <xsl:template match="gz:Emphasis">
    <i>
      <xsl:apply-templates/>
    </i>
  </xsl:template>
  <xsl:template match="gz:Span">
    <span data-p="{name(parent::node())}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="gz:Character">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="gz:AddressLineGroup">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="gz:Telephone">
    <dl>
      <dt>Telephone:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:FirmName">
    <dl>
      <dt>Firm name:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:Email">
    <dl>
      <dt>Email:</dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template match="gz:Image">
    <img>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </img>
  </xsl:template>
  <xsl:template match="gz:Para">
    <xsl:choose>
      <xsl:when test="text() and not(child::*)">
        <p data-para="">
          <xsl:apply-templates/>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="gz:Strong">
    <b>
      <xsl:apply-templates/>
    </b>
  </xsl:template>
  <xsl:template match="text()">
    <xsl:value-of select="replace(.,'\s+',' ')" disable-output-escaping="no"/>
  </xsl:template>

  <xsl:function name="fnx:getTimeStamp">
		<xsl:param name="arg"/>
		<xsl:choose>
			<xsl:when test="$arg castable as xs:time">
				<xsl:value-of select="$arg"/>
			</xsl:when>
			<xsl:otherwise>
			<xsl:analyze-string select="$arg" regex="^([0-9]*):([0-9]*):([0-9]*)([.0-9]*)">
				<xsl:matching-substring>
				<xsl:value-of select="concat(fnx:get2Digits(regex-group(1)),':', fnx:get2Digits(regex-group(2)),':',fnx:get2Digits(regex-group(3)))"/>
				</xsl:matching-substring>

				<xsl:non-matching-substring>
				<xsl:value-of select="$arg"/>
				</xsl:non-matching-substring>
			</xsl:analyze-string>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xsl:function name="fnx:get2Digits">
	  <xsl:param name="arg"/>
	  <xsl:value-of select="if ($arg castable as xs:integer and xs:integer($arg) &lt; 10) then format-number(number($arg),'00') else $arg"/>
	</xsl:function>

</xsl:stylesheet>