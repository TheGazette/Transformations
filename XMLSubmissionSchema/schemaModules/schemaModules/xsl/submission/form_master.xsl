<?xml version="1.0" encoding="UTF-8"?>
<!--Â©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
<!--Version 1.0-->
<!--Created by Williams Lea XML Team-->
<!--
	  Purpose of transform: incorporate the Java layer draft format into an HTMLRDFa format document 
	  
      Change history
      1.0 Initial Release: 20th January 2014
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:u="http://www.williamslea.com/ns/updates" xmlns:wlf="http://www.williamslea.com/xslt/functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:x="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="u wlf xsl xs x">
	<xsl:output method="xhtml" indent="no" encoding="UTF-8"/>
	<xsl:param name="form">false</xsl:param>
	<!-- Hard coding for the time being, to be London, but it needs to be considered on the form submission -->
	<xsl:param name="edition" as="xs:string" required="no">Default</xsl:param>
	<xsl:param name="bundleId" required="no">0</xsl:param>
	<xsl:param name="noticeId" as="xs:string" required="no">0</xsl:param>
	<xsl:param name="status" as="xs:string" required="no">0</xsl:param>
	<xsl:param name="submitted-date" as="xs:dateTime" required="no">
		<xsl:value-of select="current-dateTime()"/>
	</xsl:param>
	<xsl:param name="countyCourts" as="node()" select="doc('')"/>
	<xsl:param name="version-count" as="xs:string" required="no">0</xsl:param>
	<xsl:param name="user-submitted" as="xs:string" required="no">0</xsl:param>
	<xsl:param name="pageNumber" required="no">0</xsl:param>
	<xsl:param name="issue" required="no">0</xsl:param>
	<xsl:param name="issue-isbn" as="xs:string" required="no">0</xsl:param>
	<xsl:param name="organisationId" as="xs:string" required="no">0</xsl:param>
	<xsl:param name="debug">false</xsl:param>
	<xsl:param name="mapping" as="node()">
		<a/>
	</xsl:param>
	<xsl:param name="notice-capture-method" as="xs:string" required="no">webform</xsl:param>
	<!--<xsl:variable name="mapping"><test/></xsl:variable>-->
	<xsl:param name="updates" as="node()">
		<form/>
	</xsl:param>
	<!-- local functions -->
	<xsl:variable name="publicationDate">
		<xsl:if test="$updates//*:entry[@property = 'gaz:earliestPublicationDate'] != ''">
			<xsl:value-of select="concat($updates//*:entry[@property='gaz:earliestPublicationDate'],'T', 
        if ($updates//*:entry[@property='gaz:earliestPublicationDateWITHtime']) then wlf:getTimeStamp($updates//*:entry[@property='gaz:earliestPublicationDateWITHtime']) else '00:01:00')"/>
		</xsl:if>
	</xsl:variable>
	<xsl:function name="wlf:increment">
		<xsl:param name="propertytoincrement"/>
		<xsl:variable name="numeric" select="number(substring-before(substring-after($propertytoincrement,'['),']')) + 1"/>
		<xsl:variable name="baseproperty" select="substring-before($propertytoincrement,'[')"/>
		<xsl:variable name="newproperty">
			<xsl:value-of select="$baseproperty"/>[<xsl:value-of select="$numeric"/>]</xsl:variable>
		<xsl:value-of select="$newproperty"/>
	</xsl:function>
	<xsl:function name="wlf:getTimeStamp">
		<xsl:param name="arg"/>
		<xsl:choose>
			<xsl:when test="$arg castable as xs:time">
				<xsl:value-of select="$arg"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:analyze-string select="$arg" regex="^([0-9]*):([0-9]*):([0-9]*)([.0-9]*)|([0-9]*):([0-9]*)">
					<xsl:matching-substring>
						<xsl:if test="matches($arg,'^([0-9]*):([0-9]*):([0-9]*)([.0-9]*)')">
							<xsl:value-of select="concat(wlf:get2Digits(regex-group(1)),':', wlf:get2Digits(regex-group(2)),':',wlf:get2Digits(regex-group(3)))"/>
						</xsl:if>
						<xsl:if test="matches($arg,'^([0-9]*):([0-9]*)')">
							<xsl:value-of select="concat(wlf:get2Digits(regex-group(5)),':', wlf:get2Digits(regex-group(6)),':00')"/>
						</xsl:if>
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<xsl:value-of select="$arg"/>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="wlf:get2Digits">
		<xsl:param name="arg"/>
		<xsl:value-of select="if ($arg castable as xs:integer) then format-number(number($arg),'00') else $arg"/>
	</xsl:function>
	<xsl:function name="wlf:getCompanyType">
		<xsl:param name="type"/>
		<xsl:choose>
			<xsl:when test="lower-case($type) = 'unregistered'">
				<xsl:text>gazorg:Organisation gazorg:UnregisteredCompany</xsl:text>
			</xsl:when>
			<xsl:when test="lower-case($type) = 'societyclub'">
				<xsl:text>gazorg:Organisation gazorg:SocietyClub</xsl:text>
			</xsl:when>
			<xsl:when test="lower-case($type) = 'overseascompany'">
				<xsl:text>gazorg:Organisation gazorg:OverseasCompany</xsl:text>
			</xsl:when>
			<xsl:when test="lower-case($type) = 'partnership'">
				<xsl:text>gazorg:Organisation gazorg:Partnership</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>gazorg:LimitedCompany gazorg:Organisation gazorg:ForProfitCompany</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:template name="editionName">
		<xsl:variable name="edition_local">
			<xsl:choose>
				<xsl:when test="$edition = 'Default'">
					<xsl:value-of select="$updates//*[@property='gaz:hasEdition']/text()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$edition"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="lower-case($edition_local) = 'london'">
				<xsl:text>London</xsl:text>
			</xsl:when>
			<xsl:when test="lower-case($edition_local) = 'belfast'">
				<xsl:text>Belfast</xsl:text>
			</xsl:when>
			<xsl:when test="lower-case($edition_local) = 'edinburgh'">
				<xsl:text>Edinburgh</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="x:html">
		<xsl:element name="html" namespace="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="IdURI" select="replace(@IdURI,'notice/undefined',concat('notice/',$noticeId))"/>
			<xsl:variable name="temp-edition" select="$updates//*:entry[@property='gaz:hasEdition']"/>
			<xsl:variable name="temp-prefix" select="@prefix"/>
			<xsl:attribute name="prefix"><xsl:value-of select="replace(replace($temp-prefix,'edition/undefined',concat('edition/', $temp-edition )),'notice/undefined',concat('notice/',$noticeId))"/></xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="x:head">
		<head>
			<title>
				<xsl:value-of select="//x:dd[@data-ui-class = 'notice-type']"/>
			</title>
			<xsl:call-template name="gazettes-metadata"/>
		</head>
	</xsl:template>
	<xsl:template match="x:body">
		<body>
			<xsl:apply-templates/>
			<!--<div class="DEBUG">
        			<hr/><hr/><hr/>
        			<xsl:copy-of select="$updates"/>
        			<hr/><hr/><hr/>
      	  </div>-->
			<xsl:if test="$updates//*[@property='gzw:noticeImageFile']">
				<img class="logoimage" alt="Organisation Logo">
					<xsl:attribute name="src"><xsl:value-of select="$updates//*[@property='gzw:noticeImageFile']"/></xsl:attribute>
				</img>
			</xsl:if>
		</body>
	</xsl:template>
	<xsl:template name="gazettes-metadata">
		<gazette-metadata xmlns="http://www.gazettes.co.uk/metadata">
			<bundle-id>
				<xsl:value-of select="$bundleId"/>
			</bundle-id>
			<notice-id>
				<xsl:value-of select="$noticeId"/>
			</notice-id>
			<edition>
				<xsl:call-template name="editionName"/>
			</edition>
			<status>
				<xsl:value-of select="$status"/>
			</status>
			<submitted-date>
				<xsl:value-of select="$submitted-date"/>
			</submitted-date>
			<version-count>
				<xsl:value-of select="$version-count"/>
			</version-count>
			<user-submitted>
				<xsl:value-of select="$user-submitted"/>
			</user-submitted>
			<organisation-id>0</organisation-id>
			<draft-uri>
				<xsl:value-of select="$updates//@draftURI"/>
			</draft-uri>
			<xsl:if test="$updates//@uploadUri">
				<has-supporting-doc>true</has-supporting-doc>
			</xsl:if>
			<xsl:variable name="noticeType">
				<xsl:value-of select="$updates//@noticeTypeCode"/>
			</xsl:variable>
			<notice-code>
				<xsl:value-of select="$noticeType"/>
			</notice-code>
			<xsl:variable name="category">
				<xsl:sequence select="$mapping//*:Map[@Code = $noticeType]/*"/>
			</xsl:variable>
			<xsl:sequence select="$category"/>
			<notice-capture-method>
				<xsl:value-of select="$notice-capture-method"/>
			</notice-capture-method>
			<publication-date>
				<xsl:value-of select="$publicationDate"/>
			</publication-date>
			<publication-year>
				<xsl:value-of select="substring($publicationDate,1,4)"/>
			</publication-year>
			<notice-logo>
				<xsl:value-of select="$updates//*[@property='gzw:noticeImageFile']"/>
			</notice-logo>
			<xsl:if test="$updates//*[@property='gzw:requestPaperPurchase']">
				<notice-printed-copy>true</notice-printed-copy>
			</xsl:if>
			<xsl:if test="$updates//*[@property='gzw:poBoxService']">
				<po-box-service>true</po-box-service>
			</xsl:if>
			<xsl:if test="$updates//*[@property='gzw:forwardAddressId']">
				<forwarding-address-id>
					<xsl:value-of select="$updates//*[@property='gzw:forwardAddressId']"/>
				</forwarding-address-id>
			</xsl:if>
			<xsl:if test="$updates//*[@property='gzw:requestPDFpurchase']">
				<pdf-copy>true</pdf-copy>
			</xsl:if>
			<xsl:if test="$updates//*[@property='gzw:publishInNews']">
				<publish-in-newspaper>
					<xsl:value-of select="count($updates//*[@property='gzw:regionName'])"/>
				</publish-in-newspaper>
			</xsl:if>
		</gazette-metadata>
	</xsl:template>
	<xsl:template match="x:p[x:span[@property='person:alsoKnownAs']]">
		<xsl:element name="{name(.)}">
			<xsl:copy-of select="@*"/>
			<xsl:value-of select="text()[1]"/>
			<xsl:apply-templates select="x:span"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="x:span[@property='person:alsoKnownAs']">
		<xsl:variable name="this" as="node()" select="."/>
		<xsl:element name="{name(.)}">
			<xsl:copy-of select="@*"/>
			<xsl:value-of select="string-join($updates//*:entry[@about=$this/@about and @property=$this/@property],', ')"/>
		</xsl:element>
	</xsl:template>
	<!-- 2903 -->
	<xsl:template match="x:dd[@about='this:deceasedPerson' and @property='person:alsoKnownAs']">
		<xsl:element name="{name(.)}">
			<xsl:copy-of select="@*"/>
			<xsl:value-of select="string-join($updates//*:entry[@about='this:deceasedPerson' and @property='person:alsoKnownAs'],', ')"/>
		</xsl:element>
	</xsl:template>
	<!-- 2903 -->
	<xsl:template match="x:dd[@about='this:deceasedPerson' and @property='personal-legal:dateOfDeath']"/>
	<!-- 2903 -->
	<xsl:template match="x:dt[following-sibling::x:dd[1][@about='this:deceasedPerson' and @property='personal-legal:dateOfDeath']]">
		<xsl:copy-of copy-namespaces="no" select="."/>
		<xsl:variable name="dd" select="following-sibling::x:dd[1]" as="node()"/>
		<xsl:element name="{name($dd)}">
			<xsl:copy-of copy-namespaces="no" select="$dd/@*"/>
			<xsl:value-of select="$updates//*/.[@about=$dd/@about and @property = $dd/@property]/text()"/>
		</xsl:element>
	</xsl:template>
	<!-- 2903 -->
	<xsl:template match="x:dd[x:span[@about='this:deceasedPerson' and @property='personal-legal:startDateOfDeath']]">
		<xsl:copy-of copy-namespaces="no" select="preceding-sibling::x:dt[1]"/>
		<xsl:if test="$updates//*:entry[@about='this:deceasedPerson' and @property='personal-legal:startDateOfDeath']/normalize-space(.)">
			<xsl:next-match/>
		</xsl:if>
	</xsl:template>
	<!-- 2903 -->
	<xsl:template match="x:dt[following-sibling::x:dd[1]/x:span[@about='this:deceasedPerson' and @property='personal-legal:startDateOfDeath']]">
		<xsl:if test="$updates//*:entry[@about='this:deceasedPerson' and @property='personal-legal:startDateOfDeath']/normalize-space(.)">
			<xsl:copy-of copy-namespaces="no" select="."/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="x:dd[@about='noticeid:' and @property='gaz:earliestPublicationDate' and @datatype='xsd:dateTime']">
		<xsl:element name="{name()}">
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="content"><xsl:value-of select="$publicationDate"/></xsl:attribute>
			<xsl:element name="time">
				<xsl:attribute name="datetime"><xsl:value-of select="$publicationDate"/></xsl:attribute>
				<xsl:value-of select="$publicationDate"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="x:div[@data-container = 'boilerplate']">
		<div>
			<!--   <xsl:apply-templates mode="boilerplate"/>   -->
			<xsl:call-template name="boilerPlateText">
				<xsl:with-param name="updates" select="$updates"/>
			</xsl:call-template>
		</div>
	</xsl:template>
	<xsl:template match="x:div[@class = 'content' and not(@content)]//x:div[not(@data-container = 'address') and not(@data-container='boilerplate')]">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
		<xsl:if test="@data-container = 'copyable'">
			<div about="{@about}" property="gzw:isDuplicable" content="true" data-container="copyable">
				<xsl:apply-templates select="*" mode="duplicate"/>
			</div>
		</xsl:if>
	</xsl:template>
	<xsl:template match="x:div[@data-container = 'address']">
		<xsl:variable name="addressDivAbout">
			<xsl:value-of select="@about"/>
		</xsl:variable>
		<xsl:variable name="addressDivProperty">
			<xsl:value-of select="@property"/>
		</xsl:variable>
		<xsl:variable name="dataGazettesValue">
			<xsl:value-of select="@data-gazettes"/>
		</xsl:variable>
		<xsl:variable name="lengthResource" select="string-length(substring-before(@resource,'-1'))"/>
		<xsl:variable name="resourceWithoutPostfix" select="substring(@resource,1,$lengthResource)"/>
		<xsl:variable name="context" select="."/>
		<xsl:variable name="dot" select="."/>
		<!-- Added text() condition here. We dont want to choose empty entry -->
		<xsl:variable name="indistinct" select="$updates//*[contains(@about,$resourceWithoutPostfix)][text()]/@about"/>
		<xsl:for-each select="distinct-values($indistinct)">
			<xsl:sort select="."/>
			<xsl:variable name="currentAddressAbout" select="."/>
			<div about="{$addressDivAbout}" property="{$addressDivProperty}" resource="{$currentAddressAbout}">
				<xsl:choose>
					<xsl:when test="$context/x:dl">
						<dl>
							<xsl:apply-templates select="$context/x:dl/x:dd">
								<xsl:with-param name="currentAddressAbout" select="." tunnel="yes"/>
							</xsl:apply-templates>
						</dl>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$context/*">
							<xsl:with-param name="currentAddressAbout" select="." tunnel="yes"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:for-each>
	</xsl:template>
	<!-- 2903 -->
	<xsl:template match="x:dl[@data-gazettes = 'Legislation']">
		<xsl:choose>
			<xsl:when test="$updates//*:entry[@property = 'legislation:legislationTitle'] != '' 
                or $updates//*:entry[@property = 'legislation:legislationSection'] != ''">
				<dl>
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates/>
				</dl>
			</xsl:when>
			<xsl:otherwise>
				<dl>
					<xsl:if test="$updates//*:entry[@property = 'legislation:legislationTitle'] != ''">
						<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'legislation:legislationTitle']]]"/>
						<xsl:apply-templates select="x:dd [@property = 'legislation:legislationTitle']"/>
					</xsl:if>
					<xsl:if test="$updates//*:entry[@property = 'legislation:legislationSection'] != ''">
						<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'legislation:legislationSection']]]"/>
						<xsl:apply-templates select="x:dd [@property = 'legislation:legislationSection']"/>
					</xsl:if>
				</dl>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- 2903 -->
	<xsl:template match="x:dl[../@data-gazettes = 'Deceased details']">
		<dl>
			<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:familyName']]]"/>
			<xsl:apply-templates select="x:dd [@property = 'foaf:familyName']"/>
			<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:firstName']]]"/>
			<xsl:apply-templates select="x:dd [@property = 'foaf:firstName']"/>
			<xsl:if test="$updates//*:entry[@property = 'foaf:givenName'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:givenName']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'foaf:givenName']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'foaf:title'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:title']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'foaf:title']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'person:postNominal'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'person:postNominal']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'person:postNominal']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'person:honour'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'person:honour']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'person:honour']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'person:dateOfBirth'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'person:dateOfBirth']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'person:dateOfBirth']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'person:placeOfBirth'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'person:placeOfBirth']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'person:placeOfBirth']"/>
			</xsl:if>
			<!-- 2904 -->
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:hasMaritalStatus'] != ''">
				<span typeof="personal-legal:MaritalStatus" property="rdfs:label">
					<xsl:attribute name="about"><xsl:text>personal-legal:</xsl:text><xsl:value-of select="$updates//*:entry[@property = 'personal-legal:hasMaritalStatus']"/><xsl:text>MaritalStatus</xsl:text></xsl:attribute>
					<xsl:attribute name="content"><xsl:value-of select="$updates//*:entry[@property = 'personal-legal:hasMaritalStatus']"/></xsl:attribute>
				</span>
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:hasMaritalStatus']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'personal-legal:hasMaritalStatus']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'person:hasMaidenName'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'person:hasMaidenName']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'person:hasMaidenName']"/>
			</xsl:if>
			<!-- 2904 -->
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:dateOfMarriage'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:dateOfMarriage']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'personal-legal:dateOfMarriage']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:placeOfMarriage'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:placeOfMarriage']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'personal-legal:placeOfMarriage']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:spouse'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:spouse']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'personal-legal:spouse']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:nationality'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:nationality']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'personal-legal:nationality']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:religion'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:religion']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'personal-legal:religion']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'person:alsoKnownAs'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'person:alsoKnownAs']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'person:alsoKnownAs']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:dateOfDeath'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:dateOfDeath']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'personal-legal:dateOfDeath']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:startDateOfDeath'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:startDateOfDeath']]]"/>
				<xsl:apply-templates select="x:dd[x:span[@property='personal-legal:startDateOfDeath']]"/>
			</xsl:if>
			<!-- 2904 -->
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:placeOfDeath'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:placeOfDeath']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'personal-legal:placeOfDeath']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'person:jobTitle'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'person:jobTitle']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'person:jobTitle']"/>
			</xsl:if>
			<!-- 2904 -->
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:dateEnteredUK'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:dateEnteredUK']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'personal-legal:dateEnteredUK']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:dateOfNaturalisation'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:dateOfNaturalisation']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'personal-legal:dateOfNaturalisation']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:dateOfAdoption'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:dateOfAdoption']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'personal-legal:dateOfAdoption']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:dateOfDivorce'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:dateOfDivorce']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'personal-legal:dateOfDivorce']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:hasNextOfKin'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:hasNextOfKin']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'personal-legal:hasNextOfKin']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'personal-legal:otherInfo'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:otherInfo']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'personal-legal:otherInfo']"/>
			</xsl:if>
		</dl>
	</xsl:template>
	<!-- 2903 -->
	<xsl:template match="x:dl[@data-gazettes = 'Executors Name']">
		<dl>
			<!-- *********** -->
			<!-- Old executor handling still required for 2904. If multi-executors support is added in future, this block can be removed -->
			<xsl:if test="$updates//*:entry[@property = 'foaf:name' and @about = 'this:estateExecutor'] !=''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:name']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'foaf:name']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'foaf:familyName' and @about = 'this:estateExecutor'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:familyName']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'foaf:familyName']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'foaf:firstName' and @about = 'this:estateExecutor'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:firstName']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'foaf:firstName']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'foaf:givenName' and @about = 'this:estateExecutor'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:givenName']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'foaf:givenName']"/>
			</xsl:if>
			<!-- *********** -->
			<xsl:if test="$updates//*:entry[@property = 'foaf:name' and @about = 'this:estateExecutor-1'] !=''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:name' and @about = 'this:estateExecutor-1']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'foaf:name' and @about = 'this:estateExecutor-1']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'foaf:familyName' and @about = 'this:estateExecutor-1'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:familyName' and @about = 'this:estateExecutor-1']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'foaf:familyName' and @about = 'this:estateExecutor-1']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'foaf:firstName' and @about = 'this:estateExecutor-1'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:firstName' and @about = 'this:estateExecutor-1']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'foaf:firstName' and @about = 'this:estateExecutor-1']"/>
			</xsl:if>
			<xsl:if test="$updates//*:entry[@property = 'foaf:givenName' and @about = 'this:estateExecutor-1'] != ''">
				<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:givenName' and @about = 'this:estateExecutor-1']]]"/>
				<xsl:apply-templates select="x:dd [@property = 'foaf:givenName' and @about = 'this:estateExecutor-1']"/>
			</xsl:if>
		</dl>
	</xsl:template>
	<xsl:template match="x:dl[@data-gazettes = 'Additional Executors Name']">
		<xsl:if test="$updates//*:entry[contains(@about,'this:estateExecutor') and @about != 'this:estateExecutor-1'] != ''">
			<dl>
				<xsl:if test="$updates//*:entry[@property = 'foaf:familyName' and @about = 'this:estateExecutor-2'] != ''">
					<span about="this:notifiableThing" property="personal-legal:hasPersonalRepresentative" resource="this:estateExecutor-2"/>
					<span data-hide="true" resource="this:estateExecutor-2" typeof="foaf:Agent"/>
					<span about="this:estateExecutor-2" property="vcard:adr" resource="this:addressOfExecutor-1"/>
					<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:familyName' and @about = 'this:estateExecutor-2']]]"/>
					<xsl:apply-templates select="x:dd [@property = 'foaf:familyName' and @about = 'this:estateExecutor-2']"/>
				</xsl:if>
				<xsl:if test="$updates//*:entry[@property = 'foaf:firstName' and @about = 'this:estateExecutor-2'] != ''">
					<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:firstName' and @about = 'this:estateExecutor-2']]]"/>
					<xsl:apply-templates select="x:dd [@property = 'foaf:firstName' and @about = 'this:estateExecutor-2']"/>
				</xsl:if>
				<xsl:if test="$updates//*:entry[@property = 'foaf:givenName' and @about = 'this:estateExecutor-2'] != ''">
					<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:givenName' and @about = 'this:estateExecutor-2']]]"/>
					<xsl:apply-templates select="x:dd [@property = 'foaf:givenName' and @about = 'this:estateExecutor-2']"/>
				</xsl:if>
				<xsl:if test="$updates//*:entry[@property = 'foaf:familyName' and @about = 'this:estateExecutor-3'] != ''">
					<span about="this:notifiableThing" property="personal-legal:hasPersonalRepresentative" resource="this:estateExecutor-3"/>
					<span data-hide="true" resource="this:estateExecutor-3" typeof="foaf:Agent"/>
					<span about="this:estateExecutor-3" property="vcard:adr" resource="this:addressOfExecutor-1"/>
					<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:familyName' and @about = 'this:estateExecutor-3']]]"/>
					<xsl:apply-templates select="x:dd [@property = 'foaf:familyName' and @about = 'this:estateExecutor-3']"/>
				</xsl:if>
				<xsl:if test="$updates//*:entry[@property = 'foaf:firstName' and @about = 'this:estateExecutor-3'] != ''">
					<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:firstName' and @about = 'this:estateExecutor-3']]]"/>
					<xsl:apply-templates select="x:dd [@property = 'foaf:firstName' and @about = 'this:estateExecutor-3']"/>
				</xsl:if>
				<xsl:if test="$updates//*:entry[@property = 'foaf:givenName' and @about = 'this:estateExecutor-3'] != ''">
					<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:givenName' and @about = 'this:estateExecutor-3']]]"/>
					<xsl:apply-templates select="x:dd [@property = 'foaf:givenName' and @about = 'this:estateExecutor-3']"/>
				</xsl:if>
				<xsl:if test="$updates//*:entry[@property = 'foaf:familyName' and @about = 'this:estateExecutor-4'] != ''">
					<span about="this:notifiableThing" property="personal-legal:hasPersonalRepresentative" resource="this:estateExecutor-4"/>
					<span data-hide="true" resource="this:estateExecutor-4" typeof="foaf:Agent"/>
					<span about="this:estateExecutor-4" property="vcard:adr" resource="this:addressOfExecutor-1"/>
					<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:familyName' and @about = 'this:estateExecutor-4']]]"/>
					<xsl:apply-templates select="x:dd [@property = 'foaf:familyName' and @about = 'this:estateExecutor-4']"/>
				</xsl:if>
				<xsl:if test="$updates//*:entry[@property = 'foaf:firstName' and @about = 'this:estateExecutor-4'] != ''">
					<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:firstName' and @about = 'this:estateExecutor-4']]]"/>
					<xsl:apply-templates select="x:dd [@property = 'foaf:firstName' and @about = 'this:estateExecutor-4']"/>
				</xsl:if>
				<xsl:if test="$updates//*:entry[@property = 'foaf:givenName' and @about = 'this:estateExecutor-4'] != ''">
					<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:givenName' and @about = 'this:estateExecutor-4']]]"/>
					<xsl:apply-templates select="x:dd [@property = 'foaf:givenName' and @about = 'this:estateExecutor-4']"/>
				</xsl:if>
				<xsl:if test="$updates//*:entry[@property = 'foaf:familyName' and @about = 'this:estateExecutor-5'] != ''">
					<span about="this:notifiableThing" property="personal-legal:hasPersonalRepresentative" resource="this:estateExecutor-5"/>
					<span data-hide="true" resource="this:estateExecutor-5" typeof="foaf:Agent"/>
					<span about="this:estateExecutor-5" property="vcard:adr" resource="this:addressOfExecutor-1"/>
					<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:familyName' and @about = 'this:estateExecutor-5']]]"/>
					<xsl:apply-templates select="x:dd [@property = 'foaf:familyName' and @about = 'this:estateExecutor-5']"/>
				</xsl:if>
				<xsl:if test="$updates//*:entry[@property = 'foaf:firstName' and @about = 'this:estateExecutor-5'] != ''">
					<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:firstName' and @about = 'this:estateExecutor-5']]]"/>
					<xsl:apply-templates select="x:dd [@property = 'foaf:firstName' and @about = 'this:estateExecutor-5']"/>
				</xsl:if>
				<xsl:if test="$updates//*:entry[@property = 'foaf:givenName' and @about = 'this:estateExecutor-5'] != ''">
					<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'foaf:givenName' and @about = 'this:estateExecutor-5']]]"/>
					<xsl:apply-templates select="x:dd [@property = 'foaf:givenName' and @about = 'this:estateExecutor-5']"/>
				</xsl:if>
			</dl>
		</xsl:if>
	</xsl:template>
	<!-- 2903 -->
	<xsl:template match="x:dl[@data-gazettes = 'Executors Contact']">
		<xsl:choose>
			<xsl:when test="$updates//*:entry[@property = 'gaz:telephone' and @about = 'this:estateExecutor-1'] != ''
                or $updates//*:entry[@property = 'gaz:fax' and @about = 'this:estateExecutor-1'] != ''
                or $updates//*:entry[@property = 'gaz:email' and @about = 'this:estateExecutor-1'] != ''
                or $updates//*:entry[@property = 'gaz:claimNumber' and @about = 'this:notifiableThing'] != ''">
				<dl>
					<xsl:if test="$updates//*:entry[@property = 'gaz:telephone' and @about = 'this:estateExecutor-1'] != ''">
						<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'gaz:telephone']]]"/>
						<xsl:apply-templates select="x:dd [@property = 'gaz:telephone']"/>
					</xsl:if>
					<xsl:if test="$updates//*:entry[@property = 'gaz:fax' and @about = 'this:estateExecutor-1'] != ''">
						<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'gaz:fax']]]"/>
						<xsl:apply-templates select="x:dd [@property = 'gaz:fax']"/>
					</xsl:if>
					<xsl:if test="$updates//*:entry[@property = 'gaz:email' and @about = 'this:estateExecutor-1'] != ''">
						<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'gaz:email']]]"/>
						<xsl:apply-templates select="x:dd [@property = 'gaz:email']"/>
					</xsl:if>
					<xsl:if test="$updates//*:entry[@property = 'gaz:claimNumber' and @about = 'this:notifiableThing'] != ''">
						<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'gaz:claimNumber']]]"/>
						<xsl:apply-templates select="x:dd [@property = 'gaz:claimNumber']"/>
					</xsl:if>
				</dl>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- 2903 -->
	<xsl:template match="x:dl[@data-gazettes = 'Claims Date']">
		<xsl:choose>
			<xsl:when test="$updates//*:entry[@property = 'personal-legal:hasClaimDeadline'] != ''">
				<dl>
					<xsl:if test="$updates//*:entry[@property = 'personal-legal:hasClaimDeadline'] != ''">
						<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:hasClaimDeadline']]]"/>
						<xsl:apply-templates select="x:dd [@property = 'personal-legal:hasClaimDeadline']"/>
					</xsl:if>
					<xsl:if test="$updates//*:entry[@property = 'personal-legal:informant'] != ''">
						<xsl:apply-templates select="x:dt[following-sibling::*[1][self::x:dd [@property = 'personal-legal:informant']]]"/>
						<xsl:apply-templates select="x:dd [@property = 'personal-legal:informant']"/>
					</xsl:if>
				</dl>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="x:div[@class = 'fileupload']"/>
	<xsl:template match="x:p">
		<xsl:param name="currentAddressAbout" select="''" tunnel="yes"/>
		<xsl:variable name="currentAbout">
			<xsl:choose>
				<xsl:when test="../@data-container='address'">
					<xsl:value-of select="$currentAddressAbout"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="x:span[1]/@about"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="currentProperty" select="x:span[1]/@property"/>
		<xsl:variable name="currentResource" select="x:span[1]/@resource"/>
		<xsl:variable name="currentTypeOf" select="x:span[1]/@typeof"/>
		<xsl:variable name="copyablepropertyname" select="concat($currentProperty,'--copy')"/>
		<xsl:choose>
			<xsl:when test="$form = 'true'">
				<xsl:apply-templates select="x:span|x:strong|x:em"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="p">
					<xsl:value-of select="text()"/>
					<xsl:element name="span">
						<xsl:attribute name="about" select="$currentAbout"/>
						<xsl:attribute name="property" select="$currentProperty"/>
						<xsl:attribute name="datatype" select="x:span[1]/@datatype"/>
						<xsl:attribute name="resource" select="$currentResource"/>
						<xsl:attribute name="typeof" select="$currentTypeOf"/>
						<xsl:choose>
							<xsl:when test="($updates//*/@property = $copyablepropertyname) and ($updates//*[@property = $copyablepropertyname]/@about = $currentAbout)">
								<xsl:attribute name="data-container">fixed</xsl:attribute>
							</xsl:when>
							<xsl:otherwise/>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="($updates//*/@property = $currentProperty) and ($updates//*[@property = $currentProperty]/@about = $currentAbout)">
								<xsl:choose>
									<xsl:when test="x:span[1]/@datatype = 'xsd:dateTime' and ($updates//*/.[@about=$currentAbout and @property = $currentProperty]/text() != '')">
										<xsl:value-of select="$updates//*/.[@about=$currentAbout and @property = $currentProperty][1]/text()"/>T<xsl:value-of select="$updates//*/.[@about=$currentAbout and @property = concat($currentProperty,'WITHtime')][1]/text()"/>:00</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$updates//*/.[@about=$currentAbout and @property = $currentProperty][1]/text()"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(x:span[1])"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="x:dd[@data-gazettes='noticeid']">
		<dd about="noticeid:" property="gaz:hasNoticeID">
			<xsl:value-of select="$noticeId"/>
		</dd>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:copy-of select="."/>
	</xsl:template>
	<xsl:template match="node()">
		<xsl:param name="currentAddressAbout" select="''" tunnel="yes"/>
		<xsl:variable name="currentAbout">
			<xsl:choose>
				<xsl:when test="../../@data-container ='address'">
					<xsl:value-of select="$currentAddressAbout"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@about"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="currentProperty" select="@property"/>
		<xsl:choose>
			<xsl:when test="($form = 'true') and (ancestor::*/@class='content') and ((name() = 'span') or (name() = 'p') or (name() = 'strong') or (name()='em') ) and @property">
				<xsl:if test="not(@data-hide = 'true')">
					<!-- temp: get list of corresponding nodes in $updates -->
					<xsl:variable name="updatenodes" select="$updates//*[@about = $currentAbout and @property = $currentProperty]"/>
					<xsl:variable name="preambletext" select="../text()"/>
					<xsl:variable name="datatype" select="@datatype"/>
					<xsl:choose>
						<xsl:when test="$updates//*[@about = $currentAbout and @property = $currentProperty]">
							<!-- make the update -->
							<xsl:for-each select="$updatenodes">
								<xsl:variable name="atomicupdate" select="."/>
								<xsl:variable name="id">
									<xsl:value-of select="replace(@about,':','-')"/>_<xsl:value-of select="replace(@property,':','-')"/>-<xsl:value-of select="position()"/>
								</xsl:variable>
								<xsl:element name="li">
									<label for="{$id}">
										<xsl:value-of select="$preambletext"/>
									</label>
									<xsl:element name="input">
										<xsl:attribute name="id" select="$id"/>
										<xsl:attribute name="name"><xsl:variable name="namestructure"><xsl:value-of select="@about"/>[<xsl:value-of select="@property"/>]</xsl:variable><xsl:value-of select="$namestructure"/></xsl:attribute>
										<xsl:choose>
											<xsl:when test="$datatype = 'xsd:date'">
												<xsl:attribute name="type">date</xsl:attribute>
												<xsl:attribute name="class">date-picker date-picker-free-date</xsl:attribute>
											</xsl:when>
											<xsl:when test="$datatype = 'xsd:time'">
												<xsl:attribute name="type">time</xsl:attribute>
											</xsl:when>
											<xsl:when test="$datatype = 'xsd:dateTime'">
												<xsl:attribute name="type">datetime</xsl:attribute>
											</xsl:when>
											<xsl:when test="$datatype = 'checkbox'">
												<xsl:attribute name="type">checkbox</xsl:attribute>
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="type">text</xsl:attribute>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:attribute name="value"><xsl:value-of select="normalize-space(.)"/></xsl:attribute>
									</xsl:element>
								</xsl:element>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<!-- just pass through the template -->
							<xsl:element name="li">
								<xsl:variable name="id">
									<xsl:value-of select="replace(@about,':','-')"/>_<xsl:value-of select="replace(@property,':','-')"/>
								</xsl:variable>
								<label for="{$id}">
									<xsl:value-of select="../text()"/>
								</label>
								<xsl:element name="input">
									<xsl:attribute name="id" select="$id"/>
									<xsl:attribute name="name"><xsl:variable name="namestructure"><xsl:value-of select="@about"/>[<xsl:value-of select="@property"/>]</xsl:variable><xsl:value-of select="$namestructure"/></xsl:attribute>
									<xsl:choose>
										<xsl:when test="@datatype = 'xsd:date'">
											<xsl:attribute name="type">date</xsl:attribute>
											<xsl:attribute name="class">date-picker date-picker-free-date</xsl:attribute>
										</xsl:when>
										<xsl:when test="@datatype = 'xsd:time'">
											<xsl:attribute name="type">time</xsl:attribute>
										</xsl:when>
										<xsl:when test="@datatype = 'xsd:dateTime'">
											<xsl:attribute name="type">datetime</xsl:attribute>
										</xsl:when>
										<xsl:when test="@datatype = 'checkbox'">
											<xsl:attribute name="type">checkbox</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="type">text</xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
					<!-- output any required buttons -->
					<xsl:if test="@data-button = 'true'">
						<li>
							<span class="{@data-class-outer}" id="{@data-class-outer}">
								<input class="{@data-class-inner}" formnovalidate="formnovalidate" name="{@data-name}" type="submit" value="{@data-title}"/>
							</span>
						</li>
					</xsl:if>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="($updates//*/@property = $currentProperty) and ($updates//*[@property = $currentProperty]/@about = $currentAbout)">
						<xsl:variable name="contents" select="$updates//*/.[@property = $currentProperty and @about = $currentAbout]/text()"/>
						<xsl:if test="$contents!=''">
							<xsl:choose>
								<xsl:when test="../../@data-container ='address' and name(.)='dd'">
									<xsl:apply-templates select="preceding-sibling::*[1][self::x:dt]"/>
									<dd>
										<xsl:for-each select="@*">
											<xsl:variable name="attributeName">
												<xsl:value-of select="name(.)"/>
											</xsl:variable>
											<xsl:choose>
												<xsl:when test="$attributeName = 'about'">
													<xsl:attribute name="{$attributeName}" select="$currentAbout"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="{$attributeName}" select="."/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:for-each>
										<xsl:value-of select="$contents"/>
									</dd>
								</xsl:when>
								<xsl:otherwise>
									<xsl:copy>
										<xsl:if test="@property='personal-legal:hasMaritalStatus'">
											<xsl:attribute name="resource"><xsl:text>personal-legal:</xsl:text><xsl:value-of select="$updates//*[@property='personal-legal:hasMaritalStatus']/text()"/><xsl:text>MaritalStatus</xsl:text></xsl:attribute>
										</xsl:if>
										<xsl:apply-templates select="@*"/>
										<xsl:if test="$debug='true'">|||</xsl:if>
										<xsl:choose>
											<xsl:when test="@datatype = 'xsd:dateTime' and ($updates//*/.[@about=$currentAbout and @property = $currentProperty][1]/text() != '')">
												<xsl:value-of select="$updates//*/.[@about=$currentAbout and @property = $currentProperty][1]/text()"/>T<xsl:value-of select="$updates//*/.[@about=$currentAbout and @property = concat($currentProperty,'WITHtime')][1]/text()"/>:00</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$contents"/>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:if test="$debug='true'">|||</xsl:if>
									</xsl:copy>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy>
							<xsl:apply-templates select="@* | node()"/>
						</xsl:copy>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="x:div" mode="duplicate">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="x:p" mode="duplicate">
		<p>
			<xsl:apply-templates mode="duplicate"/>
		</p>
	</xsl:template>
	<xsl:template match="x:span" mode="duplicate">
		<span about="{@about}" property="{@property}" datatype="{@datatype}" resource="{@resource}" typeof="{@typeof}">
			<xsl:apply-templates mode="duplicate"/>
		</span>
	</xsl:template>
	<xsl:template match="text()" mode="duplicate">
		<xsl:value-of select="."/>
	</xsl:template>
	<xsl:template match="area[not(node())]|bgsound[not(node())]|br[not(node())]|hr[not(node())]|img[not(node())]|input[not(node())]|param[not(node())]">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="@*"/>
		</xsl:element>
	</xsl:template>
	<!--	<xsl:template match="x:span[@about='issue:' and @property='gaz:hasEdition' and @resource='edition:']">
	 <span about="issue:" property="gaz:hasEdition" resource="edition:">
		<xsl:call-template name="editionName"/>
	 </span>	
	 
	 <span about="edition:" property="gaz:editionName" datatype="xsd:string">
		<xsl:call-template name="editionName"/>
	 </span>
	</xsl:template>-->
	<xsl:template match="x:span[@about='noticeid:' and @property='gaz:hasNoticeNumber']">
		<span about="noticeid:" property="gaz:hasNoticeNumber" datatype="xsd:integer" content="{$noticeId}"/>
	</xsl:template>
	<xsl:template match="x:span[@about='issue:' and @property='gaz:hasEdition' and @resource='edition:']">
		<span about="issue:" property="gaz:hasEdition" resource="edition:">
			<!--<xsl:call-template name="editionName"/>-->
		</span>
	</xsl:template>
	<xsl:template match="x:span[@about='edition:' and @property='gaz:editionName']">
		<span about="edition:" property="gaz:editionName" datatype="xsd:string">
			<xsl:call-template name="editionName"/>
		</span>
	</xsl:template>
	<xsl:template match="x:span[@resource='edition:' and @typeof='gaz:Edition']">
		<span resource="edition:" typeof="gaz:Edition">
			<!--<xsl:call-template name="editionName"/>-->
		</span>
	</xsl:template>
	<xsl:template name="boilerPlateText">
		<xsl:param name="updates"/>
		<xsl:variable name="noticeCode">
			<xsl:value-of select="/x:html/x:body/x:article/x:div[@class='rdfa-data']/x:span[@property = 'gaz:hasNoticeCode']/@content"/>
		</xsl:variable>
		<xsl:variable name="edition">
			<xsl:value-of select="$updates//*[@property='gaz:hasEdition']/text()"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$noticeCode = '2450' and ($edition='london')">
				<xsl:call-template name="boilerPlateText2450">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '2450' and ($edition='edinburgh')">
				<xsl:call-template name="boilerPlateText2450Edinburgh">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '2450' and ($edition='belfast')">
				<xsl:call-template name="boilerPlateText2450Belfast">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '2451' and ($edition='london')">
				<xsl:call-template name="boilerPlateText2451">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '2451' and ($edition='belfast')">
				<xsl:call-template name="boilerPlateText2451Belfast">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '2451' and ($edition='edinburgh')">
				<xsl:call-template name="boilerPlateText2451Edinburgh">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '2441'">
				<xsl:call-template name="boilerPlateText2441">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '2442'">
				<xsl:call-template name="boilerPlateText2442">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '2443'">
				<xsl:call-template name="boilerPlateText2443">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '2445'">
				<xsl:call-template name="boilerPlateText2445">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '2446'">
				<xsl:call-template name="boilerPlateText2446">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '2447'">
				<xsl:call-template name="boilerPlateText2447">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '2509'">
				<xsl:call-template name="boilerPlateText2509">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '2510'">
				<xsl:call-template name="boilerPlateText2510">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '2518'">
				<xsl:call-template name="boilerPlateText2518">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '1510'">
				<xsl:call-template name="boilerPlateText1510">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '1601'">
				<xsl:call-template name="boilerPlateText1601">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '3301'">
				<xsl:call-template name="boilerPlateText3301">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$noticeCode = '1211'">
				<xsl:call-template name="boilerPlateText1211">
					<xsl:with-param name="updates" select="$updates"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="boilerPlateText1211">
		<xsl:param name="updates"/>
		<h3>
			<span about="this:authority-1" typeof="gazorg:Organisation" property="rdfs:label" data-required="true" datatype="xsd:string">
				<xsl:if test="$updates//*[@property='gazorg:hasAuthority']">
					<xsl:value-of select="$updates//*[@about='this:authority-1' and @property='gazorg:hasAuthority']/text()"/>
				</xsl:if>
			</span>
		</h3>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='gaz:hasTitle']/text() != ''">
			<h3>
				<span about="this:notifiableThing" data-gazettes="Title" property="gaz:hasTitle" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='gaz:hasTitle']/text()"/>
				</span>
			</h3>
			</xsl:if>
		<p>
			<xsl:if test="not(starts-with(normalize-space($updates//*[@about='this:authority-1' and @property='gazorg:hasAuthority']/text()), 'The'))">
			<xsl:text>The </xsl:text>
			</xsl:if>
			<span about="this:authority-1" typeof="gazorg:Organisation" property="rdfs:label" data-required="true" datatype="xsd:string">
				<xsl:if test="$updates//*[@property='gazorg:hasAuthority']">
					<xsl:value-of select="$updates//*[@about='this:authority-1' and @property='gazorg:hasAuthority']/text()"/>
				</xsl:if>
			</span>
			<xsl:text> has made a Statutory Rule entitled "</xsl:text>
			<span about="http://www.legislation.gov.uk/id/nisr/2008/12" property="rdfs:label" data-required="true">
				<xsl:if test="$updates//*[@property='rdfs:label']">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='rdfs:label']/text()"/>
				</xsl:if>
			</span>
			<xsl:text>", (S.R. </xsl:text>
			<span about="http://www.legislation.gov.uk/id/nisr/2008/12" property="legislation:hasLegislationYear" datatype="xsd:gYear" data-required="true">
				<xsl:if test="$updates//*[@property='legislation:hasLegislationYear']">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='legislation:hasLegislationYear']/text()"/>
				</xsl:if>
			</span>
			<xsl:text> No. </xsl:text>
			<span about="http://www.legislation.gov.uk/id/nisr/2008/12" property="legislation:hasLegislationNumber" data-required="true" datatype="xsd:integer">
				<xsl:if test="$updates//*[@property='legislation:hasLegislationNumber']">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='legislation:hasLegislationNumber']/text()"/>
				</xsl:if>
			</span>
			<xsl:text>), which comes into operation on </xsl:text>
			<span about="http://www.legislation.gov.uk/id/nisr/2008/12" property="legislation:dateProposedOrderComesIntoEffect" content="2017-09-13" datatype="xsd:date" data-past-date="true" data-required="true">
				<xsl:if test="$updates//*[@property='legislation:dateProposedOrderComesIntoEffect']">
					<xsl:value-of select="format-date(xs:date($updates//*[@about='this:notifiableThing' and @property='legislation:dateProposedOrderComesIntoEffect']/text()),'[D1o] [MNn] [Y0001]')"/>
				</xsl:if>
			</span>.
</p>

		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='gaz:hasAdditionalInformation']/text() != ''">
			<p>
				<span about="this:notifiableThing" property="gaz:hasAdditionalInformation" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='gaz:hasAdditionalInformation']/text()"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2450">
		<xsl:param name="updates"/>
		<p>
			<xsl:text>In the </xsl:text>
			<span about="this:court-1" property="court:courtName" datatype="xsd:string">
				<xsl:if test="$updates//*[@property='court:courtName' and contains(.,'High Court')]">
					<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:courtName']/text()"/>
				</xsl:if>
				<xsl:if test="$updates//*[@property='court:courtName' and not(contains(.,'High Court'))]">
					<xsl:text>County Court at </xsl:text>
					<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:countyCourtName']/text()"/>
				</xsl:if>
			</span>
		</p>
		<p>
			<xsl:variable name="courtCode">
				<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:caseCode']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtNumber">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtYear">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
			</xsl:variable>
			<xsl:if test="starts-with($courtCode,'No')">
				<span>
					<xsl:text>No. </xsl:text>
					<span about="this:court-case-1" property="court:caseNumber" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
					</span>
					<xsl:text> of </xsl:text>
					<span about="this:court-case-1" property="court:caseYear" datatype="xsd:gYear">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
					</span>
				</span>
			</xsl:if>
			<xsl:if test="starts-with($courtCode,'CR') or starts-with($courtCode,'BR')">
				<span>
					<span about="this:court-case-1" property="court:caseCode" datatype="xsd:string">
						<xsl:value-of select="replace(replace($courtCode,'YYYY',$courtYear),'####',$courtNumber)"/>
					</span>
				</span>
			</xsl:if>
		</p>
		<p>
			<xsl:text>In the matter of </xsl:text>
			<strong about="this:company-1" property="gazorg:name" typeof=" " datatype="xsd:string">
				<xsl:attribute name="typeof"><xsl:value-of select="wlf:getCompanyType($updates//*[@about='this:company-1' and @property='gazorg:companyType']/text())"/></xsl:attribute>
				<xsl:value-of select="upper-case($updates//*[@about='this:company-1' and @property='gazorg:name']/text())"/>
			</strong>
		</p>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text() != ''">
			<p>
				<xsl:text>Previously: </xsl:text>
				<span about="this:company-1" property="gazorg:previousCompanyName" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text() != ''">
			<p>
				<xsl:text>Trading As: </xsl:text>
				<span about="this:company-1" property="gazorg:tradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text() != ''">
			<p>
				<xsl:text>Previously Trading As: </xsl:text>
				<span about="this:company-1" property="gazorg:previouslyTradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<p>
			<xsl:text>and in the Matter of the </xsl:text>
			<span about="this:legislation-1" property="legislation:legislationTitle" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:legislation-1' and @property='legislation:legislationTitle']/text()"/>
			</span>
			<xsl:text>,</xsl:text>
		</p>
		<p>
			<xsl:text>A Petition to wind up the above-named company of </xsl:text>
			<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:name']/text()"/>
			<xsl:text> (</xsl:text>
			<xsl:if test="$updates//*[@about='this:principal-trading-address-1' and @property='vcard:outside-uk-address']/text()='on'">
				<span about="this:principal-trading-address-1" property="vcard:outside-uk-address" content="true" data-type="xsd:boolean"/>
			</xsl:if>
			<span about="this:company-1" property="gazorg:companyNumber" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:companyNumber']/text()"/>
			</span>
			<xsl:text>)</xsl:text>
			<xsl:text> of </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:principal-trading-address-1'"/>
			</xsl:call-template>
			<xsl:if test="$updates//*[@about='this:previous-trading-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:country']/text() != ''">
				<xsl:text>, previously of </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:previous-trading-address-1'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:company-registered-office-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:company-registered-office-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:company-registered-office-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:company-registered-office-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:company-registered-office-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:company-registered-office-1' and @property='vcard:country']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:company-registered-office-1'"/>
				</xsl:call-template>
				<xsl:text> (where service of the petition was effected)</xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:natureOfBusiness']/text() != ''">
				<xsl:text>, whose nature of business is </xsl:text>
				<span about="this:company-1" property="gazorg:natureOfBusiness" datatype="xsd:string" data-recommended="true">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:natureOfBusiness']/text()"/>
				</span>
			</xsl:if>
			<xsl:text>, presented on </xsl:text>
			<xsl:variable name="dateOfPetitionPresentation">
				<xsl:value-of select="format-date(xs:date($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfPetitionPresentation']/text()),'[FNn] [D01] [MNn] [Y0001]')"/>
			</xsl:variable>
			<xsl:variable name="timeOfPetitionPresentation">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfPetitionPresentationWITHtime']/text()"/>
			</xsl:variable>
			<xsl:variable name="dateOfPetitionPresentationValue">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfPetitionPresentation']/text()"/>
			</xsl:variable>
			<xsl:variable name="PetitionPresentation">
				<xsl:value-of select="concat($dateOfPetitionPresentationValue,'T',$timeOfPetitionPresentation,':00')"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfPetitionPresentation" datatype="xsd:date" content="{$dateOfPetitionPresentationValue}">
				<xsl:value-of select="concat($dateOfPetitionPresentation,', at ',$timeOfPetitionPresentation)"/>
			</span>
			<xsl:text> by </xsl:text>
			<span about="this:petitioner-1" property="foaf:name" datatype="xsd:string">
				<xsl:value-of select="upper-case($updates//*[@about='this:petitioner-1' and @property='foaf:name']/text())"/>
			</span>
			<xsl:text>, of </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:petitioner-address-1'"/>
			</xsl:call-template>
			<xsl:text> claiming to be a </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:presentedBy" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:presentedBy']/text()"/>
			</span>
			<xsl:text> of the Company, will be heard at the </xsl:text>
			<xsl:if test="$updates//*[@property='court:courtName' and contains(.,'High Court')]">
				<span about="this:notifiableThing" property="corp-insolvency:nameOfPlaceOfHearing" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:nameOfPlaceOfHearing']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@property='court:courtName' and not(contains(.,'High Court'))]">
				<xsl:text>County Court at </xsl:text>
				<span about="this:notifiableThing" property="corp-insolvency:nameOfPlaceOfHearing" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:nameOfPlaceOfHearing']/text()"/>
				</span>
			</xsl:if>
			<xsl:text>, </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:hearingAddress'"/>
			</xsl:call-template>
			<xsl:text> on </xsl:text>
			<xsl:variable name="dateOfHearing">
				<xsl:value-of select="format-date(xs:date($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfHearing'][1]/text()),'[FNn] [D01] [MNn] [Y0001]')"/>
			</xsl:variable>
			<xsl:variable name="timeOfHearing">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfHearingWITHtime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="dateOfHearingValue">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfHearing'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="hearing">
				<xsl:value-of select="concat($dateOfHearingValue,'T',$timeOfHearing,':00')"/>
			</xsl:variable>
			<span about="this:notifiableThing" datatype="xsd:dateTime" property="corp-insolvency:dateOfHearing" content="{$hearing}">
				<xsl:value-of select="concat($dateOfHearing,', at ',$timeOfHearing)"/>
			</span>
			<xsl:text> (or as soon thereafter as the Petition can be heard).</xsl:text>
		</p>
		<xsl:variable name="dateInsolvencyRule">
			<xsl:value-of select="format-date(xs:date($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateToRequestAppearance']/text()),'[FNn] [D01] [MNn] [Y0001]')"/>
		</xsl:variable>
		<xsl:variable name="timeInsolvencyRule">
			<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateToRequestAppearanceWITHtime']/text()"/>
		</xsl:variable>
		<xsl:variable name="dateInsolvencyRuleValue">
			<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateToRequestAppearance']/text()"/>
		</xsl:variable>
		<xsl:variable name="InsolvencyRule">
			<xsl:value-of select="concat($dateInsolvencyRuleValue,'T',$timeInsolvencyRule,':00')"/>
		</xsl:variable>
		<p>
			<xsl:text>Any person intending to appear on the hearing of the Petition (whether to support or oppose it) must give notice of intention to do so to the Petitioners or to their Solicitor in accordance with Rule 7.14 by </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:dateToRequestAppearance" datatype="xsd:dateTime" content="{$InsolvencyRule}">
				<xsl:value-of select="concat($timeInsolvencyRule,' hours on ',$dateInsolvencyRule)"/>
			</span>
		</p>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='foaf:name']/text() != ''
	or $updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''
	or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''
	or $updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''
	or $updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''
	or $updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != ''">
			<p>
				<xsl:variable name="pc1">
					<xsl:value-of select="$updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']"/>
				</xsl:variable>
				<xsl:variable name="pc2">
					<xsl:value-of select="$updates//*[@about='this:IP2-address-1' and @property='vcard:postal-code']"/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text() = 'Solicitor'">
						<xsl:text>The Petitioner's </xsl:text>
						<span about="this:IP1" property="corp-insolvency:practitionerType">
							<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
						</span>
						<xsl:text> is </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>The </xsl:text>
						<span about="this:IP1" property="corp-insolvency:practitionerType">
							<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
						</span>
						<xsl:text>(s) is/are </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='foaf:name']/text() != ''">
					<span about="this:IP1" property="foaf:name" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
					</span>
					<xsl:if test="$updates//*[@about='this:IP2' and @property='foaf:name']/text() != '' and ($pc1=$pc2)">
						<xsl:text> and </xsl:text>
						<span about="this:IP2" property="foaf:name" datatype="xsd:string">
							<xsl:value-of select="$updates//*[@about='this:IP2' and @property='foaf:name']/text()"/>
						</span>
					</xsl:if>
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''">
					<span about="this:IP-company-1" property="gazorg:name" datatype="xsd:string">
						<xsl:value-of select="upper-case($updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text())"/>
					</span>
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:IP1-address-1'"/>
				</xsl:call-template>
				<xsl:if test="$pc1!=$pc2">
					<xsl:if test="$updates//*[@about='this:IP2' and @property='foaf:name']/text() != ''">
						<xsl:text> and </xsl:text>
						<span about="this:IP2" property="foaf:name" datatype="xsd:string">
							<xsl:value-of select="$updates//*[@about='this:IP2' and @property='foaf:name']/text()"/>
						</span>
					</xsl:if>
					<xsl:if test="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text() != ''">
						<xsl:text>, </xsl:text>
						<span about="this:IP-company-2" property="gazorg:name" datatype="xsd:string">
							<xsl:value-of select="upper-case($updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text())"/>
						</span>
					</xsl:if>
					<xsl:if test="$updates//*[@about='this:IP2-address-1']">
						<xsl:text>, </xsl:text>
						<xsl:call-template name="address">
							<xsl:with-param name="updates" select="$updates"/>
							<xsl:with-param name="about" select="'this:IP2-address-1'"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
					<xsl:text>, Telephone: </xsl:text>
					<span about="this:IP1" property="gaz:telephone" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text()"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
					<xsl:if test="$updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:text> Fax: </xsl:text>
					<span about="this:IP1" property="gaz:fax" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:fax']/text()"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''">
					<xsl:if test="$updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:text> Email: </xsl:text>
					<span about="this:IP1" property="gaz:email" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:email']/text()"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''">
					<xsl:text> (Reference number: </xsl:text>
					<span about="this:IP1" property="person:hasIPReferenceNumber" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text()"/>
						<xsl:text>.)</xsl:text>
					</span>
				</xsl:if>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text() != ''">
			<p>
				<xsl:variable name="noticeDated">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text()"/>
				</xsl:variable>
				<span about="this:IP1" property="person:noticeDated" datatype="xsd:date" content="{$noticeDated}">
					<xsl:value-of select="format-date(xs:date($noticeDated), '[FNn] [D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text() != ''">
			<p>
				<span about="this:IP1" property="person:additionalInformationIP" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text()"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2450Edinburgh">
		<xsl:param name="updates"/>
		<h3 about="this:company-1" property="gazorg:name" typeof=" " datatype="xsd:string">
			<xsl:attribute name="typeof"><xsl:value-of select="wlf:getCompanyType($updates//*[@about='this:company-1' and @property='gazorg:companyType']/text())"/></xsl:attribute>
			<xsl:value-of select="upper-case($updates//*[@about='this:company-1' and @property='gazorg:name']/text())"/>
		</h3>
		<p>
			<xsl:text>(</xsl:text>
			<span about="this:company-1" property="gazorg:companyNumber" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:companyNumber']/text()"/>
			</span>
			<xsl:text>)</xsl:text>
		</p>
		<p>
			<span about="this:court-1" property="court:courtName" datatype="xsd:string">
				<xsl:if test="$updates//*[@property='court:courtName' and contains(.,'Session')]">
					<xsl:text>THE </xsl:text>
					<xsl:value-of select="upper-case($updates//*[@about='this:court-1' and @property='court:courtName']/text())"/>
				</xsl:if>
				<xsl:if test="$updates//*[@property='court:courtName' and not(contains(.,'Session'))]">
					<xsl:text>SHERIFFDOM OF </xsl:text>
					<xsl:value-of select="upper-case($countyCourts//*:courtName[text() = $updates//*[@about='this:court-1' and @property='court:countyCourtName']/text()]/@sheriffdom)"/>
					<xsl:text> OF </xsl:text>
					<xsl:value-of select="upper-case($updates//*[@about='this:court-1' and @property='court:countyCourtName']/text())"/>
				</xsl:if>
			</span>
		</p>
		<p>
			<xsl:variable name="courtCode">
				<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:caseCode']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtNumber">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtYear">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
			</xsl:variable>
			<xsl:if test="starts-with($courtCode,'No')">
				<span>
					<xsl:text>No. </xsl:text>
					<span about="this:court-case-1" property="court:caseNumber" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
					</span>
					<xsl:text> of </xsl:text>
					<span about="this:court-case-1" property="court:caseYear" datatype="xsd:gYear">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
					</span>
				</span>
			</xsl:if>
			<xsl:if test="starts-with($courtCode,'CR') or starts-with($courtCode,'BR')">
				<span>
					<span about="this:court-case-1" property="court:caseCode" datatype="xsd:string">
						<xsl:value-of select="replace(replace($courtCode,'YYYY',$courtYear),'####',$courtNumber)"/>
					</span>
				</span>
			</xsl:if>
		</p>
		<p>
			<xsl:text>Notice is hereby given that on </xsl:text>
			<xsl:variable name="dateOfPetitionPresentation">
				<xsl:value-of select="format-date(xs:date($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfPetitionPresentation']/text()),'[FNn] [D01] [MNn] [Y0001]')"/>
			</xsl:variable>
			<xsl:variable name="timeOfPetitionPresentation">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfPetitionPresentationWITHtime']/text()"/>
			</xsl:variable>
			<xsl:variable name="dateOfPetitionPresentationValue">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfPetitionPresentation']/text()"/>
			</xsl:variable>
			<xsl:variable name="PetitionPresentation">
				<xsl:value-of select="concat($dateOfPetitionPresentationValue,'T',$timeOfPetitionPresentation,':00')"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfPetitionPresentation" datatype="xsd:date" content="{$dateOfPetitionPresentationValue}">
				<xsl:value-of select="concat($dateOfPetitionPresentation,', at ',$timeOfPetitionPresentation)"/>
			</span>
			<xsl:text> a Petition was presented to </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:sheriffName" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:sheriffName']/text()"/>
			</span>
			<span about="this:court-1" property="court:courtName" datatype="xsd:string">
				<xsl:if test="$updates//*[@property='court:courtName' and not(contains(.,'Session'))]">
					<xsl:text> at </xsl:text>
					<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:countyCourtName']/text()"/>
					<xsl:text> Sheriff Court at </xsl:text>
					<xsl:call-template name="address">
						<xsl:with-param name="updates" select="$updates"/>
						<xsl:with-param name="about" select="'this:hearingAddress'"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="$updates//*[@property='court:courtName' and contains(.,'Session')]">
					<xsl:text> to the Court of Session</xsl:text>
				</xsl:if>
			</span>
			<xsl:text> by </xsl:text>
			<span about="this:petitioner-1" property="foaf:name" datatype="xsd:string">
				<xsl:value-of select="upper-case($updates//*[@about='this:petitioner-1' and @property='foaf:name']/text())"/>
			</span>, 
            <xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:petitioner-address-1'"/>
			</xsl:call-template>
			<xsl:text> (the Petitioner) craving the Court inter alia for an order under the </xsl:text>
			<span about="this:legislation-1" property="legislation:legislationTitle" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:legislation-1' and @property='legislation:legislationTitle']/text()"/>
			</span>
			<xsl:text> to wind up </xsl:text>
			<xsl:value-of select="upper-case($updates//*[@about='this:company-1' and @property='gazorg:name']/text())"/>
			<xsl:text> (Company Number: </xsl:text>
			<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:companyNumber']/text()"/>
			<xsl:text>) </xsl:text>
			<xsl:if test="not(exists($updates//*[@about='this:principal-trading-address-1' and @property='vcard:outside-uk-address']))">
				<xsl:text> having its registered office at </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:principal-trading-address-1'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:previous-trading-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:country']/text() != ''">
				<xsl:text>, previously of </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:previous-trading-address-1'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:principal-trading-address-1' and @property='vcard:outside-uk-address']/text()='on'">
				<span about="this:principal-trading-address-1" property="vcard:outside-uk-address" content="true" data-type="xsd:boolean"/>
				<xsl:text>, </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:company-registered-office-1'"/>
				</xsl:call-template>
				<xsl:text> (where service of the petition was effected)</xsl:text>
			</xsl:if>
			<xsl:text>, in which Petition the Sheriff by interlocutor dated </xsl:text>
			<xsl:variable name="dateOfInterlocutor">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfInterlocutor']/text()"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfInterlocutor" datatype="xsd:date" content="{$dateOfInterlocutor}">
				<xsl:value-of select="format-date(xs:date($dateOfInterlocutor), '[FNn] [D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text> appointed Notice of the import of the Petition and of the deliverance, and of the particulars specified in the Act of Sederunt to be advertised once in the Edinburgh Gazette; ordained the said </xsl:text>
			<xsl:value-of select="upper-case($updates//*[@about='this:company-1' and @property='gazorg:name']/text())"/>
			<xsl:text> and any other persons interested, if they intended to show cause why the prayer of the Petition should not be granted, to lodge Answers thereto in the hands of the </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:personToLodgeAnswersTo" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:personToLodgeAnswersTo']/text()"/>
			</span>
			<xsl:text> at </xsl:text>
			<xsl:if test="$updates//*[@property='court:courtName' and not(contains(.,'Session'))]">
				<span about="this:notifiableThing" property="corp-insolvency:nameOfPlaceOfHearing" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:countyCourtName']/text()"/>
				</span>
				<xsl:text> Sheriff Court at </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:hearingAddress'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$updates//*[@property='court:courtName' and contains(.,'Session')]">
				<xsl:text> the </xsl:text>
				<span about="this:notifiableThing" property="corp-insolvency:nameOfPlaceOfHearing" datatype="xsd:string">
					<xsl:text>Court of Session, </xsl:text>
				</span>
				<span about="this:hearingAddress" property="vcard:street-address" typeof="vcard:Address">Parliament House</span>, 
                    <span about="this:hearingAddress" property="vcard:extended-address">Parliament Square</span>, 
                    <span about="this:hearingAddress" property="vcard:locality">Edinburgh</span>, 
                    <span about="this:hearingAddress" property="vcard:postal-code">EH1 1RQ</span>
			</xsl:if>
			<xsl:text> within eight days after such intimation, service or advertisement, under certification; all of which notice is hereby given.</xsl:text>
		</p>
		<xsl:choose>
			<xsl:when test="$updates//*[@about='this:IP1' and @property='foaf:name']/text() != ''">
				<p>
					<span about="this:IP1" property="foaf:name" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
					</span>
					<xsl:text>, </xsl:text>
					<xsl:if test="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''">
						<span about="this:IP-company-1" property="gazorg:name" datatype="xsd:string">
							<xsl:value-of select="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text()"/>
						</span>
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:call-template name="address">
						<xsl:with-param name="updates" select="$updates"/>
						<xsl:with-param name="about" select="'this:IP1-address-1'"/>
					</xsl:call-template>
					<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
						<xsl:text>, Telephone: </xsl:text>
						<span about="this:IP1" property="gaz:telephone" datatype="xsd:string">
							<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text()"/>
						</span>
					</xsl:if>
					<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
						<xsl:if test="$updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:text> Fax: </xsl:text>
						<span about="this:IP1" property="gaz:fax" datatype="xsd:string">
							<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:fax']/text()"/>
						</span>
					</xsl:if>
					<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''">
						<xsl:if test="$updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:text> Email: </xsl:text>
						<span about="this:IP1" property="gaz:email" datatype="xsd:string">
							<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:email']/text()"/>
						</span>
					</xsl:if>
					<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''">
						<xsl:text> (Reference number: </xsl:text>
						<span about="this:IP1" property="person:hasIPReferenceNumber" datatype="xsd:string">
							<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text()"/>
						</span>
						<xsl:text>)</xsl:text>
					</xsl:if>
					<xsl:if test="$updates//*[@about='this:IP2' and @property='foaf:name']/text() != ''">
						<xsl:text>, and </xsl:text>
						<span about="this:IP2" property="foaf:name" datatype="xsd:string">
							<xsl:value-of select="$updates//*[@about='this:IP2' and @property='foaf:name']/text()"/>
						</span>
						<xsl:text>, </xsl:text>
						<xsl:if test="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text() != ''">
							<span about="this:IP-company-2" property="gazorg:name" datatype="xsd:string">
								<xsl:value-of select="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text()"/>
							</span>
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:call-template name="address">
							<xsl:with-param name="updates" select="$updates"/>
							<xsl:with-param name="about" select="'this:IP2-address-1'"/>
						</xsl:call-template>
					</xsl:if>
				</p>
				<p>
					<xsl:text>Agent for the Petitioner</xsl:text>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<p>
					<span about="this:petitioner-1" property="foaf:name" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:petitioner-1' and @property='foaf:name']/text()"/>
					</span>
					<xsl:text>, </xsl:text>
					<xsl:call-template name="address">
						<xsl:with-param name="updates" select="$updates"/>
						<xsl:with-param name="about" select="'this:petitioner-address-1'"/>
					</xsl:call-template>
				</p>
				<p>
					<xsl:text>Petitioner</xsl:text>
				</p>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text() != ''">
			<p>
				<xsl:variable name="noticeDated">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text()"/>
				</xsl:variable>
				<span about="this:IP1" property="person:noticeDated" datatype="xsd:date" content="{$noticeDated}">
					<xsl:value-of select="format-date(xs:date($noticeDated), '[FNn] [D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text() != ''">
			<p>
				<span about="this:IP1" property="person:additionalInformationIP" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text()"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2450Belfast">
		<xsl:param name="updates"/>
		<p>
			<xsl:text>In the </xsl:text>
			<span about="this:court-1" property="court:courtName" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:courtName']/text()"/>
			</span>
		</p>
		<p>
			<xsl:variable name="courtCode">
				<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:caseCode']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtNumber">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtYear">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
			</xsl:variable>
			<xsl:if test="starts-with($courtCode,'No')">
				<span>
					<xsl:text>No. </xsl:text>
					<span about="this:court-case-1" property="court:caseNumber" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
					</span>
					<xsl:text> of </xsl:text>
					<span about="this:court-case-1" property="court:caseYear" datatype="xsd:gYear">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
					</span>
				</span>
			</xsl:if>
			<xsl:if test="starts-with($courtCode,'CR') or starts-with($courtCode,'BR')">
				<span>
					<span about="this:court-case-1" property="court:caseCode" datatype="xsd:string">
						<xsl:value-of select="replace(replace($courtCode,'YYYY',$courtYear),'####',$courtNumber)"/>
					</span>
				</span>
			</xsl:if>
		</p>
		<p>
			<xsl:text>In the matter of </xsl:text>
			<strong about="this:company-1" property="gazorg:name" typeof=" " datatype="xsd:string">
				<xsl:attribute name="typeof"><xsl:value-of select="wlf:getCompanyType($updates//*[@about='this:company-1' and @property='gazorg:companyType']/text())"/></xsl:attribute>
				<xsl:value-of select="upper-case($updates//*[@about='this:company-1' and @property='gazorg:name']/text())"/>
			</strong>
		</p>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text() != ''">
			<p>
				<xsl:text>Previously: </xsl:text>
				<span about="this:company-1" property="gazorg:previousCompanyName" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text() != ''">
			<p>
				<xsl:text>Trading As: </xsl:text>
				<span about="this:company-1" property="gazorg:tradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text() != ''">
			<p>
				<xsl:text>Previously Trading As: </xsl:text>
				<span about="this:company-1" property="gazorg:previouslyTradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<p>
			<xsl:text>and in the matter of the </xsl:text>
			<span about="this:legislation-1" property="legislation:legislationTitle" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:legislation-1' and @property='legislation:legislationTitle']/text()"/>
			</span>
			<xsl:text>,</xsl:text>
		</p>
		<p>
			<xsl:text>A Petition to wind up </xsl:text>
			<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:name']/text()"/>
			<xsl:text> (</xsl:text>
			<xsl:if test="$updates//*[@about='this:principal-trading-address-1' and @property='vcard:outside-uk-address']/text()='on'">
				<span about="this:principal-trading-address-1" property="vcard:outside-uk-address" content="true" data-type="xsd:boolean"/>
			</xsl:if>
			<span about="this:company-1" property="gazorg:companyNumber" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:companyNumber']/text()"/>
			</span>
			<xsl:text>)</xsl:text>
			<xsl:text> of </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:principal-trading-address-1'"/>
			</xsl:call-template>
			<xsl:if test="$updates//*[@about='this:previous-trading-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:country']/text() != ''">
				<xsl:text>, previously of </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:previous-trading-address-1'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:company-registered-office-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:company-registered-office-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:company-registered-office-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:company-registered-office-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:company-registered-office-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:company-registered-office-1' and @property='vcard:country']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:company-registered-office-1'"/>
				</xsl:call-template>
				<xsl:text> (where service of the petition was effected)</xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:natureOfBusiness']/text() != ''">
				<xsl:text>, whose nature of business is </xsl:text>
				<span about="this:company-1" property="gazorg:natureOfBusiness" datatype="xsd:string" data-recommended="true">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:natureOfBusiness']/text()"/>
				</span>
			</xsl:if>
			<xsl:text>, presented on </xsl:text>
			<xsl:variable name="dateOfPetitionPresentation">
				<xsl:value-of select="format-date(xs:date($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfPetitionPresentation']/text()),'[FNn] [D01] [MNn] [Y0001]')"/>
			</xsl:variable>
			<xsl:variable name="timeOfPetitionPresentation">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfPetitionPresentationWITHtime']/text()"/>
			</xsl:variable>
			<xsl:variable name="dateOfPetitionPresentationValue">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfPetitionPresentation']/text()"/>
			</xsl:variable>
			<xsl:variable name="PetitionPresentation">
				<xsl:value-of select="concat($dateOfPetitionPresentationValue,'T',$timeOfPetitionPresentation,':00')"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfPetitionPresentation" datatype="xsd:date" content="{$dateOfPetitionPresentationValue}">
				<xsl:value-of select="concat($dateOfPetitionPresentation,', at ',$timeOfPetitionPresentation)"/>
			</span>
			<xsl:text> by </xsl:text>
			<span about="this:petitioner-1" property="foaf:name" datatype="xsd:string">
				<xsl:value-of select="upper-case($updates//*[@about='this:petitioner-1' and @property='foaf:name']/text())"/>
			</span>
			<xsl:text>, of </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:petitioner-address-1'"/>
			</xsl:call-template>
			<xsl:text> claiming to be a </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:presentedBy" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:presentedBy']/text()"/>
			</span>
			<xsl:text> of the Company, will be heard at the </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:nameOfPlaceOfHearing" datatype="xsd:string">
				<xsl:text>Royal Courts of Justice</xsl:text>, 
            </span>
			<span about="this:hearingAddress" property="vcard:street-address" typeof="vcard:Address">Chichester Street</span>,
            <span about="this:hearingAddress" property="vcard:locality">Belfast</span>, 
            <span about="this:hearingAddress" property="vcard:postal-code">BT1 3JE</span>
			<xsl:text>, on </xsl:text>
			<xsl:variable name="dateOfHearing">
				<xsl:value-of select="format-date(xs:date($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfHearing'][1]/text()),'[FNn] [D01] [MNn] [Y0001]')"/>
			</xsl:variable>
			<xsl:variable name="timeOfHearing">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfHearingWITHtime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="dateOfHearingValue">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfHearing'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="hearing">
				<xsl:value-of select="concat($dateOfHearingValue,'T',$timeOfHearing,':00')"/>
			</xsl:variable>
			<span about="this:notifiableThing" datatype="xsd:dateTime" property="corp-insolvency:dateOfHearing" content="{$hearing}">
				<xsl:value-of select="concat($dateOfHearing,', at ',$timeOfHearing)"/>
			</span>
			<xsl:text> hours (or as soon thereafter as the Petition can be heard).</xsl:text>
		</p>
		<xsl:variable name="dateInsolvencyRule">
			<xsl:value-of select="format-date(xs:date($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateToRequestAppearance']/text()),'[FNn] [D01] [MNn] [Y0001]')"/>
		</xsl:variable>
		<xsl:variable name="timeInsolvencyRule">
			<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateToRequestAppearanceWITHtime']/text()"/>
		</xsl:variable>
		<xsl:variable name="dateInsolvencyRuleValue">
			<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateToRequestAppearance']/text()"/>
		</xsl:variable>
		<xsl:variable name="InsolvencyRule">
			<xsl:value-of select="concat($dateInsolvencyRuleValue,'T',$timeInsolvencyRule,':00')"/>
		</xsl:variable>
		<p>
			<xsl:text>Any person intending to appear on the hearing of the Petition (whether to support or oppose it) must give notice of intention to do so to the Petitioners or to their Solicitor in accordance with Rule 4.016 of the Insolvency Rules (Northern Island) 1991 by </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:dateToRequestAppearance" datatype="xsd:dateTime" content="{$InsolvencyRule}">
				<xsl:value-of select="concat($timeInsolvencyRule,' hours on ',$dateInsolvencyRule)"/>
			</span>
		</p>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='foaf:name']/text() != ''
	or $updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''
	or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''
	or $updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''
	or $updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''
	or $updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != ''">
			<p>
				<xsl:variable name="pc1">
					<xsl:value-of select="$updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']"/>
				</xsl:variable>
				<xsl:variable name="pc2">
					<xsl:value-of select="$updates//*[@about='this:IP2-address-1' and @property='vcard:postal-code']"/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text() = 'Solicitor'">
						<xsl:text>The Petitioner's </xsl:text>
						<span about="this:IP1" property="corp-insolvency:practitionerType">
							<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
						</span>
						<xsl:text> is </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>The </xsl:text>
						<span about="this:IP1" property="corp-insolvency:practitionerType">
							<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
						</span>
						<xsl:text>(s) is/are </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='foaf:name']/text() != ''">
					<span about="this:IP1" property="foaf:name" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
					</span>
					<xsl:if test="$updates//*[@about='this:IP2' and @property='foaf:name']/text() != '' and ($pc1=$pc2)">
						<xsl:text> and </xsl:text>
						<span about="this:IP2" property="foaf:name" datatype="xsd:string">
							<xsl:value-of select="$updates//*[@about='this:IP2' and @property='foaf:name']/text()"/>
						</span>
					</xsl:if>
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''">
					<span about="this:IP-company-1" property="gazorg:name" datatype="xsd:string">
						<xsl:value-of select="upper-case($updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text())"/>
					</span>
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:IP1-address-1'"/>
				</xsl:call-template>
				<xsl:if test="$pc1!=$pc2">
					<xsl:if test="$updates//*[@about='this:IP2' and @property='foaf:name']/text() != ''">
						<xsl:text> and </xsl:text>
						<span about="this:IP2" property="foaf:name" datatype="xsd:string">
							<xsl:value-of select="$updates//*[@about='this:IP2' and @property='foaf:name']/text()"/>
						</span>
					</xsl:if>
					<xsl:if test="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text() != ''">
						<xsl:text>, </xsl:text>
						<span about="this:IP-company-2" property="gazorg:name" datatype="xsd:string">
							<xsl:value-of select="upper-case($updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text())"/>
						</span>
					</xsl:if>
					<xsl:if test="$updates//*[@about='this:IP2-address-1']">
						<xsl:text>, </xsl:text>
						<xsl:call-template name="address">
							<xsl:with-param name="updates" select="$updates"/>
							<xsl:with-param name="about" select="'this:IP2-address-1'"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
					<xsl:text>, Telephone: </xsl:text>
					<span about="this:IP1" property="gaz:telephone" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text()"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
					<xsl:if test="$updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:text> Fax: </xsl:text>
					<span about="this:IP1" property="gaz:fax" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:fax']/text()"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''">
					<xsl:if test="$updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:text> Email: </xsl:text>
					<span about="this:IP1" property="gaz:email" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:email']/text()"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''">
					<xsl:text> (Reference number: </xsl:text>
					<span about="this:IP1" property="person:hasIPReferenceNumber" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text()"/>
						<xsl:text>.)</xsl:text>
					</span>
				</xsl:if>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text() != ''">
			<p>
				<xsl:variable name="noticeDated">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text()"/>
				</xsl:variable>
				<span about="this:IP1" property="person:noticeDated" datatype="xsd:date" content="{$noticeDated}">
					<xsl:value-of select="format-date(xs:date($noticeDated), '[FNn] [D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text() != ''">
			<p>
				<span about="this:IP1" property="person:additionalInformationIP" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text()"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2451">
		<xsl:param name="updates"/>
		<p>
			<xsl:text>In the </xsl:text>
			<span about="this:court-1" property="court:courtName" datatype="xsd:string">
				<xsl:if test="$updates//*[@property='court:courtName' and contains(.,'High Court')]">
					<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:courtName']/text()"/>
				</xsl:if>
				<xsl:if test="$updates//*[@property='court:courtName' and not(contains(.,'High Court'))]">
					<xsl:text>County Court at </xsl:text>
					<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:countyCourtName']/text()"/>
				</xsl:if>
			</span>
		</p>
		<p>
			<span about="this:court-1" property="court:courtDistrict" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:courtDistrict']/text()"/>
			</span>
			<xsl:variable name="courtCode">
				<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:caseCode']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtNumber">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtYear">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
			</xsl:variable>
			<xsl:if test="starts-with($courtCode,'No')">
				<span>
					<xsl:text>No. </xsl:text>
					<span about="this:court-case-1" property="court:caseNumber" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
					</span>
					<xsl:text> of </xsl:text>
					<span about="this:court-case-1" property="court:caseYear" datatype="xsd:gYear">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
					</span>
				</span>
			</xsl:if>
			<xsl:if test="starts-with($courtCode,'CR') or starts-with($courtCode,'BR')">
				<span>
					<span about="this:court-case-1" property="court:caseCode" datatype="xsd:string">
						<xsl:value-of select="replace(replace($courtCode,'YYYY',$courtYear),'####',$courtNumber)"/>
					</span>
				</span>
			</xsl:if>
		</p>
		<p data-gazettes="Company" property="insolvency:hasCompany" resource="this:company-1" typeof="gazorg:Partnership">
			<xsl:text>In the matter of </xsl:text>
			<strong about="this:company-1" property="gazorg:name" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:name']/text()"/>
			</strong>
			<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:partnershipType']/text() != 'General Partnership'">
				<xsl:text> (</xsl:text>
				<span about="this:company-1" property="gazorg:partnershipNumber">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:partnershipNumber']"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:text>, a </xsl:text>
			<span about="this:company-1" property="gazorg:partnershipType" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:partnershipType']/text()"/>
			</span>
			<xsl:text>,</xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text() != ''">
			<p>
				<xsl:text>Previously: </xsl:text>
				<span about="this:company-1" property="gazorg:previousCompanyName" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text() != ''">
			<p>
				<xsl:text>Trading As: </xsl:text>
				<span about="this:company-1" property="gazorg:tradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text() != ''">
			<p>
				<xsl:text>Previously Trading As: </xsl:text>
				<span about="this:company-1" property="gazorg:previouslyTradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<p>
			<xsl:text>and in the Matter of the </xsl:text>
			<xsl:variable name="legValue">
				<xsl:choose>
					<xsl:when test="$updates//*[@about='this:company-1' and @property='gazorg:partnershipType']/text() = 'Limited Liability Partnership'">Insolvency Act 1986 as applied by The Limited Liability Partnerships Regulations 2001</xsl:when>
					<xsl:when test="$updates//*[@about='this:company-1' and @property='gazorg:partnershipType']/text() != 'Limited Liability Partnership'">Insolvency Act 1986 as modified by Insolvent Partnerships Order 1994</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<span about="this:legislation-1" property="legislation:legislationTitle" datatype="xsd:string">
				<xsl:value-of select="$legValue"/>
			</span>
		</p>
		<p>
			<xsl:text>A Petition to wind up the above-named Partnership of </xsl:text>
			<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:name']/text()"/>
			<xsl:text> of </xsl:text>
			<xsl:if test="$updates//*[@about='this:company-principal-trading-address-1' and @property='vcard:postal-code']/text() != ''">
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:company-principal-trading-address-1'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:previous-trading-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:country']/text() != ''">
				<span>
					<xsl:text> previously of </xsl:text>
					<xsl:call-template name="address">
						<xsl:with-param name="updates" select="$updates"/>
						<xsl:with-param name="about" select="'this:previous-trading-address-1'"/>
					</xsl:call-template>
					<xsl:text>, </xsl:text>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:company-registered-office-1' and @property='vcard:postal-code']/text() != ''">
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:company-registered-office-1'"/>
				</xsl:call-template>
				<xsl:text> (where service of the petition was effected), </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:country']/text() != ''">
				<span>
					<xsl:text>previously of </xsl:text>
					<xsl:call-template name="address">
						<xsl:with-param name="updates" select="$updates"/>
						<xsl:with-param name="about" select="'this:company-previous-registered-office-1'"/>
					</xsl:call-template>
					<xsl:text>, </xsl:text>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:natureOfBusiness']/text() != ''">
				<xsl:text>whose nature of business is </xsl:text>
				<span about="this:company-1" property="gazorg:natureOfBusiness" datatype="xsd:string" data-recommended="true">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:natureOfBusiness']/text()"/>
					<xsl:text>, </xsl:text>
				</span>
			</xsl:if>
			<xsl:text>presented on </xsl:text>
			<xsl:variable name="dateOfPetitionPresentation">
				<xsl:value-of select="format-date(xs:date($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfPetitionPresentation']/text()),'[FNn] [D01] [MNn] [Y0001]')"/>
			</xsl:variable>
			<xsl:variable name="timeOfPetitionPresentation">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfPetitionPresentationWITHtime']/text()"/>
			</xsl:variable>
			<xsl:variable name="dateOfPetitionPresentationValue">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfPetitionPresentation']/text()"/>
			</xsl:variable>
			<xsl:variable name="PetitionPresentation">
				<xsl:value-of select="concat($dateOfPetitionPresentationValue,'T',$timeOfPetitionPresentation,':00')"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfPetitionPresentation" datatype="xsd:date" content="{$dateOfPetitionPresentationValue}">
				<xsl:value-of select="concat($dateOfPetitionPresentation,', at ',$timeOfPetitionPresentation)"/>
			</span>
			<xsl:text> by </xsl:text>
			<span about="this:petitioner-1" property="foaf:name" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:petitioner-1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:text> of </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:petitioner-address-1'"/>
			</xsl:call-template>
			<xsl:text> claiming to be a </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:presentedBy">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:presentedBy']/text()"/>
			</span>
			<xsl:text> of the Partnership, will be heard at the </xsl:text>
			<xsl:if test="$updates//*[@property='court:courtName' and contains(.,'High Court')]">
				<span about="this:notifiableThing" property="corp-insolvency:nameOfPlaceOfHearing" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:nameOfPlaceOfHearing']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@property='court:courtName' and not(contains(.,'High Court'))]">
				<xsl:text>County Court at </xsl:text>
				<span about="this:notifiableThing" property="corp-insolvency:nameOfPlaceOfHearing" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:nameOfPlaceOfHearing']/text()"/>
				</span>
			</xsl:if>
			<xsl:text>, </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:hearingAddress'"/>
			</xsl:call-template>
			<xsl:variable name="dateOfHearing">
				<xsl:value-of select="format-date(xs:date($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfHearing'][1]/text()),'[D01] [MNn] [Y0001]')"/>
			</xsl:variable>
			<xsl:variable name="timeOfHearing">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfHearingWITHtime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="dateOfHearingValue">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfHearing'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="hearing">
				<xsl:value-of select="concat($dateOfHearingValue,'T',$timeOfHearing,':00')"/>
			</xsl:variable>
			<xsl:text> on </xsl:text>
			<span about="this:notifiableThing" datatype="xsd:dateTime" property="corp-insolvency:dateOfHearing" content="{$hearing}">
				<xsl:value-of select="concat($dateOfHearing,' at ',$timeOfHearing)"/>
			</span>
			<xsl:text> (or as soon thereafter as the Petition can be heard).</xsl:text>
		</p>
		<xsl:variable name="dateInsolvencyRule">
			<xsl:value-of select="format-date(xs:date($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateToRequestAppearance']/text()),'[FNn] [D01] [MNn] [Y0001]')"/>
		</xsl:variable>
		<xsl:variable name="timeInsolvencyRule">
			<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateToRequestAppearanceWITHtime']/text()"/>
		</xsl:variable>
		<xsl:variable name="dateInsolvencyRuleValue">
			<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateToRequestAppearance']/text()"/>
		</xsl:variable>
		<xsl:variable name="InsolvencyRule">
			<xsl:value-of select="concat($dateInsolvencyRuleValue,'T',$timeInsolvencyRule,':00')"/>
		</xsl:variable>
		<p>
			<xsl:text>Any persons intending to appear on the hearing of the Petition (whether to support or oppose it) must give notice of intention to do so to the Petitioners or to their Solicitor in accordance with Rule 7.14 by </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:dateToRequestAppearance" datatype="xsd:dateTime" content="{$InsolvencyRule}">
				<xsl:value-of select="concat($timeInsolvencyRule,' hours on ',$dateInsolvencyRule)"/>
			</span>
			<xsl:text>.</xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='foaf:name']/text() != ''
	or $updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''
	or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''
	or $updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''
	or $updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''
	or $updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != ''
	or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != ''">
			<p>
				<xsl:choose>
					<xsl:when test="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text() = 'Solicitor'">
						<xsl:text>The Petitioner's </xsl:text>
						<span about="this:IP1" property="corp-insolvency:practitionerType">
							<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
						</span>
						<xsl:text> is </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>The </xsl:text>
						<span about="this:IP1" property="corp-insolvency:practitionerType">
							<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
						</span>
						<xsl:text> is </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='foaf:name']/text() != ''">
					<span about="this:IP1" property="foaf:name" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''">
					<xsl:text>, </xsl:text>
					<span about="this:IP-company-1" property="gazorg:name" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text()"/>
					</span>
				</xsl:if>
				<xsl:text>, </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:IP1-address-1'"/>
				</xsl:call-template>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
					<xsl:if test="$updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != ''">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:text>Telephone: </xsl:text>
					<span about="this:IP1" property="gaz:telephone" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text()"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
					<xsl:if test="$updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:text> Fax: </xsl:text>
					<span about="this:IP1" property="gaz:fax" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:fax']/text()"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''">
					<xsl:if test="$updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:text> Email: </xsl:text>
					<span about="this:IP1" property="gaz:email" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:email']/text()"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''">
					<xsl:text> (Reference number: </xsl:text>
					<span about="this:IP1" property="person:hasIPReferenceNumber" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text()"/>
						<xsl:text>.)</xsl:text>
					</span>
				</xsl:if>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text() != ''">
			<p>
				<xsl:variable name="noticeDated">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text()"/>
				</xsl:variable>
				<span about="this:IP1" property="person:noticeDated" datatype="xsd:date" content="{$noticeDated}">
					<xsl:value-of select="format-date(xs:date($noticeDated), '[FNn] [D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text() != ''">
			<p>
				<span about="this:IP1" property="person:additionalInformationIP" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text()"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2451Belfast">
		<xsl:param name="updates"/>
		<p>
			<xsl:text>In the </xsl:text>
			<span about="this:court-1" property="court:courtName" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:courtName']/text()"/>
			</span>
		</p>
		<p>
			<span about="this:court-1" property="court:courtDistrict" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:courtDistrict']/text()"/>
			</span>
			<xsl:variable name="courtCode">
				<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:caseCode']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtNumber">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtYear">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
			</xsl:variable>
			<xsl:if test="starts-with($courtCode,'No')">
				<span>
					<xsl:text>No. </xsl:text>
					<span about="this:court-case-1" property="court:caseNumber" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
					</span>
					<xsl:text> of </xsl:text>
					<span about="this:court-case-1" property="court:caseYear" datatype="xsd:gYear">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
					</span>
				</span>
			</xsl:if>
			<xsl:if test="starts-with($courtCode,'CR') or starts-with($courtCode,'BR')">
				<span>
					<span about="this:court-case-1" property="court:caseCode" datatype="xsd:string">
						<xsl:value-of select="replace(replace($courtCode,'YYYY',$courtYear),'####',$courtNumber)"/>
					</span>
				</span>
			</xsl:if>
		</p>
		<p data-gazettes="Company" property="insolvency:hasCompany" resource="this:company-1" typeof="gazorg:Partnership">
			<xsl:text>In the matter of </xsl:text>
			<span about="this:company-1" property="gazorg:name" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:name']/text()"/>
			</span>
			<xsl:text>, a </xsl:text>
			<span about="this:company-1" property="gazorg:partnershipType" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:partnershipType']/text()"/>
			</span>
			<xsl:text>,</xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text() != ''">
			<p>
				<xsl:text>Previously: </xsl:text>
				<span about="this:company-1" property="gazorg:previousCompanyName" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text() != ''">
			<p>
				<xsl:text>Trading As: </xsl:text>
				<span about="this:company-1" property="gazorg:tradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text() != ''">
			<p>
				<xsl:text>Previously Trading As: </xsl:text>
				<span about="this:company-1" property="gazorg:previouslyTradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<p>
			<xsl:text>and in the matter of the </xsl:text>
			<xsl:variable name="legValue">
				<xsl:choose>
					<xsl:when test="$updates//*[@about='this:company-1' and @property='gazorg:partnershipType']/text() = 'Limited Liability Partnership'">Insolvency (Northern Ireland) Order 1989 as applied by The Limited Liability Partnerships Regulations (Northern Ireland) 2004</xsl:when>
					<xsl:when test="$updates//*[@about='this:company-1' and @property='gazorg:partnershipType']/text() != 'Limited Liability Partnership'">Insolvency (Northern Ireland) Order 1989 as modified by The Insolvent Partnerships Order (Northern Ireland) 1995</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<span about="this:legislation-1" property="legislation:legislationTitle" datatype="xsd:string">
				<xsl:value-of select="$legValue"/>
			</span>
		</p>
		<p>
			<xsl:text>A Petition to wind up </xsl:text>
			<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:name']/text()"/>
			<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:partnershipType']/text() != 'General Partnership'">
				<xsl:text> (</xsl:text>
				<span about="this:company-1" property="gazorg:partnershipNumber">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:partnershipNumber']/text()"/>
				</span>
				<xsl:text>) </xsl:text>
				<xsl:text> whose registered office is at </xsl:text>
				<span about="this:company-registered-office-1">
					<xsl:call-template name="address">
						<xsl:with-param name="updates" select="$updates"/>
						<xsl:with-param name="about" select="'this:company-registered-office-1'"/>
					</xsl:call-template>
				</span>
				<xsl:if test="$updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:country']/text() != ''">
					<xsl:text>, previously of </xsl:text>
					<xsl:call-template name="address">
						<xsl:with-param name="updates" select="$updates"/>
						<xsl:with-param name="about" select="'this:company-previous-registered-office-1'"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:partnershipType']/text() != 'Limited Liability Partnership'">
				<xsl:text> at </xsl:text>
				<span about="this:company-principal-trading-address-1">
					<xsl:call-template name="address">
						<xsl:with-param name="updates" select="$updates"/>
						<xsl:with-param name="about" select="'this:company-principal-trading-address-1'"/>
					</xsl:call-template>
				</span>
				<xsl:if test="$updates//*[@about='this:previous-trading-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:country']/text() != ''">
					<xsl:text>, previously of </xsl:text>
					<xsl:call-template name="address">
						<xsl:with-param name="updates" select="$updates"/>
						<xsl:with-param name="about" select="'this:previous-trading-address-1'"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:if>
			<xsl:text>, </xsl:text>
			<xsl:text>whose nature of business is </xsl:text>
			<span about="this:company-1" property="gazorg:natureOfBusiness" datatype="xsd:string" data-recommended="true">
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:natureOfBusiness']/text()"/>
			</span>
			<xsl:text>, presented on </xsl:text>
			<xsl:variable name="dateOfPetitionPresentation">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfPetitionPresentation']/text()"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfPetitionPresentation" datatype="xsd:date" content="{$dateOfPetitionPresentation}">
				<xsl:value-of select="format-date(xs:date($dateOfPetitionPresentation), '[D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text> by </xsl:text>
			<span about="this:petitioner-1" property="foaf:name" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:petitioner-1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:text> of </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:petitioner-address-1'"/>
			</xsl:call-template>
			<xsl:text> claiming to be a </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:presentedBy">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:presentedBy']/text()"/>
			</span>
			<xsl:text> of the Partnership, will be heard at </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:nameOfPlaceOfHearing">
				<xsl:text>the Royal Courts of Justice</xsl:text>
			</span>
			<xsl:text>, </xsl:text>
			<span about="this:hearingAddress" property="vcard:street-address" typeof="vcard:Address">Chichester Street</span>,
            <span about="this:hearingAddress" property="vcard:locality">Belfast</span>, 
            <span about="this:hearingAddress" property="vcard:postal-code">BT1 3JE</span>
			<xsl:variable name="dateOfHearing">
				<xsl:value-of select="format-date(xs:date($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfHearing'][1]/text()),'[D01] [MNn] [Y0001]')"/>
			</xsl:variable>
			<xsl:variable name="dayOfHearing">
				<xsl:value-of select="format-date(xs:date($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfHearing'][1]/text()),'[FNn]')"/>
			</xsl:variable>
			<xsl:variable name="timeOfHearing">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfHearingWITHtime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="dateOfHearingValue">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfHearing'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="hearing">
				<xsl:value-of select="concat($dateOfHearingValue,'T',$timeOfHearing,':00')"/>
			</xsl:variable>
			<xsl:text>, on </xsl:text>
			<span about="this:notifiableThing" datatype="xsd:dateTime" property="corp-insolvency:dateOfHearing" content="{$hearing}">
				<xsl:value-of select="$dayOfHearing"/>
				<xsl:text>, </xsl:text>
				<xsl:value-of select="concat($dateOfHearing,' at ',$timeOfHearing)"/>
			</span>
			<xsl:text> hours (or as soon thereafter as the Petition can be heard).</xsl:text>
		</p>
		<p>
			<xsl:variable name="dateInsolvencyRule">
				<xsl:value-of select="format-date(xs:date($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateToRequestAppearance']/text()),'[FNn], [D01] [MNn] [Y0001]')"/>
			</xsl:variable>
			<xsl:variable name="timeInsolvencyRule">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateToRequestAppearanceWITHtime']/text()"/>
			</xsl:variable>
			<xsl:variable name="dateInsolvencyRuleValue">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateToRequestAppearance']/text()"/>
			</xsl:variable>
			<xsl:variable name="InsolvencyRule">
				<xsl:value-of select="concat($dateInsolvencyRuleValue,'T',$timeInsolvencyRule,':00')"/>
			</xsl:variable>
			<xsl:text>Any persons intending to appear on the hearing of the Petition (whether to support or oppose it) must give notice of intention to do so to the Petitioners or their Solicitor in accordance with Rule 4.016 of the Insolvency Rules (Northern Ireland) 1991 by </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:dateToRequestAppearance" datatype="xsd:dateTime" content="{$InsolvencyRule}">
				<xsl:value-of select="concat($timeInsolvencyRule,' hours on ',$dateInsolvencyRule)"/>
			</span>
			<xsl:text>.</xsl:text>
		</p>
		<p>
			<xsl:text>Crown Solicitor for Northern Ireland</xsl:text>
			<br clear="none"/>
			<xsl:text>Crown Solicitor&apos;s Office</xsl:text>
			<br clear="none"/>
			<xsl:text>Royal Courts of Justice</xsl:text>
			<br clear="none"/>
			<xsl:text>Chichester Street</xsl:text>
			<br clear="none"/>
			<xsl:text>Belfast</xsl:text>
			<br clear="none"/>
			<xsl:text>BT1 3JE</xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text() != ''">
			<p>
				<xsl:variable name="noticeDated">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text()"/>
				</xsl:variable>
				<span about="this:IP1" property="person:noticeDated" datatype="xsd:date" content="{$noticeDated}">
					<xsl:value-of select="format-date(xs:date($noticeDated), '[FNn] [D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text() != ''">
			<p>
				<span about="this:IP1" property="person:additionalInformationIP" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text()"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2451Edinburgh">
		<xsl:param name="updates"/>
		<h3 about="this:company-1" property="gazorg:name" datatype="xsd:string">
			<span data-gazettes="Company" property="insolvency:hasCompany" resource="this:company-1" typeof="gazorg:Partnership"/>
			<xsl:value-of select="upper-case($updates//*[@about='this:company-1' and @property='gazorg:name']/text())"/>
		</h3>
		<h3 about="this:court-1" property="court:courtName" datatype="xsd:string">
			<xsl:if test="$updates//*[@property='court:courtName' and contains(.,'Session')]">
				<xsl:text>THE </xsl:text>
				<xsl:value-of select="upper-case($updates//*[@about='this:court-1' and @property='court:courtName']/text())"/>
			</xsl:if>
			<xsl:if test="$updates//*[@property='court:courtName' and not(contains(.,'Session'))]">
				<xsl:text>SHERIFFDOM OF </xsl:text>
				<xsl:value-of select="upper-case($countyCourts//*:courtName[text() = $updates//*[@about='this:court-1' and @property='court:countyCourtName']/text()]/@sheriffdom)"/>
				<xsl:text> OF </xsl:text>
				<xsl:value-of select="upper-case($updates//*[@about='this:court-1' and @property='court:countyCourtName']/text())"/>
			</xsl:if>
		</h3>
		<p>
			<xsl:variable name="courtCode">
				<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:caseCode']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtNumber">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtYear">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
			</xsl:variable>
			<xsl:if test="starts-with($courtCode,'No')">
				<span>
					<xsl:text>No. </xsl:text>
					<span about="this:court-case-1" property="court:caseNumber" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
					</span>
					<xsl:text> of </xsl:text>
					<span about="this:court-case-1" property="court:caseYear" datatype="xsd:gYear">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
					</span>
				</span>
			</xsl:if>
			<xsl:if test="starts-with($courtCode,'CR') or starts-with($courtCode,'BR')">
				<span>
					<span about="this:court-case-1" property="court:caseCode" datatype="xsd:string">
						<xsl:value-of select="replace(replace($courtCode,'YYYY',$courtYear),'####',$courtNumber)"/>
					</span>
				</span>
			</xsl:if>
		</p>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:partnershipNumber']/text() != ''">
			<p>
				<xsl:text>(</xsl:text>
				<span about="this:company-1" property="gazorg:partnershipNumber" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:partnershipNumber']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</p>
		</xsl:if>
		<p>
			<xsl:text>Notice is hereby given that on </xsl:text>
			<xsl:variable name="dateOfPetitionPresentation">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfPetitionPresentation']/text()"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfPetitionPresentation" datatype="xsd:date" content="{$dateOfPetitionPresentation}">
				<xsl:value-of select="format-date(xs:date($dateOfPetitionPresentation), '[FNn] [D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text> a Petition was presented to the Sheriff at </xsl:text>
			<xsl:if test="$updates//*[@property='court:courtName' and not(contains(.,'Session'))]">
				<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:countyCourtName']/text()"/>
			</xsl:if>
			<xsl:if test="$updates//*[@property='court:courtName' and contains(.,'Session')]">
				<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:courtName']/text()"/>
			</xsl:if>
			<xsl:text> by </xsl:text>
			<span about="this:petitioner-1" property="foaf:name" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:petitioner-1' and @property='foaf:name']/text()"/>
				<xsl:text>, </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:petitioner-address-1'"/>
				</xsl:call-template>
			</span>
			<xsl:text> craving the Court inter alia that </xsl:text>
			<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:name']/text()"/>
			<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:partnershipType']/text() = 'Limited Liability Partnership'">
				<xsl:text>, a limited liability partnership with LLP Number </xsl:text>
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:partnershipNumber']/text()"/>
				<xsl:text> and having its registered office at </xsl:text>
				<span about="this:company-registered-office-1">
					<xsl:call-template name="address">
						<xsl:with-param name="updates" select="$updates"/>
						<xsl:with-param name="about" select="'this:company-registered-office-1'"/>
					</xsl:call-template>
				</span>
				<xsl:if test="$updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:country']/text() != ''">
					<xsl:text> previously of </xsl:text>
					<xsl:call-template name="address">
						<xsl:with-param name="updates" select="$updates"/>
						<xsl:with-param name="about" select="'this:company-previous-registered-office-1'"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:partnershipType']/text() != 'Limited Liability Partnership'">
				<xsl:text>, a partnership with Partnership Number </xsl:text>
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:partnershipNumber']/text()"/>
				<xsl:text> and having its principal trading address at </xsl:text>
				<span about="this:company-principal-trading-address-1">
					<xsl:call-template name="address">
						<xsl:with-param name="updates" select="$updates"/>
						<xsl:with-param name="about" select="'this:company-principal-trading-address-1'"/>
					</xsl:call-template>
				</span>
				<xsl:if test="$updates//*[@about='this:previous-trading-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:previous-trading-address-1' and @property='vcard:country']/text() != ''">
					<xsl:text> previously of </xsl:text>
					<xsl:call-template name="address">
						<xsl:with-param name="updates" select="$updates"/>
						<xsl:with-param name="about" select="'this:previous-trading-address-1'"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:if>
			<xsl:text>, (&quot;the Partnership&quot;) be wound up under the </xsl:text>
			<xsl:variable name="legValue">
				<xsl:choose>
					<xsl:when test="$updates//*[@about='this:company-1' and @property='gazorg:partnershipType']/text() = 'Limited Liability Partnership'">Insolvency Act 1986 as applied by The Limited Liability Partnerships Regulations 2001</xsl:when>
					<xsl:when test="$updates//*[@about='this:company-1' and @property='gazorg:partnershipType']/text() != 'Limited Liability Partnership'">Insolvency Act 1986 as modified by Insolvent Partnerships Order 1994</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<span about="this:legislation-1" property="legislation:legislationTitle" datatype="xsd:string">
				<xsl:value-of select="$legValue"/>
			</span>
			<xsl:text> and that </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:provisionalLiquidator" resource="this:pro-liquidator-1"/>
			<span about="this:pro-liquidator-1" property="foaf:name" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:pro-liquidator-1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:text>, </xsl:text>
			<span about="this:pro-liquidator-1" property="person:jobTitle" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:pro-liquidator-1' and @property='person:jobTitle']/text()"/>
			</span>
			<xsl:text> of </xsl:text>
			<xsl:if test="$updates//*[@about='this:pro-liquidator-1-org-1' and @property='gazorg:name']/text() != ''">
				<span about="this:pro-liquidator-1" property="gazorg:hasOrganisationMember" resource="this:pro-liquidator-1-org-1"/>
				<span about="this:pro-liquidator-1-org-1" property="gazorg:name">
					<xsl:value-of select="$updates//*[@about='this:pro-liquidator-1-org-1' and @property='gazorg:name']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:pro-liquidator-1-adr-1'"/>
			</xsl:call-template>
			<xsl:text>, be appointed as Interim Liquidator of the Partnership; in which Petition the Sheriff by interlocutor dated </xsl:text>
			<xsl:variable name="dateOfInterlocutor">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfInterlocutor']/text()"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfInterlocutor" datatype="xsd:date" content="{$dateOfInterlocutor}">
				<xsl:value-of select="format-date(xs:date($dateOfInterlocutor), '[FNn] [D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text> ordained the Partnership or any other persons interested, if they intend to show cause why the Petition should not be granted, to lodge Answers in the hands of the Sheriff Clerk at </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:nameOfPlaceOfHearing" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:nameOfPlaceOfHearing']/text()"/>
			</span>
			<xsl:text> within eight days after intimation, service or advertisement; all of which notice is hereby given.</xsl:text>
		</p>
		<p>
			<span about="this:IP1" property="corp-insolvency:practitionerType">
				<xsl:attribute name="content"><xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/></xsl:attribute>
			</span>
			<span about="this:IP1" property="foaf:name" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:text>, </xsl:text>
			<span about="this:IP-company-1" property="gazorg:name" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
			</span>
			<xsl:text>, </xsl:text>
			<xsl:if test="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''">
				<span about="this:IP-company-1" property="gazorg:name" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:IP1-address-1'"/>
			</xsl:call-template>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
				<xsl:if test="$updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != ''">
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:text>Telephone: </xsl:text>
				<span about="this:IP1" property="gaz:telephone" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
				<xsl:if test="$updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
					<xsl:text>,</xsl:text>
				</xsl:if>
				<xsl:text> Fax: </xsl:text>
				<span about="this:IP1" property="gaz:fax" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:fax']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''">
				<xsl:if test="$updates//*[@about='this:IP1-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:IP1-address-1' and @property='vcard:country']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
					<xsl:text>,</xsl:text>
				</xsl:if>
				<xsl:text> Email: </xsl:text>
				<span about="this:IP1" property="gaz:email" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:email']/text()"/>
				</span>
			</xsl:if>
		</p>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text() != ''">
			<p>
				<xsl:variable name="noticeDated">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text()"/>
				</xsl:variable>
				<span about="this:IP1" property="person:noticeDated" datatype="xsd:date" content="{$noticeDated}">
					<xsl:value-of select="format-date(xs:date($noticeDated), '[FNn] [D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text() != ''">
			<p>
				<span about="this:IP1" property="person:additionalInformationIP" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text()"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2441">
		<xsl:param name="updates"/>
		<xsl:variable name="edition">
			<xsl:value-of select="$updates//*[@property='gaz:hasEdition']/text()"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$edition = 'belfast'">
				<span about="http://www.legislation.gov.uk/nisi/1989/2405/article/70" datatype="xsd:string" property="rdfs:label" content="The Insolvency (Northern Ireland) Order 1989 (Art. 70 (1A))"/>
			</xsl:when>
			<xsl:otherwise>
				<span about="http://www.legislation.gov.uk/ukpga/1986/45/section/84" datatype="xsd:string" property="rdfs:label" content="Insolvency Act 1986 (S.84)"/>
			</xsl:otherwise>
		</xsl:choose>
		<h3 about="this:company-1" property="gazorg:name" typeof=" " datatype="xsd:string">
			<xsl:attribute name="typeof"><xsl:value-of select="wlf:getCompanyType($updates//*[@about='this:company-1' and @property='gazorg:companyType']/text())"/></xsl:attribute>
			<xsl:value-of select="upper-case($updates//*[@about='this:company-1' and @property='gazorg:name']/text())"/>
		</h3>
		<p>
			<xsl:text>(Company Number: </xsl:text>
			<span about="this:company-1" property="gazorg:companyNumber" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:companyNumber']/text()"/>
			</span>
			<xsl:text>)</xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text() != ''">
			<p>previously <span about="this:company-1" property="gazorg:previousCompanyName" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text() != ''">
			<p>trading as <span about="this:company-1" property="gazorg:tradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text() != ''">
			<p>previously trading as <span about="this:company-1" property="gazorg:previouslyTradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text()"/>
				</span>
			</p>
		</xsl:if>
		<p>Registered Office: <xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:company-registered-office-1'"/>
			</xsl:call-template>
		</p>
		<p>Principal Trading Address: <xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:company-principal-trading-address-1'"/>
			</xsl:call-template>
		</p>
		<xsl:if test="$updates//*[@about='this:previous-trading-address-1' and @property='vcard:street-address']/text() != ''">
			<p>
				<xsl:text>Previous Principal Trading Address: </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:previous-trading-address-1'"/>
				</xsl:call-template>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:natureOfBusiness']/text() != ''">
			<p>Nature of Business: <span about="this:company-1" property="gazorg:natureOfBusiness" datatype="xsd:string" data-recommended="true">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:natureOfBusiness']/text()"/>
				</span>
			</p>
		</xsl:if>
		<p>
			<xsl:text>At a </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:hasMeetingType">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasMeetingType']"/>
			</span>
			<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text() != 'All'">
				<xsl:text> of the </xsl:text>
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']"/>
			</xsl:if>
			<xsl:text> of the above-named Company, duly convened, and held </xsl:text>
			<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasDecisionMakingProcedure']/text() = 'Physical meeting'">
				<xsl:text> at </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:meetingAddress-1'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasDecisionMakingProcedure']/text() = 'Virtual meeting'">
				<xsl:text> remotely </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasDecisionMakingProcedure']/text() = 'Correspondence'">
				<xsl:text> by correspondence </xsl:text>
			</xsl:if>
			<xsl:text> on </xsl:text>
			<xsl:variable name="corpInsolvencyMeetingDate">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfResolution'][1]/text()"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfResolution" datatype="xsd:date" content="{$corpInsolvencyMeetingDate}">
				<xsl:value-of select="format-date(xs:date($corpInsolvencyMeetingDate), '[FNn] [D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text>, the following Resolution/s was/were duly passed:</xsl:text>
		</p>
		<p>
			<span about="this:notifiableThing" property="corp-insolvency:hasResolution" resource="this:resolution-1" typeof="corp-insolvency:MeetingResolution"/>
			<span about="this:resolution-1" property="corp-insolvency:hasResolutionNumber" content="1" datatype="xsd:integer">1. </span>
			<span about="this:resolution-1" property="corp-insolvency:hasResolutionType" datatype="xsd:string">
				<xsl:text>(</xsl:text>
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolutionType-1']"/>
				<xsl:text>) </xsl:text>
			</span>
			<span about="this:resolution-1" property="rdfs:label" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolution-1']"/>
			</span>
		</p>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolution-2']/text() != ''">
			<p>
				<span about="this:resolution-2" property="corp-insolvency:hasResolutionNumber" content="2" datatype="xsd:integer">2. </span>
				<span about="this:resolution-2" property="corp-insolvency:hasResolutionType" datatype="xsd:string">
					<xsl:text>(</xsl:text>
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolutionType-2']"/>
					<xsl:text>) </xsl:text>
				</span>
				<span about="this:resolution-2" property="rdfs:label" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolution-2']"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolution-3']/text() != ''">
			<p>
				<span about="this:resolution-3" property="corp-insolvency:hasResolutionNumber" content="3" datatype="xsd:integer">3. </span>
				<span about="this:resolution-3" property="corp-insolvency:hasResolutionType" datatype="xsd:string">
					<xsl:text>(</xsl:text>
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolutionType-3']"/>
					<xsl:text>) </xsl:text>
				</span>
				<span about="this:resolution-3" property="rdfs:label" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolution-3']"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolution-4']/text() != ''">
			<p>
				<span about="this:resolution-4" property="corp-insolvency:hasResolutionNumber" content="4" datatype="xsd:integer">4. </span>
				<span about="this:resolution-4" property="corp-insolvency:hasResolutionType" datatype="xsd:string">
					<xsl:text>(</xsl:text>
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolutionType-4']"/>
					<xsl:text>) </xsl:text>
				</span>
				<span about="this:resolution-4" property="rdfs:label" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolution-4']"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolution-5']/text() != ''">
			<p>
				<span about="this:resolution-5" property="corp-insolvency:hasResolutionNumber" content="5" datatype="xsd:integer">5. </span>
				<span about="this:resolution-5" property="corp-insolvency:hasResolutionType" datatype="xsd:string">
					<xsl:text>(</xsl:text>
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolutionType-5']"/>
					<xsl:text>) </xsl:text>
				</span>
				<span about="this:resolution-5" property="rdfs:label" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolution-5']"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolution-6']/text() != ''">
			<p>
				<span about="this:resolution-6" property="corp-insolvency:hasResolutionNumber" content="6" datatype="xsd:integer">6. </span>
				<span about="this:resolution-6" property="corp-insolvency:hasResolutionType" datatype="xsd:string">
					<xsl:text>(</xsl:text>
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolutionType-6']"/>
					<xsl:text>) </xsl:text>
				</span>
				<span about="this:resolution-6" property="rdfs:label" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasResolution-6']"/>
				</span>
			</p>
		</xsl:if>
		<p>
			<xsl:text>For further details, please contact: </xsl:text>
			<span about="this:IP1" property="foaf:name">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:text>, (</xsl:text>
			<span about="this:IP1" property="person:hasIPnum">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPnum']"/>
			</span>
			<xsl:text>)</xsl:text>
			<xsl:if test="$updates//*[@about='this:IP2']/text() != ''">
				<xsl:text>, and </xsl:text>
				<xsl:if test="$updates//*[@about='this:IP2' and @property='foaf:name']/text() != ''">
					<span about="this:IP2" typeof="person:InsolvencyPractitioner" property="foaf:name">
						<xsl:value-of select="$updates//*[@about='this:IP2' and @property='foaf:name']"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP2' and @property='person:hasIPnum']/text() != ''">
					<xsl:text>, (</xsl:text>
					<span about="this:IP2" property="person:hasIPnum">
						<xsl:value-of select="$updates//*[@about='this:IP2' and @property='person:hasIPnum']"/>
					</span>
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text()"/>
			</xsl:if>
			<xsl:text>, </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:IP1-address-1'"/>
			</xsl:call-template>
			<xsl:if test="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text() != ''">
				<xsl:text>, or </xsl:text>
				<span about="this:IP-company-2" property="gazorg:name">
					<xsl:value-of select="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP2-address-1' and @property='vcard:postal-code']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:IP2-address-1'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
				<xsl:text>, Telephone: </xsl:text>
				<span about="this:IP1" property="gaz:telephone" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''">
				<xsl:text>, Email address: </xsl:text>
				<span about="this:IP1" property="gaz:email" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:email']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
				<xsl:text>, Fax: </xsl:text>
				<span about="this:IP1" property="gaz:fax" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:fax']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''">
				<xsl:text>, (</xsl:text>
				<span about="this:IP1" property="person:hasIPReferenceNumber" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:text>.</xsl:text>
		</p>
		<p>
			<span about="this:signatory-1" property="foaf:name">
				<xsl:value-of select="$updates//*[@about='this:signatory-1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:text>, </xsl:text>
			<span about="this:role-signatory-1" property="person:roleName">
				<xsl:value-of select="$updates//*[@about='this:role-signatory-1' and @property='person:roleName']/text()"/>
			</span>
		</p>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text() != ''">
			<p>
				<xsl:variable name="noticeDated">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text()"/>
				</xsl:variable>
				<span about="this:IP1" property="person:noticeDated" datatype="xsd:date" content="{$noticeDated}">
					<xsl:value-of select="format-date(xs:date($noticeDated), '[FNn] [D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text() != ''">
			<p>
				<span about="this:IP1" property="person:additionalInformationIP" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text()"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2442">
		<xsl:param name="updates"/>
		<h3 about="this:company-1" property="gazorg:name" typeof=" " datatype="xsd:string">
			<xsl:attribute name="typeof"><xsl:value-of select="wlf:getCompanyType($updates//*[@about='this:company-1' and @property='gazorg:companyType']/text())"/></xsl:attribute>
			<xsl:value-of select="upper-case($updates//*[@about='this:company-1' and @property='gazorg:name']/text())"/>
		</h3>
		<p>
			<xsl:text>(Company Number: </xsl:text>
			<span about="this:company-1" property="gazorg:companyNumber" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:companyNumber']/text()"/>
			</span>
			<xsl:text>)</xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text() != ''">
			<p>Previously: <span about="this:company-1" property="gazorg:previousCompanyName" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text() != ''">
			<p>Trading As: <span about="this:company-1" property="gazorg:tradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text() != ''">
			<p>Previously Trading As: <span about="this:company-1" property="gazorg:previouslyTradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text()"/>
				</span>
			</p>
		</xsl:if>
		<p>Registered Office: <xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:company-registered-office-1'"/>
			</xsl:call-template>
		</p>
		<p>Principal Trading Address: <xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:company-principal-trading-address-1'"/>
			</xsl:call-template>
		</p>
		<p>
			<xsl:text>Notice is hereby given, pursuant to </xsl:text>
			<span about="this:legislation-1" property="legislation:legislationTitle" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:legislation-1' and @property='legislation:legislationTitle']/text()"/>
			</span>
			<xsl:text> that the </xsl:text>
			<span about="this:IP1" property="corp-insolvency:practitionerType">
				<xsl:value-of select="lower-case($updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text())"/>
			</span>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()='Liquidator'">
				<xsl:text> has </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()='Joint Liquidators'">
				<xsl:text> have </xsl:text>
			</xsl:if>
			<xsl:text>summoned a general meeting of the Company's </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:typeOfAttendees" datatype="xsd:string">
				<xsl:value-of select="lower-case($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text())"/>
			</span>
			<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:meetingRequestedByCreditor']/text() = 'Yes'">
				<xsl:text> as requested by the creditors </xsl:text>
			</xsl:if>
			<xsl:text> for the purpose of </xsl:text>
			<!-- streamline in future update -->
			<span about="this:notifiableThing" property="corp-insolvency:hasPurpose" resource="this:purpose-1" typeof="corp-insolvency:MeetingPurpose"/>
			<xsl:variable name="multiplePurposeText">
				<span about="this:purpose-1" property="rdfs:label">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasPurpose-1']/text()"/>
				</span>
				<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasPurpose-2']/text() != ''">
					<span about="this:notifiableThing" property="corp-insolvency:hasPurpose" resource="this:purpose-2" typeof="corp-insolvency:MeetingPurpose"/>
					<xsl:choose>
						<xsl:when test="$updates//*[@property='corp-insolvency:hasPurpose-3']/text() != ''">
							<xsl:text>; </xsl:text>
						</xsl:when>
						<xsl:when test="$updates//*[@property='corp-insolvency:hasPurpose-3' and not(node())]">
							<xsl:text> and </xsl:text>
						</xsl:when>
					</xsl:choose>
					<span about="this:purpose-2" property="rdfs:label">
						<xsl:text/>
						<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasPurpose-2']/text()"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasPurpose-3']/text() != ''">
					<span about="this:notifiableThing" property="corp-insolvency:hasPurpose" resource="this:purpose-3" typeof="corp-insolvency:MeetingPurpose"/>
					<xsl:choose>
						<xsl:when test="$updates//*[@property='corp-insolvency:hasPurpose-4']/text() != ''">
							<xsl:text>; </xsl:text>
						</xsl:when>
						<xsl:when test="$updates//*[@property='corp-insolvency:hasPurpose-4' and not(node())]">
							<xsl:text> and </xsl:text>
						</xsl:when>
					</xsl:choose>
					<span about="this:purpose-3" property="rdfs:label">
						<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasPurpose-3']/text()"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasPurpose-4']/text() != ''">
					<span about="this:notifiableThing" property="corp-insolvency:hasPurpose" resource="this:purpose-4" typeof="corp-insolvency:MeetingPurpose"/>
					<xsl:choose>
						<xsl:when test="$updates//*[@property='corp-insolvency:hasPurpose-5']/text() != ''">
							<xsl:text>; </xsl:text>
						</xsl:when>
						<xsl:when test="$updates//*[@property='corp-insolvency:hasPurpose-5' and not(node())]">
							<xsl:text> and </xsl:text>
						</xsl:when>
					</xsl:choose>
					<span about="this:purpose-4" property="rdfs:label">
						<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasPurpose-4']/text()"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasPurpose-5']/text() != ''">
					<span about="this:notifiableThing" property="corp-insolvency:hasPurpose" resource="this:purpose-5" typeof="corp-insolvency:MeetingPurpose"/>
					<xsl:choose>
						<xsl:when test="$updates//*[@property='corp-insolvency:hasPurpose-6']/text() != ''">
							<xsl:text>; </xsl:text>
						</xsl:when>
						<xsl:when test="$updates//*[@property='corp-insolvency:hasPurpose-6' and not(node())]">
							<xsl:text> and </xsl:text>
						</xsl:when>
					</xsl:choose>
					<span about="this:purpose-5" property="rdfs:label">
						<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasPurpose-5']/text()"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasPurpose-6']/text() != ''">
					<span about="this:notifiableThing" property="corp-insolvency:hasPurpose" resource="this:purpose-6" typeof="corp-insolvency:MeetingPurpose"/>
					<xsl:text> and </xsl:text>
					<span about="this:purpose-6" property="rdfs:label">
						<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasPurpose-6']/text()"/>
					</span>
				</xsl:if>
			</xsl:variable>
			<xsl:copy-of select="$multiplePurposeText"/>
			<!-- Horrible, but necessary for now, bit of code to ensure last character is a period -->
			<xsl:if test="substring($multiplePurposeText, string-length($multiplePurposeText), string-length($multiplePurposeText) - 1) != '.'">
				<xsl:text>.</xsl:text>
			</xsl:if>
			<xsl:text> The meeting will be held </xsl:text>
			<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasDecisionMakingProcedure']/text()='Physical meeting'">
				<xsl:text>at </xsl:text>
				<span about="this:notifiableThing" property="corp-insolvency:hasDecisionMakingProcedure" content="Physical meeting" datatype="xsd:string"/>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:meetingAddress-1'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasDecisionMakingProcedure']/text()='Virtual meeting'">
				<span about="this:notifiableThing" property="corp-insolvency:hasDecisionMakingProcedure" content="Virtual meeting" datatype="xsd:string"/>
			</xsl:if>
			<xsl:variable name="corpInsolvencyMeetingDate">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:meetingTime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyMeetingTime">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:meetingTimeWITHtime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyMeetingDateAndTime">
				<xsl:value-of select="concat($corpInsolvencyMeetingDate, 'T', $corpInsolvencyMeetingTime, ':00')"/>
			</xsl:variable>
			<xsl:text> on </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:meetingTime" datatype="xsd:dateTime" content="{$corpInsolvencyMeetingDateAndTime}">
				<xsl:value-of select="format-date(xs:date($corpInsolvencyMeetingDate), '[D01] [MNn] [Y0001]')"/>, at <xsl:value-of select="$corpInsolvencyMeetingTime"/>
			</span>
			<xsl:text>.</xsl:text>
		</p>
		<p>
			<xsl:text>In order to be entitled to vote at the meeting, creditors must lodge proxies and hitherto unlodged proofs with </xsl:text>
			<span about="this:IP1" typeof="person:InsolvencyPractitioner">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:text> at </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:address-for-lodging-proofs-1'"/>
			</xsl:call-template>
			<xsl:text> by no later than </xsl:text>
			<xsl:variable name="corpInsolvencyProvingDate">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebts'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyProvingTime">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebtsWITHtime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyProvingDateAndTime">
				<xsl:value-of select="concat($corpInsolvencyProvingDate, 'T', $corpInsolvencyProvingTime, ':00')"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:onOrBeforeProvingDebts" datatype="xsd:dateTime" content="{$corpInsolvencyProvingDateAndTime}">
				<xsl:value-of select="$corpInsolvencyProvingTime"/> on <xsl:value-of select="format-date(xs:date($corpInsolvencyProvingDate), '[D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text>.</xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:debtsProved']/text() = 'Yes'">
			<p>
				<xsl:text>The </xsl:text>
				<span about="this:IP1" typeof="person:InsolvencyPractitioner" property="corp-insolvency:practitionerType">
					<xsl:value-of select="lower-case($updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text())"/>
				</span>
				<xsl:text> will treat any debts of &#163;1,000 or less as proved for the purposes of paying a dividend, unless creditors advise the </xsl:text>
				<xsl:value-of select="lower-case($updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text())"/>
				<xsl:text> that the amount of the debt is incorrect (in which case, proofs must be submitted) or that no debt is owed, also by </xsl:text>
				<xsl:variable name="corpInsolvencyProvingDate">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebts'][1]/text()"/>
				</xsl:variable>
				<xsl:variable name="corpInsolvencyProvingTime">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebtsWITHtime'][1]/text()"/>
				</xsl:variable>
				<xsl:variable name="corpInsolvencyProvingDateAndTime">
					<xsl:value-of select="concat($corpInsolvencyProvingDate, 'T', $corpInsolvencyProvingTime, ':00')"/>
				</xsl:variable>
				<xsl:value-of select="$corpInsolvencyProvingTime"/> on <xsl:value-of select="format-date(xs:date($corpInsolvencyProvingDate), '[D01] [MNn] [Y0001]')"/>
				<xsl:text>.</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:debtsProved']/text() = 'Yes'">
			<p>
				<xsl:text>Any creditor who has opted out from receiving notices may nevertheless vote if the creditor provides a proof by </xsl:text>
				<xsl:variable name="corpInsolvencyProvingDate">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebts'][1]/text()"/>
				</xsl:variable>
				<xsl:variable name="corpInsolvencyProvingTime">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebtsWITHtime'][1]/text()"/>
				</xsl:variable>
				<xsl:variable name="corpInsolvencyProvingDateAndTime">
					<xsl:value-of select="concat($corpInsolvencyProvingDate, 'T', $corpInsolvencyProvingTime, ':00')"/>
				</xsl:variable>
				<xsl:value-of select="$corpInsolvencyProvingTime"/> on <xsl:value-of select="format-date(xs:date($corpInsolvencyProvingDate), '[D01] [MNn] [Y0001]')"/>
				<xsl:text>.</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text() != ''">
			<p>
				<span about="this:IP1" property="person:additionalInformationIP" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text()"/>
				</span>
			</p>
		</xsl:if>
		<p>
			<xsl:text>For further details, please contact: </xsl:text>
			<span about="this:IP1" property="foaf:name">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:text> (</xsl:text>
			<span about="this:IP1" property="person:hasIPnum">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPnum']"/>
			</span>
			<xsl:text>)</xsl:text>
			<xsl:if test="$updates//*[@about='this:IP2']/text() != ''">
				<xsl:text>, and </xsl:text>
				<xsl:if test="$updates//*[@about='this:IP2' and @property='foaf:name']/text() != ''">
					<span about="this:IP2" typeof="person:InsolvencyPractitioner" property="foaf:name">
						<xsl:value-of select="$updates//*[@about='this:IP2' and @property='foaf:name']"/>
					</span>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:IP2' and @property='person:hasIPnum']/text() != ''">
					<xsl:text>, (</xsl:text>
					<span about="this:IP2" property="person:hasIPnum">
						<xsl:value-of select="$updates//*[@about='this:IP2' and @property='person:hasIPnum']"/>
					</span>
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text()"/>
			</xsl:if>
			<xsl:text>, </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:IP1-address-1'"/>
			</xsl:call-template>
			<xsl:if test="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text() != ''">
				<xsl:text>, or </xsl:text>
				<span about="this:IP-company-2" property="gazorg:name">
					<xsl:value-of select="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP2-address-1' and @property='vcard:postal-code']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:IP2-address-1'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
				<xsl:text>, Telephone: </xsl:text>
				<span about="this:IP1" property="gaz:telephone" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''">
				<xsl:text>, Email address: </xsl:text>
				<span about="this:IP1" property="gaz:email" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:email']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
				<xsl:text>, Fax: </xsl:text>
				<span about="this:IP1" property="gaz:fax" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:fax']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''">
				<xsl:text>, (</xsl:text>
				<span about="this:IP1" property="person:hasIPReferenceNumber" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:text>.</xsl:text>
		</p>
		<p>
			<em about="this:signatory-1" property="foaf:name">
				<xsl:value-of select="$updates//*[@about='this:signatory-1' and @property='foaf:name']/text()"/>
			</em>
			<xsl:text>, </xsl:text>
			<span about="this:role-signatory-1" property="person:roleName">
				<xsl:value-of select="$updates//*[@about='this:role-signatory-1' and @property='person:roleName']/text()"/>
			</span>
		</p>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text() != ''">
			<p>
				<xsl:variable name="noticeDated">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text()"/>
				</xsl:variable>
				<span about="this:IP1" property="person:noticeDated" datatype="xsd:date" content="{$noticeDated}">
					<xsl:value-of select="format-date(xs:date($noticeDated), '[FNn] [D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2443">
		<xsl:param name="updates"/>
		<span about="this:legislation-1" property="legislation:legislationTitle" datatype="xsd:string">
			<xsl:attribute name="content"><xsl:value-of select="$updates//*[@about='this:legislation-1' and @property='legislation:legislationTitle']/text()"/></xsl:attribute>
		</span>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasAppointer']/text() = 'By Order of the Court'">
			<p>
				<xsl:text>In the </xsl:text>
				<xsl:if test="$updates//*[@about='this:court-1' and @property='court:courtName']">
					<span about="this:court-1" property="court:courtName" datatype="xsd:string">
						<xsl:if test="$updates//*[@property='court:courtName' and (contains(.,'High Court') or contains(.,'Court of Session'))]">
							<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:courtName']/text()"/>
						</xsl:if>
						<xsl:if test="$updates//*[@property='court:courtName' and not(contains(.,'High Court')) and not(contains(.,'Court of Session'))]">
							<xsl:text>County Court at </xsl:text>
							<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:countyCourtName']/text()"/>
						</xsl:if>
					</span>
				</xsl:if>
			</p>
			<p>
				<xsl:variable name="courtCode">
					<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:caseCode']/text()"/>
				</xsl:variable>
				<xsl:variable name="courtNumber">
					<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
				</xsl:variable>
				<xsl:variable name="courtYear">
					<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
				</xsl:variable>
				<xsl:text>Chancery Division Court Number: </xsl:text>
				<xsl:if test="starts-with($courtCode,'No')">
					<span>
						<xsl:text>No. </xsl:text>
						<span about="this:court-case-1" property="court:caseNumber" datatype="xsd:string">
							<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
						</span>
						<xsl:text> of </xsl:text>
						<span about="this:court-case-1" property="court:caseYear" datatype="xsd:gYear">
							<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
						</span>
					</span>
				</xsl:if>
				<xsl:if test="starts-with($courtCode,'CR') or starts-with($courtCode,'BR')">
					<span>
						<span about="this:court-case-1" property="court:caseCode" datatype="xsd:string">
							<xsl:value-of select="replace(replace($courtCode,'YYYY',$courtYear),'####',$courtNumber)"/>
						</span>
					</span>
				</xsl:if>
			</p>
		</xsl:if>
		<p>
			<xsl:text>Name of Company: </xsl:text>
			<span about="this:company-1" property="gazorg:name" typeof="" datatype="xsd:string">
				<xsl:attribute name="typeof"><xsl:value-of select="wlf:getCompanyType($updates//*[@about='this:company-1' and @property='gazorg:companyType']/text())"/></xsl:attribute>
				<xsl:value-of select="upper-case($updates//*[@about='this:company-1' and @property='gazorg:name']/text())"/>
			</span>
		</p>
		<p>
			<xsl:text>Company Number: </xsl:text>
			<xsl:choose>
				<xsl:when test="$updates//*[@about='this:company-1' and @property='gazorg:companyType']/text() = 'Partnership'">
					<span about="this:company-1" property="gazorg:partnershipNumber" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:companyNumber']/text()"/>
					</span>
				</xsl:when>
				<xsl:otherwise>
					<span about="this:company-1" property="gazorg:companyNumber" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:companyNumber']/text()"/>
					</span>
				</xsl:otherwise>
			</xsl:choose>
		</p>
		<p>
			<xsl:text>Company Type: </xsl:text>
			<span about="this:company-1" property="gazorg:companyType" datatype="xsd:string">
				<xsl:choose>
					<xsl:when test="$updates//*[@about='this:company-1' and @property='gazorg:companyType']/text() = 'Registered'">
						<xsl:text>Registered Company</xsl:text>
					</xsl:when>
					<xsl:when test="$updates//*[@about='this:company-1' and @property='gazorg:companyType']/text() = 'Unregistered'">
						<xsl:text>Unregistered Company</xsl:text>
					</xsl:when>
					<xsl:when test="$updates//*[@about='this:company-1' and @property='gazorg:companyType']/text() = 'SocietyClub'">
						<xsl:text>Society/Social Club</xsl:text>
					</xsl:when>
					<xsl:when test="$updates//*[@about='this:company-1' and @property='gazorg:companyType']/text() = 'OverseasCompany'">
						<xsl:text>Overseas Company</xsl:text>
					</xsl:when>
					<xsl:when test="$updates//*[@about='this:company-1' and @property='gazorg:companyType']/text() = 'Partnership'">
						<xsl:text>Partnership</xsl:text>
					</xsl:when>
				</xsl:choose>
			</span>
		</p>
		<p>
			<xsl:text>Nature of the business: </xsl:text>
			<span about="this:company-1" property="gazorg:natureOfBusiness">
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:natureOfBusiness']"/>
			</span>
		</p>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text() != ''">
			<p>
				<xsl:text>Previously: </xsl:text>
				<xsl:for-each select="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']">
					<span about="this:company-1" property="gazorg:previousCompanyName" datatype="xsd:string">
						<xsl:value-of select="text()"/>
						<xsl:if test="position() != last()">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</span>
				</xsl:for-each>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text() != $updates//*[@about='this:company-1' and @property='gazorg:name']/text()">
			<p>
				<xsl:text>Trading as: </xsl:text>
				<span about="this:company-1" property="gazorg:tradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text() != ''">
			<p>
				<xsl:text>Previously trading as: </xsl:text>
				<span about="this:company-1" property="gazorg:previouslyTradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text()"/>
				</span>
			</p>
		</xsl:if>
		<p>
			<xsl:text>Type of Liquidation: </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:typeOfLiquidation" datetype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfLiquidation']/text()"/>
			</span>
		</p>
		<p>
			<xsl:text>Registered office: </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:company-registered-office-1'"/>
			</xsl:call-template>
		</p>
		<xsl:if test="$updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:country']/text() != ''">
			<p>
				<xsl:text>Previous registered office: </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:company-previous-registered-office-1'"/>
				</xsl:call-template>
			</p>
		</xsl:if>
		<p>
			<xsl:text>Principal trading address: </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:company-principal-trading-address-1'"/>
			</xsl:call-template>
		</p>
		<xsl:if test="$updates//*[@about='this:previous-trading-address-1' and @property='vcard:street-address']/text() != ''">
			<p>
				<xsl:text>Previous Trading Address: </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:previous-trading-address-1'"/>
				</xsl:call-template>
			</p>
		</xsl:if>
		<p>
			<xsl:text>Office Holder/s: </xsl:text>
			<span about="this:IP1" typeof="person:InsolvencyPractitioner" property="foaf:name">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']"/>
			</span>
			<xsl:if test="$updates//*[@about='this:IP2' and @property='foaf:name']/text() != ''">
				<xsl:text> and </xsl:text>
				<span about="this:IP2" typeof="person:InsolvencyPractitioner" property="foaf:name">
					<xsl:value-of select="$updates//*[@about='this:IP2' and @property='foaf:name']"/>
				</span>
			</xsl:if>
			<xsl:text>, of </xsl:text>
			<xsl:if test="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''">
				<xsl:value-of select="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text()"/>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''">
				<xsl:text> and </xsl:text>
				<xsl:value-of select="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text()"/>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != '' or $updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text() != ''">
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:IP1-address-1'"/>
			</xsl:call-template>
			<xsl:if test="$updates//*[@about='this:IP2-address-1' and @property='vcard:postal-code']/text() != ''">
				<xsl:text> and </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:IP2-address-1'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
				<xsl:text>, Telephone: </xsl:text>
				<span about="this:IP1" property="gaz:telephone" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''">
				<xsl:text>, Email address: </xsl:text>
				<span about="this:IP1" property="gaz:email" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:email']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
				<xsl:text>, Fax: </xsl:text>
				<span about="this:IP1" property="gaz:fax" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:fax']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''">
				<xsl:text> (</xsl:text>
				<span about="this:IP1" property="person:hasIPReferenceNumber">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
		</p>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPnum']/text() != ''">
			<p>
				<xsl:text>Office Holder Number/s: </xsl:text>
				<span about="this:IP1" property="person:hasIPnum">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPnum']"/>
				</span>
				<xsl:if test="$updates//*[@about='this:IP2' and @property='person:hasIPnum']/text() != ''">
					<xsl:text> and </xsl:text>
					<span about="this:IP2" property="person:hasIPnum">
						<xsl:value-of select="$updates//*[@about='this:IP2' and @property='person:hasIPnum']"/>
					</span>
				</xsl:if>
			</p>
		</xsl:if>
		<p>
			<xsl:text>Date of appointment: </xsl:text>
			<xsl:variable name="dateOfAppointment">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfAppointment']/text()"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfAppointment" datatype="xsd:date" content="{$dateOfAppointment}">
				<xsl:value-of select="format-date(xs:date($dateOfAppointment), '[D01] [MNn] [Y0001]')"/>
			</span>
		</p>
		<p>
			<xsl:text>By whom Appointed: </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:hasAppointer">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasAppointer']/text()"/>
			</span>
		</p>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text() != ''">
			<p>
				<xsl:variable name="noticeDated">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text()"/>
				</xsl:variable>
				<span about="this:IP1" property="person:noticeDated" datatype="xsd:date" content="{$noticeDated}">
					<xsl:value-of select="format-date(xs:date($noticeDated), '[FNn] [D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text() != ''">
			<p>
				<span about="this:IP1" property="person:additionalInformationIP">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text()"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2445">
		<xsl:param name="updates"/>
		<h3 about="this:company-1" property="gazorg:name" typeof="" datatype="xsd:string">
			<xsl:attribute name="typeof"><xsl:value-of select="wlf:getCompanyType($updates//*[@about='this:company-1' and @property='gazorg:companyType']/text())"/></xsl:attribute>
			<xsl:value-of select="upper-case($updates//*[@about='this:company-1' and @property='gazorg:name']/text())"/>
		</h3>
		<xsl:if test="lower-case($updates//*[@about='this:company-1' and @property='gazorg:companyType']/text()) = 'registered'">
			<p>
				<xsl:text>(Company Number </xsl:text>
				<span about="this:company-1" property="gazorg:companyNumber" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:companyNumber']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text() != ''">
			<p>
				<xsl:text>(previously </xsl:text>
				<span about="this:company-1" property="gazorg:previousCompanyName" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text() != ''">
			<p>
				<xsl:text> (t/a </xsl:text>
				<span about="this:company-1" property="gazorg:tradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text() != ''">
			<p>
				<xsl:text>(previously t/a </xsl:text>
				<span about="this:company-1" property="gazorg:previouslyTradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</p>
		</xsl:if>
		<p>
			<xsl:text>Registered Office: </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:company-registered-office-1'"/>
			</xsl:call-template>
		</p>
		<xsl:if test="$updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:company-previous-registered-office-1' and @property='vcard:country']/text() != ''">
			<p>
				<xsl:text>(Previous Registered Office: </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:company-previous-registered-office-1'"/>
				</xsl:call-template>
				<xsl:text>) </xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-principal-trading-address-1' and @property='vcard:street-address']/text() != '' or $updates//*[@about='this:company-principal-trading-address-1' and @property='vcard:extended-address']/text() != '' or $updates//*[@about='this:company-principal-trading-address-1' and @property='vcard:locality']/text() != '' or $updates//*[@about='this:company-principal-trading-address-1' and @property='vcard:region']/text() != '' or $updates//*[@about='this:company-principal-trading-address-1' and @property='vcard:postal-code']/text() != '' or $updates//*[@about='this:company-principal-trading-address-1' and @property='vcard:country']/text() != ''">
			<p>
				<xsl:text>(Principal Trading Address: </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:company-principal-trading-address-1'"/>
				</xsl:call-template>
				<xsl:text>) </xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:previous-trading-address-1' and @property='vcard:street-address']/text() != ''">
			<p>
				<xsl:text>(Previous Trading Address: </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:previous-trading-address-1'"/>
				</xsl:call-template>
				<xsl:text>) </xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:natureOfBusiness']/text() != ''">
			<p>
				<xsl:text>Nature of Business: </xsl:text>
				<span about="this:company-1" property="gazorg:natureOfBusiness" datatype="xsd:string" data-recommended="true">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:natureOfBusiness']/text()"/>
				</span>
			</p>
		</xsl:if>
		<p>
			<xsl:text>Notice is hereby given, pursuant to </xsl:text>
			<span about="this:legislation-1" property="legislation:legislationSection">
				<xsl:value-of select="$updates//*[@about='this:legislation-1' and @property='legislation:legislationSection']/text()"/>
			</span>
			<xsl:text> of the </xsl:text>
			<span about="this:legislation-1" property="legislation:legislationTitle">
				<xsl:value-of select="$updates//*[@about='this:legislation-1' and @property='legislation:legislationTitle']/text()"/>
			</span>
			<xsl:text>that final meetings of members and creditors of the above named Company will be held at </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:meetingAddress-1'"/>
			</xsl:call-template>
			<xsl:variable name="corpInsolvencyMeetingDate">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:meetingTime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyMeetingTime">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:meetingTimeWITHtime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyMeetingTime2">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:meetingTime2WITHtime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyMeetingDateAndTime">
				<xsl:value-of select="concat($corpInsolvencyMeetingDate,'T',$corpInsolvencyMeetingTime,':00')"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyMeeting2DateAndTime">
				<xsl:value-of select="concat($corpInsolvencyMeetingDate,'T',$corpInsolvencyMeetingTime2,':00')"/>
			</xsl:variable>
			<xsl:text> on </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:meetingTime" datatype="xsd:dateTime" content="{$corpInsolvencyMeetingDateAndTime}">
				<xsl:value-of select="format-date(xs:date($corpInsolvencyMeetingDate), '[FNn] [D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text> at </xsl:text>
			<xsl:value-of select="$corpInsolvencyMeetingTime"/>
			<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:meetingIsFor']">
				<xsl:text> for </xsl:text>
				<span about="this:notifiableThing" property="corp-insolvency:meetingIsFor">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:meetingIsFor']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$corpInsolvencyMeetingTime2 != ''">
				<xsl:text> and </xsl:text>
				<span about="this:notifiableThing" property="corp-insolvency:meetingTime2" datatype="xsd:dateTime" content="{$corpInsolvencyMeeting2DateAndTime}">
					<xsl:value-of select="$corpInsolvencyMeetingTime2"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:meeting2IsFor']">
				<xsl:text> for </xsl:text>
				<span about="this:notifiableThing" property="corp-insolvency:meeting2IsFor" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:meeting2IsFor']/text()"/>
				</span>
			</xsl:if>
			<xsl:text> , for the purpose of </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:purposeOfMeeting" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:purposeOfMeeting']/text()"/>
			</span>
		</p>
		<p>
			<xsl:text>A member or creditor entitled to attend and vote is entitled to appoint a proxy to attend and vote instead of him and such proxy need not also be a member or creditor. Proxy forms must be returned to the offices of </xsl:text>
			<span about="this:IP-company-1" property="gazorg:name" datatype="xsd:string">
				<xsl:value-of select="upper-case($updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text())"/>
			</span>
			<xsl:text> at </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:IP1-address-1'"/>
			</xsl:call-template>
			<xsl:text> , no later than 12 noon on the business day before the meeting. </xsl:text>
		</p>
		<xsl:variable name="dateOfAppointment">
			<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfAppointment']/text()"/>
		</xsl:variable>
		<xsl:if test="$dateOfAppointment != ''">
			<p>
				<xsl:text>Date of Appoinment: </xsl:text>
				<span about="this:notifiableThing" property="corp-insolvency:dateOfAppointment" datatype="xsd:date" content="{$dateOfAppointment}">
					<xsl:value-of select="format-date(xs:date($dateOfAppointment), '[D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
		<p>
			<span about="this:IP1" property="foaf:name" datatype="xsd:string" typeof="person:InsolvencyPractitioner">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:text>, </xsl:text>
			<span about="this:IP1" property="person:hasIPCapacity" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPCapacity']/text()"/>
			</span>
			<xsl:text> (IP number </xsl:text>
			<span about="this:IP1" property="person:hasIPnum" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPnum']/text()"/>
			</span>
			<xsl:text>)</xsl:text>
			<xsl:if test="$updates//*[@about='this:IP2' and @property='foaf:name']/text() != ''">
				<xsl:text> and</xsl:text>
				<span about="this:IP2" property="foaf:name" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP2' and @property='foaf:name']/text()"/>
				</span>
				<xsl:if test="$updates//*[@about='this:IP2' and @property='person:hasIPCapacity']/text() != ''">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP2' and @property='person:hasIPCapacity']/text() != ''">
				<span about="this:IP2" property="person:hasIPCapacity" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP2' and @property='person:hasIPCapacity']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP2' and @property='person:hasIPnum']/text() != ''">
				<xsl:text>(IP number </xsl:text>
				<span about="this:IP2" property="person:hasIPnum" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP2' and @property='person:hasIPnum']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:text> of </xsl:text>
			<span about="this:IP-company-1" property="gazorg:name" typeof="gazorg:ForProfitOrganisation" datatype="xsd:string">
				<xsl:value-of select="upper-case($updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text())"/>
			</span>
			<xsl:text> at </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:IP1-address-1'"/>
			</xsl:call-template>
		</p>
		<p>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalContactName']/text() != ''">
				<xsl:text>For Further details contact: </xsl:text>
				<span about="this:IP1" property="person:additionalContactName">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalContactName']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
				<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalContactName']/text() != ''">
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:text> Telephone number: </xsl:text>
				<span about="this:IP1" property="gaz:telephone" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
				<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalContactName']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:text> Fax: </xsl:text>
				<span about="this:IP1" property="gaz:fax" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:fax']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''">
				<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalContactName']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != '' or $updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:text> Email: </xsl:text>
				<span about="this:IP1" property="gaz:email" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:email']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''">
				<xsl:text> (Ref: </xsl:text>
				<span about="this:IP1" property="person:hasIPReferenceNumber" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
		</p>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text() != ''">
			<p>
				<span about="this:IP1" property="person:additionalInformationIP">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:signatory-1' and @property='foaf:name']/text() != ''">
			<p>
				<span about="this:signatory-1" property="foaf:name" typeof="person:Person" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:signatory-1' and @property='foaf:name']/text()"/>
				</span>
				<xsl:if test="$updates//*[@about='this:role-signatory-1' and @property='person:roleName']/text() != ''">
					<xsl:text>, </xsl:text>
					<span about="this:role-signatory-1" property="person:roleName" typeof="person:Role" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:role-signatory-1' and @property='person:roleName']/text()"/>
					</span>
				</xsl:if>
			</p>
		</xsl:if>
		<xsl:variable name="dateAuthorisationSigned">
			<xsl:value-of select="$updates//*[@about='this:authoriser-1' and @property='gaz:dateAuthorisationSigned']/text()"/>
		</xsl:variable>
		<xsl:if test="$updates//*[@about='this:authoriser-1' and @property='gaz:dateAuthorisationSigned']/text() != ''">
			<p>
				<span about="this:authoriser-1" property="gaz:dateAuthorisationSigned" datatype="xsd:date" content="{$dateAuthorisationSigned}">
					<xsl:value-of select="format-date(xs:date($dateAuthorisationSigned), '[D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2446">
		<xsl:param name="updates"/>
		<h3 about="this:company-1" property="gazorg:name" typeof="" datatype="xsd:string">
			<xsl:attribute name="typeof"><xsl:value-of select="wlf:getCompanyType($updates//*[@about='this:company-1' and @property='gazorg:companyType']/text())"/></xsl:attribute>
			<xsl:value-of select="upper-case($updates//*[@about='this:company-1' and @property='gazorg:name']/text())"/>
		</h3>
		<p>
			<xsl:text>Company Number: (</xsl:text>
			<span about="this:company-1" property="gazorg:companyNumber" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:companyNumber']/text()"/>
			</span>
			<xsl:text>)</xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text() != ''">
			<p>
				<xsl:text>Previously: </xsl:text>
				<span about="this:company-1" property="gazorg:previousCompanyName" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text() != ''">
			<p>
				<xsl:text>Trading as: </xsl:text>
				<span about="this:company-1" property="gazorg:tradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text() != ''">
			<p>
				<xsl:text>Previously trading as: </xsl:text>
				<span about="this:company-1" property="gazorg:previouslyTradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-principal-trading-address-1' and @property='vcard:outside-uk-address']/text()='on'">
			<span about="this:company-principal-trading-address-1" property="vcard:outside-uk-address" content="true" data-type="xsd:boolean"/>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-registered-office-1' and @property='vcard:outside-uk-address']/text()='on'">
			<span about="this:company-registered-office-1" property="vcard:outside-uk-address" content="true" data-type="xsd:boolean"/>
		</xsl:if>
		<p>
			<xsl:text>Registered Office: </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:company-registered-office-1'"/>
			</xsl:call-template>
		</p>
		<p>
			<xsl:text>Principal Trading Address: </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:company-principal-trading-address-1'"/>
			</xsl:call-template>
		</p>
		<p>
			<xsl:text>Notice is hereby given, pursuant to </xsl:text>
			<span about="this:legislation-1" typeof="legislation:Act" property="legislation:legislationTitle" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:legislation-1' and @property='legislation:legislationTitle']/text()"/>
			</span>
			<xsl:text> that the creditors of the above named Company, which is being voluntarily wound up, are required on or before </xsl:text>
			<xsl:variable name="corpInsolvencyProvingDate">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebts'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyProvingTime">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebtsWITHtime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyProvingDateAndTime">
				<xsl:value-of select="concat($corpInsolvencyProvingDate, 'T', $corpInsolvencyProvingTime, ':00')"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:onOrBeforeProvingDebts" datatype="xsd:dateTime" content="{$corpInsolvencyProvingDateAndTime}">
				<xsl:value-of select="$corpInsolvencyProvingTime"/> on <xsl:value-of select="format-date(xs:date($corpInsolvencyProvingDate), '[D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text>, to send their full names and addresses along with descriptions and full particulars of their debts or claims and the names and addresses of their solicitors (if any), to </xsl:text>
			<span about="this:IP1" property="foaf:name" datatype="xsd:string" typeof="person:InsolvencyPractitioner">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:text> (</xsl:text>
			<span about="this:IP1" property="person:hasIPnum" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPnum']/text()"/>
			</span>
			<xsl:text>)</xsl:text>
			<xsl:text> at </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:IP1-address-1'"/>
			</xsl:call-template>
			<xsl:text>, and, if so required by notice in writing from said </xsl:text>
			<span about="this:IP1" typeof="person:InsolvencyPractitioner" property="corp-insolvency:practitionerType">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
			</span>
			<xsl:text>, by their solicitors or personally, to come in and prove their debts or claims at such time and place as shall be specified in such notice, or in default thereof they will be excluded from the benefit of any distribution made before such debts/claims are proved. </xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:debtsProved']/text() = 'Yes'">
			<p>
				<xsl:text>The </xsl:text>
				<span about="this:IP1" typeof="person:InsolvencyPractitioner" property="corp-insolvency:practitionerType">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
				</span>
				<xsl:text> will treat any debts of &#163;1,000 or less as proved for the purposes of paying a dividend, unless creditors advise the </xsl:text>
				<span about="this:IP1" typeof="person:InsolvencyPractitioner" property="corp-insolvency:practitionerType">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
				</span>
				<xsl:text> that the amount of the debt is incorrect (in which case, proofs must be submitted) or that no debt is owed, also by </xsl:text>
				<xsl:variable name="corpInsolvencyProvingDate">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebts'][1]/text()"/>
				</xsl:variable>
				<xsl:variable name="corpInsolvencyProvingTime">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebtsWITHtime'][1]/text()"/>
				</xsl:variable>
				<xsl:variable name="corpInsolvencyProvingDateAndTime">
					<xsl:value-of select="concat($corpInsolvencyProvingDate, 'T', $corpInsolvencyProvingTime, ':00')"/>
				</xsl:variable>
				<span about="this:notifiableThing" property="corp-insolvency:onOrBeforeProvingDebts" datatype="xsd:dateTime" content="{$corpInsolvencyProvingDateAndTime}">
					<xsl:value-of select="$corpInsolvencyProvingTime"/> on <xsl:value-of select="format-date(xs:date($corpInsolvencyProvingDate), '[D01] [MNn] [Y0001]')"/>
				</span>
				<xsl:text>.</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text() != ''">
			<p>
				<span about="this:IP1" property="person:additionalInformationIP">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text()"/>
				</span>
			</p>
		</xsl:if>
		<p>
			<xsl:text>Office holder details: </xsl:text>
			<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
			<xsl:text>, (</xsl:text>
			<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPnum']/text()"/>
			<xsl:text>)</xsl:text>
			<xsl:if test="$updates//*[@about='this:IP2' and @property='foaf:name']/text() != ''">
				<xsl:text> and </xsl:text>
				<span about="this:IP2" property="foaf:name">
					<xsl:value-of select="$updates//*[@about='this:IP2' and @property='foaf:name']"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP2' and @property='person:hasIPnum']/text() != ''">
				<xsl:text>, (</xsl:text>
				<span about="this:IP2" property="person:hasIPnum">
					<xsl:value-of select="$updates//*[@about='this:IP2' and @property='person:hasIPnum']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP1" property="gazorg:hasOrganisationMember" resource="this:IP-company-1"/>
				<span about="this:IP-company-1" property="gazorg:name">
					<xsl:value-of select="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text()"/>
				</span>
			</xsl:if>
			<xsl:text>, </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:IP1-address-1'"/>
			</xsl:call-template>
			<xsl:if test="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text() != ''">
				<xsl:text>, or </xsl:text>
				<span about="this:IP2" property="gazorg:hasOrganisationMember" resource="this:IP-company-2"/>
				<span about="this:IP-company-2" property="gazorg:name">
					<xsl:value-of select="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP2-address-1' and @property='vcard:postal-code']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:IP2-address-1'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:text>. Date of appointment: </xsl:text>
			<xsl:variable name="dateOfAppointment">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfAppointment']/text()"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfAppointment" datatype="xsd:date" content="{$dateOfAppointment}">
				<xsl:value-of select="format-date(xs:date($dateOfAppointment), '[D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text>. </xsl:text>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
				<xsl:text>Telephone: </xsl:text>
				<span about="this:IP1" property="gaz:telephone" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''">
				<xsl:text>, Email address: </xsl:text>
				<span about="this:IP1" property="gaz:email" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:email']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
				<xsl:text>, Fax: </xsl:text>
				<span about="this:IP1" property="gaz:fax" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:fax']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''">
				<xsl:text>, (</xsl:text>
				<span about="this:IP1" property="person:hasIPReferenceNumber" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:text>.</xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text() != ''">
			<p>
				<xsl:variable name="noticeDated">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text()"/>
				</xsl:variable>
				<span about="this:IP1" property="person:noticeDated" datatype="xsd:date" content="{$noticeDated}">
					<xsl:value-of select="format-date(xs:date($noticeDated), '[FNn] [D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2447">
		<xsl:param name="updates"/>
		<h3 about="this:company-1" property="gazorg:name" typeof="" datatype="xsd:string">
			<xsl:attribute name="typeof"><xsl:value-of select="wlf:getCompanyType($updates//*[@about='this:company-1' and @property='gazorg:companyType']/text())"/></xsl:attribute>
			<xsl:value-of select="upper-case($updates//*[@about='this:company-1' and @property='gazorg:name']/text())"/>
		</h3>
		<h3>
			<xsl:text>Company Number: (</xsl:text>
			<span about="this:company-1" property="gazorg:companyNumber" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:companyNumber']/text()"/>
			</span>
			<xsl:text>)</xsl:text>
		</h3>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text() != ''">
			<p>
				<xsl:text>Previously: </xsl:text>
				<span about="this:company-1" property="gazorg:previousCompanyName" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previousCompanyName']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text() != ''">
			<p>
				<xsl:text>Trading as: </xsl:text>
				<span about="this:company-1" property="gazorg:tradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:tradingAs']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text() != ''">
			<p>
				<xsl:text>Previously trading as: </xsl:text>
				<span about="this:company-1" property="gazorg:previouslyTradingAs" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:previouslyTradingAs']/text()"/>
				</span>
				<xsl:text>,</xsl:text>
			</p>
		</xsl:if>
		<p>
			<xsl:text>Registered Office: </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:company-registered-office-1'"/>
			</xsl:call-template>
		</p>
		<p>
			<xsl:text>Principal Trading Address: </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:company-principal-trading-address-1'"/>
			</xsl:call-template>
		</p>
		<p>
			<xsl:text>Notice is hereby given, pursuant to </xsl:text>
			<span about="this:legislation-1" typeof="legislation:Act" property="legislation:legislationTitle" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:legislation-1' and @property='legislation:legislationTitle']/text()"/>
			</span>
			<xsl:text> that the convener/s is/are making the following proposal/s to the </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:typeOfAttendees">
				<xsl:value-of select="lower-case($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text())"/>
			</span>
			<xsl:text> of </xsl:text>
			<xsl:value-of select="$updates//*[@about='this:company-1' and @property='gazorg:name']/text()"/>
			<xsl:text>:</xsl:text>
		</p>
		<p>
			<span about="this:notifiableThing" property="corp-insolvency:hasProposal" resource="this:proposal-1"/>
			<span about="this:proposal-1" property="corp-insolvency:hasProposalNumber" content="1" datatype="xsd:integer">1. </span>
			<span about="this:proposal-1" property="rdfs:label" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasProposal-1']"/>
			</span>
		</p>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasProposal-2']/text() != ''">
			<p>
				<span about="this:notifiableThing" property="corp-insolvency:hasProposal" resource="this:proposal-2"/>
				<span about="this:proposal-2" property="corp-insolvency:hasProposalNumber" content="2" datatype="xsd:integer">2. </span>
				<span about="this:proposal-2" property="rdfs:label" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasProposal-2']"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasProposal-3']/text() != ''">
			<p>
				<span about="this:notifiableThing" property="corp-insolvency:hasProposal" resource="this:proposal-3"/>
				<span about="this:proposal-3" property="corp-insolvency:hasProposalNumber" content="3" datatype="xsd:integer">3. </span>
				<span about="this:proposal-3" property="rdfs:label" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasProposal-3']"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasProposal-4']/text() != ''">
			<p>
				<span about="this:notifiableThing" property="corp-insolvency:hasProposal" resource="this:proposal-4"/>
				<span about="this:proposal-4" property="corp-insolvency:hasProposalNumber" content="4" datatype="xsd:integer">4. </span>
				<span about="this:proposal-4" property="rdfs:label" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasProposal-4']"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasProposal-5']/text() != ''">
			<p>
				<span about="this:notifiableThing" property="corp-insolvency:hasProposal" resource="this:proposal-5"/>
				<span about="this:proposal-5" property="corp-insolvency:hasProposalNumber" content="5" datatype="xsd:integer">5. </span>
				<span about="this:proposal-5" property="rdfs:label" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasProposal-5']"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasProposal-6']/text() != ''">
			<p>
				<span about="this:notifiableThing" property="corp-insolvency:hasProposal" resource="this:proposal-6"/>
				<span about="this:proposal-6" property="corp-insolvency:hasProposalNumber" content="6" datatype="xsd:integer">6. </span>
				<span about="this:proposal-6" property="rdfs:label" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasProposal-6']"/>
				</span>
			</p>
		</xsl:if>
		<p>
			<xsl:text>If any </xsl:text>
			<xsl:value-of select="lower-case($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text())"/>
			<xsl:text> object to these proposals, then they must send the convenor/s a notice of objection by 23:59 on </xsl:text>
			<xsl:variable name="decisionDate">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfDecision']/text()"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfDecision" datatype="xsd:date" content="{$decisionDate}">
				<xsl:value-of select="format-date(xs:date($decisionDate), '[D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text>, otherwise the </xsl:text>
			<xsl:value-of select="lower-case($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text())"/>
			<xsl:text> shall be deemed as having consented to the proposed decision and it will be approved. </xsl:text>
		</p>
		<p>
			<xsl:text>In order to object to the proposed decision, </xsl:text>
			<xsl:value-of select="lower-case($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text())"/>
			<xsl:text> must deliver their notices of objection to the convener either by post to </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:address-for-lodging-proofs-1'"/>
			</xsl:call-template>
			<xsl:text>, or by email to </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:emailForLodgingProofs">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:emailForLodgingProofs']/text()"/>
			</span>
			<xsl:text> no later than </xsl:text>
			<xsl:variable name="corpInsolvencyProvingDate">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebts'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyProvingTime">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebtsWITHtime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyProvingDateAndTime">
				<xsl:value-of select="concat($corpInsolvencyProvingDate, 'T', $corpInsolvencyProvingTime, ':00')"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:onOrBeforeProvingDebts" datatype="xsd:dateTime" content="{$corpInsolvencyProvingDateAndTime}">
				<xsl:value-of select="$corpInsolvencyProvingTime"/> on <xsl:value-of select="format-date(xs:date($corpInsolvencyProvingDate), '[D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text> together with any proofs in respect of the </xsl:text>
			<xsl:value-of select="lower-case($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text())"/>
			<xsl:text> claim in accordance with these Rules, failing which the objection will be disregarded. </xsl:text>
			<xsl:value-of select="concat(upper-case(substring($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text(),1,1)),
                    substring(lower-case($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text()), 2),
                    ' '[not(last())])"/>
			<xsl:text> who are owed small debts (&#163;1,000 or less) are still required to submit their claim in order for their objection to be valid. </xsl:text>
			<xsl:value-of select="concat(upper-case(substring($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text(),1,1)),
                    substring(lower-case($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text()), 2),
                    ' '[not(last())])"/>
			<xsl:text> have the right to appeal the decision made by applying to Court under Rule 15.35 within 21 days of </xsl:text>
			<xsl:variable name="decisionDate">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfDecision']/text()"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:onOrBeforeProvingDebts" datatype="xsd:date" content="{$decisionDate}">
				<xsl:value-of select="format-date(xs:date($decisionDate), '[D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text>. Any creditor who has opted out from receiving notices may nevertheless vote if the creditor provides a valid proof of debt by </xsl:text>
			<xsl:variable name="corpInsolvencyProvingDate">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebts'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyProvingTime">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebtsWITHtime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyProvingDateAndTime">
				<xsl:value-of select="concat($corpInsolvencyProvingDate, 'T', $corpInsolvencyProvingTime, ':00')"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:onOrBeforeProvingDebts" datatype="xsd:dateTime" content="{$corpInsolvencyProvingDateAndTime}">
				<xsl:value-of select="$corpInsolvencyProvingTime"/> on <xsl:value-of select="format-date(xs:date($corpInsolvencyProvingDate), '[D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text>.</xsl:text>
		</p>
		<p>
			<xsl:text>The convenor is responsible for aggregating any objections to see if the threshold is met for the decision to be taken as not having been made. If the threshold (being 10% in value, 10% in number or a total of 10 creditors or contributories who would be entitled to vote at a qualifying decision procedure) is met, then the deemed consent procedure will terminate without a decision being made, and if a decision is sought again on the same matter it will be sought by a physical meeting of </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:typeOfAttendees">
				<xsl:value-of select="lower-case($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text())"/>
			</span>
			<xsl:text>.</xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasCommittee']/text() = 'No'">
			<p>
				<xsl:text>The </xsl:text>
				<span about="this:notifiableThing" property="corp-insolvency:typeOfAttendees">
					<xsl:value-of select="lower-case($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text())"/>
				</span>
				<xsl:text> are also invited to determine whether a committee should be established. The committee may be formed if sufficient </xsl:text>
				<span about="this:notifiableThing" property="corp-insolvency:typeOfAttendees">
					<xsl:value-of select="lower-case($updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text())"/>
				</span>
				<xsl:text> (being a minimum of 3 and a maximum of 5) are willing to be members. Nominations for membership of the committee can only be accepted from creditors who have lodged a proof of debt, and whose votes have not been disallowed for voting purposes. The nominations must be received by the </xsl:text>
				<xsl:variable name="decisionDate">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfDecision']/text()"/>
				</xsl:variable>
				<span about="this:notifiableThing" property="corp-insolvency:onOrBeforeProvingDebts" datatype="xsd:date" content="{$decisionDate}">
					<xsl:value-of select="format-date(xs:date($decisionDate), '[D01] [MNn] [Y0001]')"/>
				</span>
				<xsl:text>.</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text() != ''">
			<p>
				<span about="this:IP1" property="person:additionalInformationIP">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text()"/>
				</span>
			</p>
		</xsl:if>
		<p>
			<xsl:text>For further details, please contact: </xsl:text>
			<span about="this:IP1" property="foaf:name">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPnum']/text() != ''">
				<xsl:text> (</xsl:text>
				<span about="this:IP1" property="person:hasIPnum">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPnum']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP1" property="gazorg:hasOrganisationMember" resource="this:IP-company-1"/>
				<span about="this:IP-company-1" property="gazorg:name">
					<xsl:value-of select="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text()"/>
				</span>
			</xsl:if>
			<xsl:text>, </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:IP1-address-1'"/>
			</xsl:call-template>
			<xsl:if test="$updates//*[@about='this:IP2' and @property='foaf:name']/text() != ''">
				<xsl:text> and </xsl:text>
				<span about="this:IP2" property="foaf:name">
					<xsl:value-of select="$updates//*[@about='this:IP2' and @property='foaf:name']"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP2' and @property='person:hasIPnum']/text() != ''">
				<xsl:text> (</xsl:text>
				<span about="this:IP2" property="person:hasIPnum">
					<xsl:value-of select="$updates//*[@about='this:IP2' and @property='person:hasIPnum']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP2" property="gazorg:hasOrganisationMember" resource="this:IP-company-2"/>
				<span about="this:IP-company-2" property="gazorg:name">
					<xsl:value-of select="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP2-address-1' and @property='vcard:postal-code']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP2" property="person:hasAddress" resource="this:IP2-address-1"/>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:IP2-address-1'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP1" property="gaz:telephone" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP1" property="gaz:email" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:email']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP1" property="gaz:fax" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:fax']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''">
				<xsl:text>, (</xsl:text>
				<span about="this:IP1" property="person:hasIPReferenceNumber" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:text>.</xsl:text>
		</p>
		<p>
			<span about="this:signatory-1" property="foaf:name" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:signatory-1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:text>, </xsl:text>
			<span about="this:role-signatory-1" property="person:roleName rdfs:label" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:role-signatory-1' and @property='person:roleName']/text()"/>
			</span>
		</p>
		<xsl:if test="$updates//*[@about='this:signatory-2' and @property='foaf:name']/text() != ''">
			<p>
				<span about="this:authoriser-1" property="gaz:hasAuthorisingPerson" resource="this:signatory-2" data-hide="true"/>
				<span about="this:signatory-2" property="person:hasRole" resource="this:role-signatory-2"/>
				<span about="this:signatory-2" property="foaf:name" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:signatory-2' and @property='foaf:name']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
				<span about="this:role-signatory-2" property="person:roleName rdfs:label" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:role-signatory-1' and @property='person:roleName']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text() != ''">
			<p>
				<xsl:variable name="noticeDated">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text()"/>
				</xsl:variable>
				<span about="this:IP1" property="person:noticeDated" datatype="xsd:date" content="{$noticeDated}">
					<xsl:value-of select="format-date(xs:date($noticeDated), '[FNn] [D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2509">
		<xsl:param name="updates"/>
		<xsl:variable name="edition">
			<xsl:value-of select="$updates//*[@property='gaz:hasEdition']/text()"/>
		</xsl:variable>
		<p>
			<xsl:text>In the </xsl:text>
			<span about="this:court-1" property="court:courtName" datatype="xsd:string">
				<xsl:if test="$updates//*[@property='court:courtName' and contains(.,'High Court')]">
					<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:courtName']/text()"/>
				</xsl:if>
				<xsl:if test="$updates//*[@property='court:courtName' and not(contains(.,'High Court'))]">
					<xsl:text>County Court at </xsl:text>
					<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:countyCourtName']/text()"/>
				</xsl:if>
			</span>
		</p>
		<p>
			<xsl:variable name="courtCode">
				<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:caseCode']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtNumber">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtYear">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
			</xsl:variable>
			<xsl:if test="starts-with($courtCode,'No')">
				<span>
					<xsl:text> No. </xsl:text>
					<span about="this:court-case-1" property="court:caseNumber" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
					</span>
					<xsl:text> of </xsl:text>
					<span about="this:court-case-1" property="court:caseYear" datatype="xsd:gYear">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
					</span>
				</span>
			</xsl:if>
			<xsl:if test="starts-with($courtCode,'CR') or starts-with($courtCode,'BR')">
				<span>
					<span about="this:court-case-1" property="court:caseCode" datatype="xsd:string">
						<xsl:value-of select="replace(replace($courtCode,'YYYY',$courtYear),'####',$courtNumber)"/>
					</span>
				</span>
			</xsl:if>
		</p>
		<h3 data-gazettes="Person" property="gaz:hasPerson" resource="this:person-1">
			<span about="this:person-1" property="foaf:firstName">
				<xsl:value-of select="$updates//*[@about='this:person-1' and @property='foaf:firstName']/text()"/>
			</span>
			<xsl:if test="normalize-space($updates//*[@about='this:person-1' and @property='foaf:givenName']/text()) != ''">
				<xsl:text> </xsl:text>
				<span about="this:person-1" property="foaf:givenName">
					<xsl:value-of select="$updates//*[@about='this:person-1' and @property='foaf:givenName']/text()"/>
				</span>
			</xsl:if>
			<xsl:text> </xsl:text>
			<span about="this:person-1" property="foaf:familyName">
				<xsl:value-of select="$updates//*[@about='this:person-1' and @property='foaf:familyName']/text()"/>
			</span>
			<xsl:if test="$updates//*[@about='this:person-1' and @property='person:isDeceased']/text() = 'Yes'">
				<span about="this:person-1" property="person:isDeceased" content="true" data-type="xsd:boolean">
					<xsl:text> (Deceased)</xsl:text>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:person-1' and @property='person:isDeceased']/text() = 'No'">
				<span about="this:person-1" property="person:isDeceased" content="false" data-type="xsd:boolean"/>
			</xsl:if>
		</h3>
		<xsl:if test="$updates//*[@about='this:person-1' and @property='person:alsoKnownAs']/text() != ''">
			<xsl:for-each select="$updates//*[@about='this:person-1' and @property='person:alsoKnownAs']">
				<p>
					<xsl:text>also known as: </xsl:text>
					<span about="this:person-1" property="person:alsoKnownAs" datatype="xsd:string">
						<xsl:value-of select="text()"/>
					</span>
				</p>
			</xsl:for-each>
		</xsl:if>
		<p>
			<xsl:variable name="bankruptcyStatus">
				<xsl:choose>
					<xsl:when test="$updates//*[@about='this:person-1' and @property='person:hasStatus']/text() = 'In bankruptcy'">
						<xsl:text>In Bankruptcy</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Formerly in bankruptcy</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<span about="this:person-1" property="person:hasStatus">
				<xsl:value-of select="$bankruptcyStatus"/>
			</span>
		</p>
		<xsl:variable name="dateOfBankruptcyOrder">
			<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfBankruptcyOrder']/text()"/>
		</xsl:variable>
		<xsl:variable name="dateOfBankruptcyOrderWITHTime">
			<xsl:value-of select="concat($dateOfBankruptcyOrder,'T00:01:00')"/>
		</xsl:variable>
		<p>
			<xsl:text>Date of bankruptcy order: </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfBankruptcyOrder" datatype="xsd:dateTime" content="{$dateOfBankruptcyOrderWITHTime}">
				<xsl:value-of select="format-date(xs:date($dateOfBankruptcyOrder), '[D01] [MNn] [Y0001]')"/>
			</span>
		</p>
		<p>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:person-1-address-1'"/>
			</xsl:call-template>
		</p>
		<xsl:if test="$updates//*[@about='this:person-1-previous-address-1' and @property='vcard:street-address']/text() != '' 
            or $updates//*[@about='this:person-1-previous-address-1' and @property='vcard:extended-address']/text() != '' 
            or $updates//*[@about='this:person-1-previous-address-1' and @property='vcard:locality']/text() != '' 
            or $updates//*[@about='this:person-1-previous-address-1' and @property='vcard:region']/text() != '' 
            or $updates//*[@about='this:person-1-previous-address-1' and @property='vcard:postal-code']/text() != '' 
            or $updates//*[@about='this:person-1-previous-address-1' and @property='vcard:country']/text() != ''">
			<p>
				<xsl:text>Formerly of: </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:person-1-previous-address-1'"/>
				</xsl:call-template>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:person-1' and @property='person:isTradingAs']/text() != ''">
			<p>
				<xsl:text>who at the date of the bankruptcy order was trading as: </xsl:text>
				<span about="this:person-1" property="person:isTradingAs">
					<xsl:value-of select="$updates//*[@about='this:person-1' and @property='person:isTradingAs']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:person-1' and @property='person:isDischarged']/text() = 'Yes'">
			<p>
				<span about="this:person-1" property="person:isDischarged" content="true" data-type="xsd:boolean"/>
				<xsl:text>NOTE: the above-named was discharged from the proceedings and may no longer have a connection with the addresses listed.</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:person-1' and @property='person:isDischarged']/text() = 'No'">
			<span about="this:person-1" property="person:isDischarged" content="false" data-type="xsd:boolean"/>
		</xsl:if>
		<p>
			<xsl:variable name="dateOfBirth">
				<xsl:value-of select="$updates//*[@about='this:person-1' and @property='person:dateOfBirth']/text()"/>
			</xsl:variable>
			<span about="this:person-1" property="person:dateOfBirth" datatype="xsd:date" content="{$dateOfBirth}">
				<xsl:value-of select="format-date(xs:date($dateOfBirth), '[D01] [MNn] [Y0001]')"/>
			</span>
		</p>
		<p>
			<span about="this:person-1-occupation-1" property="person:jobTitle">
				<xsl:value-of select="$updates//*[@about='this:person-1-occupation-1' and @property='person:jobTitle']/text()"/>
			</span>
		</p>
		<p>
			<xsl:text>Notice is hereby given, pursuant to </xsl:text>
			<xsl:if test="lower-case($edition) != 'belfast' and $updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfBankruptcyOrder']/text() &lt; '20170604'">
				<span about="this:legislation-1" typeof="legislation:Act" property="legislation:legislationTitle" datatype="xsd:string">
					<xsl:text>Rule 11.2 of the Insolvency Rules 1986</xsl:text>
				</span>
			</xsl:if>
			<xsl:if test="lower-case($edition) != 'belfast' and $updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfBankruptcyOrder']/text() &gt;= '20170604'">
				<span about="this:legislation-1" typeof="legislation:Act" property="legislation:legislationTitle" datatype="xsd:string">
					<xsl:text>Rule 14.28 of the Insolvency (England and Wales) Rules 2016</xsl:text>
				</span>
			</xsl:if>
			<xsl:if test="lower-case($edition) = 'belfast'">
				<span about="this:legislation-1" typeof="legislation:Act" property="legislation:legislationTitle" datatype="xsd:string">
					<xsl:text>Rule 11.02 of the Insolvency Rules (Northern Ireland) 1991 (as amended)</xsl:text>
				</span>
			</xsl:if>
			<xsl:text> that the </xsl:text>
			<span about="this:IP1" property="corp-insolvency:practitionerType">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
			</span>
			<xsl:text>, having been appointed on </xsl:text>
			<xsl:variable name="dateOfAppointment">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfAppointment']/text()"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfAppointment" datatype="xsd:date" content="{$dateOfAppointment}">
				<xsl:value-of select="format-date(xs:date($dateOfAppointment), '[D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text> intend(s) to declare a(n) </xsl:text>
			<span about="this:dividend-1" property="corp-insolvency:hasDividendType">
				<xsl:value-of select="$updates//*[@about='this:dividend-1' and @property='corp-insolvency:hasDividendType']/text()"/>
			</span>
			<xsl:if test="$updates//*[@about='this:price-1' and @property='rdf:value']/text() != ''">
				<xsl:text> of &#163;</xsl:text>
				<xsl:value-of select="$updates//*[@about='this:price-1' and @property='rdf:value']/text()"/>
			</xsl:if>
			<xsl:text> to all </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:typeOfAttendees">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text()"/>
			</span>
			<xsl:text> of the Bankrupt's estate within </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:hasProvingPeriod">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasProvingPeriod']/text()"/>
			</span>
			<xsl:text> of the last date for proving specified below.</xsl:text>
		</p>
		<p>
			<xsl:text>Creditors who have not yet done so must prove their debts or claims and the names and addresses, particulars of their debts by sending their full names and addresses of their solicitors (if any), to the </xsl:text>
			<span about="this:IP1" property="corp-insolvency:practitionerType">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
			</span>
			<xsl:text> using the details specified below.</xsl:text>
		</p>
		<p>
			<xsl:text>The </xsl:text>
			<span about="this:IP1" property="corp-insolvency:practitionerType">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
			</span>
			<xsl:text> is/are not obliged to deal with proofs lodged after the last date for proving. Creditors who have not proved their debts by </xsl:text>
			<xsl:variable name="corpInsolvencyProvingDate">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebts'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyProvingTime">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebtsWITHtime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyProvingDateAndTime">
				<xsl:value-of select="concat($corpInsolvencyProvingDate, 'T', $corpInsolvencyProvingTime, ':00')"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:onOrBeforeProvingDebts" datatype="xsd:dateTime" content="{$corpInsolvencyProvingDateAndTime}">
				<xsl:value-of select="$corpInsolvencyProvingTime"/> on <xsl:value-of select="format-date(xs:date($corpInsolvencyProvingDate), '[D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text> may be excluded from the benefit of the dividend or any other dividend declared before their debt is proved.</xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text() != ''">
			<p>
				<span about="this:IP1" property="person:additionalInformationIP" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text()"/>
				</span>
			</p>
		</xsl:if>
		<p>
			<xsl:text>Office holder details: </xsl:text>
			<span about="this:IP1" property="foaf:name">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:if test="$updates//*[@about='this:IP2' and @property='foaf:name']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP2" property="foaf:name">
					<xsl:value-of select="$updates//*[@about='this:IP2' and @property='foaf:name']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text()"/>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text()"/>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @ property='person:hasIPnum']/text() != ''">
				<xsl:text>, (</xsl:text>
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPnum']/text()"/>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP2' and @ property='person:hasIPnum']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$updates//*[@about='this:IP2' and @property='person:hasIPnum']/text()"/>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:text>, </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:IP1-address-1'"/>
			</xsl:call-template>
			<xsl:if test="$updates//*[@about='this:IP2-address-1' and @property='vcard:postal-code']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:IP2-address-1'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP1" property="gaz:telephone" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP1" property="gaz:email" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:email']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP1" property="gaz:fax" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:fax']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''">
				<xsl:text>, (</xsl:text>
				<span about="this:IP1" property="person:hasIPReferenceNumber" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:text>.</xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text() != ''">
			<p>
				<xsl:variable name="noticeDated">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text()"/>
				</xsl:variable>
				<span about="this:IP1" property="person:noticeDated" datatype="xsd:date" content="{$noticeDated}">
					<xsl:value-of select="format-date(xs:date($noticeDated), '[FNn] [D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2510">
		<xsl:param name="updates"/>
		<xsl:variable name="edition">
			<xsl:value-of select="$updates//*[@property='gaz:hasEdition']/text()"/>
		</xsl:variable>
		<p>
			<xsl:text>In the </xsl:text>
			<span about="this:court-1" property="court:courtName" datatype="xsd:string">
				<xsl:if test="$updates//*[@property='court:courtName' and contains(.,'High Court')]">
					<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:courtName']/text()"/>
				</xsl:if>
				<xsl:if test="$updates//*[@property='court:courtName' and not(contains(.,'High Court'))]">
					<xsl:text>County Court at </xsl:text>
					<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:countyCourtName']/text()"/>
				</xsl:if>
			</span>
		</p>
		<p>
			<xsl:variable name="courtCode">
				<xsl:value-of select="$updates//*[@about='this:court-1' and @property='court:caseCode']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtNumber">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
			</xsl:variable>
			<xsl:variable name="courtYear">
				<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
			</xsl:variable>
			<xsl:if test="starts-with($courtCode,'No')">
				<span>
					<xsl:text> No. </xsl:text>
					<span about="this:court-case-1" property="court:caseNumber" datatype="xsd:string">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseNumber']/text()"/>
					</span>
					<xsl:text> of </xsl:text>
					<span about="this:court-case-1" property="court:caseYear" datatype="xsd:gYear">
						<xsl:value-of select="$updates//*[@about='this:court-case-1' and @property='court:caseYear']/text()"/>
					</span>
				</span>
			</xsl:if>
			<xsl:if test="starts-with($courtCode,'CR') or starts-with($courtCode,'BR')">
				<span>
					<span about="this:court-case-1" property="court:caseCode" datatype="xsd:string">
						<xsl:value-of select="replace(replace($courtCode,'YYYY',$courtYear),'####',$courtNumber)"/>
					</span>
				</span>
			</xsl:if>
		</p>
		<h3 data-gazettes="Person" property="gaz:hasPerson" resource="this:person-1">
			<span about="this:person-1" property="foaf:firstName">
				<xsl:value-of select="$updates//*[@about='this:person-1' and @property='foaf:firstName']/text()"/>
			</span>
			<xsl:if test="normalize-space($updates//*[@about='this:person-1' and @property='foaf:givenName']/text()) != ''">
				<xsl:text> </xsl:text>
				<span about="this:person-1" property="foaf:givenName">
					<xsl:value-of select="$updates//*[@about='this:person-1' and @property='foaf:givenName']/text()"/>
				</span>
			</xsl:if>
			<xsl:text> </xsl:text>
			<span about="this:person-1" property="foaf:familyName">
				<xsl:value-of select="$updates//*[@about='this:person-1' and @property='foaf:familyName']/text()"/>
			</span>
			<xsl:if test="$updates//*[@about='this:person-1' and @property='person:isDeceased']/text() = 'Yes'">
				<span about="this:person-1" property="person:isDeceased" content="true" data-type="xsd:boolean">
					<xsl:text> (Deceased)</xsl:text>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:person-1' and @property='person:isDeceased']/text() = 'No'">
				<span about="this:person-1" property="person:isDeceased" content="false" data-type="xsd:boolean"/>
			</xsl:if>
		</h3>
		<xsl:if test="$updates//*[@about='this:person-1' and @property='person:alsoKnownAs']/text() != ''">
			<xsl:for-each select="$updates//*[@about='this:person-1' and @property='person:alsoKnownAs']">
				<p>
					<xsl:text>also known as: </xsl:text>
					<span about="this:person-1" property="person:alsoKnownAs" datatype="xsd:string">
						<xsl:value-of select="text()"/>
					</span>
				</p>
			</xsl:for-each>
		</xsl:if>
		<p>
			<xsl:variable name="bankruptcyStatus">
				<xsl:choose>
					<xsl:when test="$updates//*[@about='this:person-1' and @property='person:hasStatus']/text() = 'In bankruptcy'">
						<xsl:text>In Bankruptcy</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Formerly in bankruptcy</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<span about="this:person-1" property="person:hasStatus">
				<xsl:value-of select="$bankruptcyStatus"/>
			</span>
		</p>
		<xsl:variable name="dateOfBankruptcyOrder">
			<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfBankruptcyOrder']/text()"/>
		</xsl:variable>
		<xsl:variable name="dateOfBankruptcyOrderWITHTime">
			<xsl:value-of select="concat($dateOfBankruptcyOrder,'T00:01:00')"/>
		</xsl:variable>
		<p>
			<xsl:text>Date of bankruptcy order: </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfBankruptcyOrder" datatype="xsd:dateTime" content="{$dateOfBankruptcyOrderWITHTime}">
				<xsl:value-of select="format-date(xs:date($dateOfBankruptcyOrder), '[D01] [MNn] [Y0001]')"/>
			</span>
		</p>
		<p>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:person-1-address-1'"/>
			</xsl:call-template>
		</p>
		<xsl:if test="$updates//*[@about='this:person-1-previous-address-1' and @property='vcard:street-address']/text() != '' 
            or $updates//*[@about='this:person-1-previous-address-1' and @property='vcard:extended-address']/text() != '' 
            or $updates//*[@about='this:person-1-previous-address-1' and @property='vcard:locality']/text() != '' 
            or $updates//*[@about='this:person-1-previous-address-1' and @property='vcard:region']/text() != '' 
            or $updates//*[@about='this:person-1-previous-address-1' and @property='vcard:postal-code']/text() != '' 
            or $updates//*[@about='this:person-1-previous-address-1' and @property='vcard:country']/text() != ''">
			<p>
				<xsl:text>Formerly of: </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:person-1-previous-address-1'"/>
				</xsl:call-template>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:person-1' and @property='person:isTradingAs']/text() != ''">
			<p>
				<xsl:text>who at the date of the bankruptcy order was trading as: </xsl:text>
				<span about="this:person-1" property="person:isTradingAs">
					<xsl:value-of select="$updates//*[@about='this:person-1' and @property='person:isTradingAs']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:person-1' and @property='person:isDischarged']/text() = 'Yes'">
			<p>
				<xsl:text>NOTE: the above-named was discharged from the proceedings and may no longer have a connection with the addresses listed.</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:person-1' and @property='person:isDischarged']/text() = 'No'">
			<span about="this:person-1" property="person:isDischarged" content="false" data-type="xsd:boolean"/>
		</xsl:if>
		<p>
			<xsl:variable name="dateOfBirth">
				<xsl:value-of select="$updates//*[@about='this:person-1' and @property='person:dateOfBirth']/text()"/>
			</xsl:variable>
			<span about="this:person-1" property="person:dateOfBirth" datatype="xsd:date" content="{$dateOfBirth}">
				<xsl:value-of select="format-date(xs:date($dateOfBirth), '[D01] [MNn] [Y0001]')"/>
			</span>
		</p>
		<p>
			<span about="this:person-1-occupation-1" property="person:jobTitle">
				<xsl:value-of select="$updates//*[@about='this:person-1-occupation-1' and @property='person:jobTitle']/text()"/>
			</span>
		</p>
		<p>
			<xsl:text>Notice is hereby given, pursuant to </xsl:text>
			<xsl:if test="lower-case($edition) != 'belfast' and $updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfBankruptcyOrder']/text() &lt; '20170604'">
				<span about="this:legislation-1" typeof="legislation:Act" property="legislation:legislationTitle" datatype="xsd:string">
					<xsl:text>Rule 11.6 of the Insolvency Rules 1986</xsl:text>
				</span>
			</xsl:if>
			<xsl:if test="lower-case($edition) != 'belfast' and $updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfBankruptcyOrder']/text() &gt;= '20170604'">
				<span about="this:legislation-1" typeof="legislation:Act" property="legislation:legislationTitle" datatype="xsd:string">
					<xsl:text>Rule 14.35 of the Insolvency (England and Wales) Rules 2016</xsl:text>
				</span>
			</xsl:if>
			<xsl:if test="lower-case($edition) = 'belfast'">
				<span about="this:legislation-1" typeof="legislation:Act" property="legislation:legislationTitle" datatype="xsd:string">
					<xsl:text>Rule 11.06 of the Insolvency Rules (Northern Ireland) 1991 (as amended)</xsl:text>
				</span>
			</xsl:if>
			<xsl:text> that the </xsl:text>
			<span about="this:IP1" property="corp-insolvency:practitionerType">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
			</span>
			<xsl:text>, having been appointed on </xsl:text>
			<xsl:variable name="dateOfAppointment">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateOfAppointment']/text()"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateOfAppointment" datatype="xsd:date" content="{$dateOfAppointment}">
				<xsl:value-of select="format-date(xs:date($dateOfAppointment), '[D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text> intend(s) to declare a(n) </xsl:text>
			<span about="this:dividend-1" property="corp-insolvency:hasDividendType">
				<xsl:value-of select="$updates//*[@about='this:dividend-1' and @property='corp-insolvency:hasDividendType']/text()"/>
			</span>
			<xsl:if test="$updates//*[@about='this:price-1' and @property='rdf:value']/text() != ''">
				<xsl:text> of &#163;</xsl:text>
				<xsl:value-of select="$updates//*[@about='this:price-1' and @property='rdf:value']/text()"/>
			</xsl:if>
			<xsl:text> to all </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:typeOfAttendees">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:typeOfAttendees']/text()"/>
			</span>
			<xsl:text> of the Bankrupt's estate </xsl:text>
			<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:debtsProved']/text() = 'Yes'">
				<xsl:text> who have proven their debts</xsl:text>
			</xsl:if>
			<xsl:text> within </xsl:text>
			<span about="this:notifiableThing" property="corp-insolvency:hasProvingPeriod">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:hasProvingPeriod']/text()"/>
			</span>
			<xsl:text> of the last date for proving specified below.</xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:debtsProved']/text() = 'Yes'">
			<xsl:variable name="corpInsolvencyProvingDate">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebts'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyProvingTime">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebtsWITHtime'][1]/text()"/>
			</xsl:variable>
			<xsl:variable name="corpInsolvencyProvingDateAndTime">
				<xsl:value-of select="concat($corpInsolvencyProvingDate, 'T', $corpInsolvencyProvingTime, ':00')"/>
			</xsl:variable>
			<p>
				<xsl:text>Last day of proving: </xsl:text>
				<span about="this:notifiableThing" property="corp-insolvency:onOrBeforeProvingDebts" datatype="xsd:dateTime" content="{$corpInsolvencyProvingDateAndTime}">
					<xsl:value-of select="$corpInsolvencyProvingTime"/> on <xsl:value-of select="format-date(xs:date($corpInsolvencyProvingDate), '[D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:debtsProved']/text() = 'No'">
			<p>
				<xsl:text>Creditors who have not yet done so must prove their debts or claims and the names and addresses, particulars of their debts by sending their full
                    names and addresses of their solicitors (if any), to the </xsl:text>
				<span about="this:IP1" property="corp-insolvency:practitionerType">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
				</span>
				<xsl:text> using the details specified below.</xsl:text>
			</p>
			<p>
				<xsl:text>The </xsl:text>
				<span about="this:IP1" property="corp-insolvency:practitionerType">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='corp-insolvency:practitionerType']/text()"/>
				</span>
				<xsl:text> is/are not obliged to deal with proofs lodged after the last date for proving. Creditors who have not proved their debts by </xsl:text>
				<xsl:variable name="corpInsolvencyProvingDate">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebts'][1]/text()"/>
				</xsl:variable>
				<xsl:variable name="corpInsolvencyProvingTime">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:onOrBeforeProvingDebtsWITHtime'][1]/text()"/>
				</xsl:variable>
				<xsl:variable name="corpInsolvencyProvingDateAndTime">
					<xsl:value-of select="concat($corpInsolvencyProvingDate, 'T', $corpInsolvencyProvingTime, ':00')"/>
				</xsl:variable>
				<xsl:text> on </xsl:text>
				<span about="this:notifiableThing" property="corp-insolvency:onOrBeforeProvingDebts" datatype="xsd:dateTime" content="{$corpInsolvencyProvingDateAndTime}">
					<xsl:value-of select="$corpInsolvencyProvingTime"/> on <xsl:value-of select="format-date(xs:date($corpInsolvencyProvingDate), '[D01] [MNn] [Y0001]')"/>
				</span>
				<xsl:text> may be excluded from the benefit of the dividend or any other dividend declared before their debt is proved.</xsl:text>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text() != ''">
			<p>
				<span about="this:IP1" property="person:additionalInformationIP" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:additionalInformationIP']/text()"/>
				</span>
			</p>
		</xsl:if>
		<p>
			<xsl:text>Office holder details: </xsl:text>
			<span about="this:IP1" property="foaf:name">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:if test="$updates//*[@about='this:IP2' and @property='foaf:name']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP2" property="foaf:name">
					<xsl:value-of select="$updates//*[@about='this:IP2' and @property='foaf:name']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text()"/>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$updates//*[@about='this:IP-company-2' and @property='gazorg:name']/text()"/>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @ property='person:hasIPnum']/text() != ''">
				<xsl:text>, (</xsl:text>
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPnum']/text()"/>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP2' and @ property='person:hasIPnum']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$updates//*[@about='this:IP2' and @property='person:hasIPnum']/text()"/>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:text>, </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:IP1-address-1'"/>
			</xsl:call-template>
			<xsl:if test="$updates//*[@about='this:IP2-address-1' and @property='vcard:postal-code']/text() != ''">
				<xsl:text>, </xsl:text>
				<xsl:call-template name="address">
					<xsl:with-param name="updates" select="$updates"/>
					<xsl:with-param name="about" select="'this:IP2-address-1'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP1" property="gaz:telephone" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP1" property="gaz:email" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:email']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
				<xsl:text>, </xsl:text>
				<span about="this:IP1" property="gaz:fax" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:fax']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''">
				<xsl:text>, (</xsl:text>
				<span about="this:IP1" property="person:hasIPReferenceNumber" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:text>.</xsl:text>
		</p>
		<xsl:if test="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text() != ''">
			<p>
				<xsl:variable name="noticeDated">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:noticeDated']/text()"/>
				</xsl:variable>
				<span about="this:IP1" property="person:noticeDated" datatype="xsd:date" content="{$noticeDated}">
					<xsl:value-of select="format-date(xs:date($noticeDated), '[FNn] [D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="boilerPlateText2518">
		<xsl:param name="updates"/>
		<p>
			<xsl:text>A Trust Deed has been granted by </xsl:text>
			<span about="this:person1" property="foaf:firstName">
				<xsl:value-of select="$updates//*[@about='this:person1' and @property='foaf:firstName']/text()"/>
			</span>
			<xsl:text> </xsl:text>
			<xsl:if test="$updates//*[@about='this:person1' and @property='foaf:givenName']/text() != ''">
				<span about="this:person1" property="foaf:givenName">
					<xsl:value-of select="$updates//*[@about='this:person1' and @property='foaf:givenName']/text()"/>
				</span>
				<xsl:text> </xsl:text>
			</xsl:if>
			<span about="this:person1" property="foaf:familyName">
				<xsl:value-of select="$updates//*[@about='this:person1' and @property='foaf:familyName']/text()"/>
			</span>
			<xsl:if test="$updates//*[@about='this:person1' and @property='person:alsoKnownAs']/text() != ''">
				<span about="this:person1" property="person:alsoKnownAs">
					<xsl:value-of select="$updates//*[@about='this:person1' and @property='person:alsoKnownAs']/text()"/>
				</span>
			</xsl:if>
			<xsl:text> of </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:person1-address-1'"/>
			</xsl:call-template>
			<xsl:text> , on </xsl:text>
			<xsl:variable name="dateGranted">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='corp-insolvency:dateGranted']/text()"/>
			</xsl:variable>
			<span about="this:notifiableThing" property="corp-insolvency:dateGranted" datatype="xsd:date" content="{$dateGranted}">
				<xsl:value-of select="format-date(xs:date($dateGranted), '[FNn] [D01] [MNn] [Y0001]')"/>
			</span>
			<xsl:text>, conveying (to the extent specified in section 5(4A) in the Bankruptcy (Scotland) Act 1985) her estate to me, </xsl:text>
			<span about="this:person2" property="foaf:firstName">
				<xsl:value-of select="$updates//*[@about='this:person2' and @property='foaf:firstName']/text()"/>
			</span>
			<xsl:if test="$updates//*[@about='this:person2' and @property='foaf:givenName']/text() != ''">
				<span about="this:person2" property="foaf:givenName">
					<xsl:value-of select="$updates//*[@about='this:person2' and @property='foaf:givenName']/text()"/>
				</span>
			</xsl:if>
			<span about="this:person2" property="foaf:familyName">
				<xsl:value-of select="$updates//*[@about='this:person2' and @property='foaf:familyName']/text()"/>
			</span>
			<xsl:text> of </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:person2-address-1'"/>
			</xsl:call-template>
			<xsl:text> , as Trustee for the benefit of her Creditors generally.</xsl:text>
		</p>
		<p>
			<xsl:text>If a Creditor wishes to object to the Trust Deed for the purposes of preventing it becoming
      a Protected Trust Deed (see notes below on the objections required for that purpose)
      notification of such objection must be delivered in writing to the Trustee within 5 weeks of
      the date of the publication of this notice in </xsl:text>
			<i>The Edinburgh Gazette</i>
			<xsl:text>.</xsl:text>
		</p>
		<p>
			<xsl:text>Notes: The Trust Deed may become a Protected Trust Deed unless within the period of 5 weeks
      of the date of publication of this notice in </xsl:text>
			<i>The Edinburgh Gazette</i>
			<xsl:text> a majority in number
      or not less than one third in value of the Creditors notify the Trustee in writing that they
      object to the Trust Deed and do not wish to accede to them.</xsl:text>
		</p>
		<p>
			<xsl:text>Briefly, this has the effect of restricting the rights of non-acceding Creditors to do
      diligence (ie to enforce court decrees for unpaid debts) against the Debtor and confers
      certain protection upon the Trust Deed from being superseded by the sequestration of the
      Debtor's estate.</xsl:text>
		</p>
		<p>
			<span about="this:IP1" property="foaf:name">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
			</span>
			<xsl:text>, (IP number </xsl:text>
			<span about="this:IP1" property="person:hasIPnum">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPnum']/text()"/>
			</span>
			<xsl:text>), </xsl:text>
			<span about="this:IP1" property="person:hasIPCapacity">
				<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPCapacity']/text()"/>
			</span>
			<xsl:text>, </xsl:text>
			<span about="this:IP-company-1" property="gazorg:name">
				<xsl:value-of select="$updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text()"/>
			</span>
			<xsl:text>, </xsl:text>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:IP1-address-1'"/>
			</xsl:call-template>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text() != ''">
				<xsl:text>, Telephone number: </xsl:text>
				<span about="this:IP1" property="gaz:telephone" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:telephone']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:fax']/text() != ''">
				<xsl:text> Fax: </xsl:text>
				<span about="this:IP1" property="gaz:fax" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:fax']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='gaz:email']/text() != ''">
				<xsl:text> Email: </xsl:text>
				<span about="this:IP1" property="gaz:email" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='gaz:email']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text() != ''">
				<xsl:text> (Ref: </xsl:text>
				<span about="this:IP1" property="person:hasIPReferenceNumber" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPReferenceNumber']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
		</p>
		<!--<xsl:variable name="IPName">
      <xsl:value-of select="$updates//*[@about='this:IP1' and @property='foaf:name']/text()"/>
    </xsl:variable>
    <span about="this:IP1" typeof="person:InsolvencyPractitioner" property="foaf:name"
      datatype="xsd:string" content="{$IPName}"/>
    <xsl:variable name="IPNum">
      <xsl:value-of select="$updates//*[@about='this:IP1' and @property='person:hasIPnum']/text()"/>
    </xsl:variable>
    <span about="this:IP1" property="person:hasIPnum" datatype="xsd:string" content="{$IPNum}"/>
    <xsl:variable name="IPCompany">
      <xsl:value-of
        select="upper-case($updates//*[@about='this:IP-company-1' and @property='gazorg:name']/text())"
      />
    </xsl:variable>
    <span about="this:IP-company-1" typeof="gazorg:ForProfitOrganisation" property="gazorg:name"
      datatype="xsd:string" content="{$IPCompany}"/>
    <xsl:call-template name="address">
      <xsl:with-param name="updates" select="$updates"/>
      <xsl:with-param name="about" select="'this:IP1-address-1'"/>
    </xsl:call-template>
    <xsl:variable name="IPCapacity">
      <xsl:value-of
        select="$updates//*[@about='this:IP1' and @property='person:hasIPCapacity']/text()"/>
    </xsl:variable>
    <span about="this:IP1" property="person:hasIPCapacity" datatype="xsd:string"
      content="{$IPCapacity}"/>-->
	</xsl:template>
	<xsl:template name="boilerPlateText1510">
		<xsl:param name="updates"/>
		<p>
			<span about="this:legislation" property="legislation:legislationTitle" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:legislation' and @property='legislation:legislationTitle']/text()"/>
			</span>
		</p>
		<p>
			<span about="this:authority-1" property="gazorg:name" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:authority-1' and @property='gazorg:name']/text()"/>
			</span>
		</p>
		<p>
			<span about="this:legislation-1" property="legislation:legislationTitle" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:legislation-1' and @property='legislation:legislationTitle']/text()"/>
			</span>
		</p>
		<xsl:if test="$updates//*[@about='this:legislation-2' and @property='legislation:legislationTitle']/text() != ''">
			<p>
				<span about="this:legislation-2" property="legislation:legislationTitle" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:legislation-2' and @property='legislation:legislationTitle']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:legislation-3' and @property='legislation:legislationTitle']/text() != ''">
			<p>
				<span about="this:legislation-3" property="legislation:legislationTitle" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:legislation-3' and @property='legislation:legislationTitle']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:legislation-4' and @property='legislation:legislationTitle']/text() != ''">
			<p>
				<span about="this:legislation-4" property="legislation:legislationTitle" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:legislation-4' and @property='legislation:legislationTitle']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:legislation-5' and @property='legislation:legislationTitle']/text() != ''">
			<p>
				<span about="this:legislation-5" property="legislation:legislationTitle" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:legislation-5' and @property='legislation:legislationTitle']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-1' and @property='gaz:hasSubject']/text() != ''">
			<p>
				<span about="this:subjectElement-1" property="gaz:hasSubject" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-1' and @property='gaz:hasSubject']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-1' and @property='transport:hasSubheading']/text() != ''">
			<p>
				<span about="this:subjectElement-1" property="transport:hasSubheading" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-1' and @property='transport:hasSubheading']/text()"/>
				</span>
			</p>
		</xsl:if>
		<p>
			<span about="this:subjectElement-1" property="gaz:hasNoticeDetails" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:subjectElement-1' and @property='gaz:hasNoticeDetails']/text()"/>
			</span>
		</p>
		<xsl:if test="$updates//*[@about='this:subjectElement-2' and @property='gaz:hasSubject']/text() != ''">
			<p>
				<span about="this:subjectElement-2" property="gaz:hasSubject" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-2' and @property='gaz:hasSubject']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-2' and @property='transport:hasSubheading']/text() != ''">
			<p>
				<span about="this:subjectElement-2" property="transport:hasSubheading" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-2' and @property='transport:hasSubheading']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-2' and @property='gaz:hasNoticeDetails']/text() != ''">
			<p>
				<span about="this:subjectElement-2" property="gaz:hasNoticeDetails" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-2' and @property='gaz:hasNoticeDetails']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-3' and @property='gaz:hasSubject']/text() != ''">
			<p>
				<span about="this:subjectElement-3" property="gaz:hasSubject" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-3' and @property='gaz:hasSubject']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-3' and @property='transport:hasSubheading']/text() != ''">
			<p>
				<span about="this:subjectElement-3" property="transport:hasSubheading" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-3' and @property='transport:hasSubheading']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-3' and @property='gaz:hasNoticeDetails']/text() != ''">
			<p>
				<span about="this:subjectElement-3" property="gaz:hasNoticeDetails" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-3' and @property='gaz:hasNoticeDetails']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-4' and @property='gaz:hasSubject']/text() != ''">
			<p>
				<span about="this:subjectElement-4" property="gaz:hasSubject" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-4' and @property='gaz:hasSubject']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-4' and @property='transport:hasSubheading']/text() != ''">
			<p>
				<span about="this:subjectElement-4" property="transport:hasSubheading" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-4' and @property='transport:hasSubheading']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-4' and @property='gaz:hasNoticeDetails']/text() != ''">
			<p>
				<span about="this:subjectElement-4" property="gaz:hasNoticeDetails" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-4' and @property='gaz:hasNoticeDetails']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-5' and @property='gaz:hasSubject']/text() != ''">
			<p>
				<span about="this:subjectElement-5" property="gaz:hasSubject" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-5' and @property='gaz:hasSubject']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-5' and @property='transport:hasSubheading']/text() != ''">
			<p>
				<span about="this:subjectElement-5" property="transport:hasSubheading" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-5' and @property='transport:hasSubheading']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-5' and @property='gaz:hasNoticeDetails']/text() != ''">
			<p>
				<span about="this:subjectElement-5" property="gaz:hasNoticeDetails" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-5' and @property='gaz:hasNoticeDetails']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-6' and @property='gaz:hasSubject']/text() != ''">
			<p>
				<span about="this:subjectElement-6" property="gaz:hasSubject" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-6' and @property='gaz:hasSubject']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-6' and @property='transport:hasSubheading']/text() != ''">
			<p>
				<span about="this:subjectElement-6" property="transport:hasSubheading" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-6' and @property='transport:hasSubheading']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-6' and @property='gaz:hasNoticeDetails']/text() != ''">
			<p>
				<span about="this:subjectElement-6" property="gaz:hasNoticeDetails" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-6' and @property='gaz:hasNoticeDetails']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-7' and @property='gaz:hasSubject']/text() != ''">
			<p>
				<span about="this:subjectElement-7" property="gaz:hasSubject" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-7' and @property='gaz:hasSubject']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-7' and @property='transport:hasSubheading']/text() != ''">
			<p>
				<span about="this:subjectElement-7" property="transport:hasSubheading" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-7' and @property='transport:hasSubheading']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-7' and @property='gaz:hasNoticeDetails']/text() != ''">
			<p>
				<span about="this:subjectElement-7" property="gaz:hasNoticeDetails" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-7' and @property='gaz:hasNoticeDetails']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-8' and @property='gaz:hasSubject']/text() != ''">
			<p>
				<span about="this:subjectElement-8" property="gaz:hasSubject" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-8' and @property='gaz:hasSubject']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-8' and @property='transport:hasSubheading']/text() != ''">
			<p>
				<span about="this:subjectElement-8" property="transport:hasSubheading" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-8' and @property='transport:hasSubheading']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-8' and @property='gaz:hasNoticeDetails']/text() != ''">
			<p>
				<span about="this:subjectElement-8" property="gaz:hasNoticeDetails" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-8' and @property='gaz:hasNoticeDetails']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-9' and @property='gaz:hasSubject']/text() != ''">
			<p>
				<span about="this:subjectElement-9" property="gaz:hasSubject" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-9' and @property='gaz:hasSubject']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-9' and @property='transport:hasSubheading']/text() != ''">
			<p>
				<span about="this:subjectElement-9" property="transport:hasSubheading" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-9' and @property='transport:hasSubheading']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-9' and @property='gaz:hasNoticeDetails']/text() != ''">
			<p>
				<span about="this:subjectElement-9" property="gaz:hasNoticeDetails" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-9' and @property='gaz:hasNoticeDetails']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-10' and @property='gaz:hasSubject']/text() != ''">
			<p>
				<span about="this:subjectElement-10" property="gaz:hasSubject" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-10' and @property='gaz:hasSubject']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-10' and @property='transport:hasSubheading']/text() != ''">
			<p>
				<span about="this:subjectElement-10" property="transport:hasSubheading" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-10' and @property='transport:hasSubheading']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:subjectElement-10' and @property='gaz:hasNoticeDetails']/text() != ''">
			<p>
				<span about="this:subjectElement-10" property="gaz:hasNoticeDetails" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:subjectElement-10' and @property='gaz:hasNoticeDetails']/text()"/>
				</span>
			</p>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='gaz:hasAdditionalInformation']/text() != ''">
			<p>
				<span about="this:notifiableThing" property="gaz:hasAdditionalInformation" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='gaz:hasAdditionalInformation']/text()"/>
				</span>
			</p>
		</xsl:if>
		<p>
			<xsl:if test="$updates//*[@about='this:signatory-1' and @property='foaf:name']/text() != ''">
				<span about="this:signatory-1" property="foaf:name" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:signatory-1' and @property='foaf:name']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:role-signatory-1' and @property='person:roleName']/text() != ''">
				<span about="this:role-signatory-1" property="person:roleName" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:role-signatory-1' and @property='person:roleName']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:authority-2' and @property='gazorg:name']/text() != ''">
				<span about="this:authority-2" property="gazorg:name" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:authority-2' and @property='gazorg:name']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:authority-2' and @property='authority:hasDepartment']/text() != ''">
				<span about="this:authority-2" property="authority:hasDepartment" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:authority-2' and @property='authority:hasDepartment']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:authority-2-address-1'"/>
			</xsl:call-template>
			<xsl:if test="$updates//*[@about='this:authority-2' and @property='gaz:telephone']/text() != ''">
				<xsl:text>Telephone number: </xsl:text>
				<span about="this:authority-2" property="gaz:telephone" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:authority-2' and @property='gaz:telephone']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:authority-2' and @property='gaz:fax']/text() != ''">
				<xsl:text>Fax: </xsl:text>
				<span about="this:authority-2" property="gaz:fax" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:authority-2' and @property='gaz:fax']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:authority-2' and @property='gaz:email']/text() != ''">
				<xsl:text>Email: </xsl:text>
				<span about="this:authority-2" property="gaz:email" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:authority-2' and @property='gaz:email']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:authority-2' and @property='authority:hasReferenceNumber']/text() != ''">
				<xsl:text> (Ref: </xsl:text>
				<span about="this:authority-2" property="authority:hasReferenceNumber" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:authority-2' and @property='authority:hasReferenceNumber']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:variable name="dateAuthorisationSigned">
				<xsl:value-of select="$updates//*[@about='this:authoriser-1' and @property='gaz:dateAuthorisationSigned']/text()"/>
			</xsl:variable>
			<xsl:if test="$updates//*[@about='this:authoriser-1' and @property='gaz:dateAuthorisationSigned']/text() != ''">
				<p>
					<span about="this:authoriser-1" property="gaz:dateAuthorisationSigned" datatype="xsd:date" content="{$dateAuthorisationSigned}">
						<xsl:value-of select="format-date(xs:date($dateAuthorisationSigned), '[FNn] [D01] [MNn] [Y0001]')"/>
					</span>
				</p>
			</xsl:if>
		</p>
	</xsl:template>
	<xsl:template name="boilerPlateText1601">
		<xsl:param name="updates"/>
		<h2>
			<span about="this:authority-1" property="gazorg:name" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:authority-1' and @property='gazorg:name']/text()"/>
			</span>
		</h2>
		<xsl:for-each-group select="$updates//*[starts-with(@about, 'this:legislation-') and text() != '']" group-by="@about">
			<xsl:sort data-type="number" select="replace(@about,'this:legislation-','')"/>
			<xsl:variable name="about">
				<xsl:value-of select="@about"/>
			</xsl:variable>
			<xsl:variable name="index">
				<xsl:value-of select="substring-after($about,'this:legislation-')"/>
			</xsl:variable>
			<h3 about="{$about}" property="legislation:legislationTitle" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about=concat('this:legislation-',$index) and @property='legislation:legislationTitle']/text()"/>
			</h3>
		</xsl:for-each-group>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='gaz:hasSubject']/text() != ''">
			<p about="this:notifiableThing" property="gaz:hasSubject" datatype="xsd:string">
				<xsl:value-of select="$updates//*[@about='this:notifiableThing' and @property='gaz:hasSubject']/text()"/>
			</p>
		</xsl:if>
		<div about="this:notifiableThing" property="planning:orderDetails" datatype="xsd:string" content="{normalize-space($updates//*[@about='this:notifiableThing' and @property='planning:orderDetails']/text())}">
			<xsl:for-each select="tokenize($updates//*[@about='this:notifiableThing' and @property='planning:orderDetails']/text(),'\n')">
				<p>
					<xsl:value-of select="."/>
				</p>
			</xsl:for-each>
		</div>
		<xsl:if test="$updates//*[starts-with(@about, 'this:proposal-')]">
			<table>
				<thead>
					<tr>
						<th>Proposal Reference</th>
						<th>Address of Proposal</th>
						<th>Applicant Information</th>
						<th>Description of Proposal</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each-group select="$updates//*[starts-with(@about, 'this:proposal-') and text() != '']" group-by="@about">
						<xsl:sort data-type="number" select="replace(@about,'this:proposal-','')"/>
						<xsl:variable name="about">
							<xsl:value-of select="@about"/>
						</xsl:variable>
						<xsl:variable name="index">
							<xsl:value-of select="substring-after($about,'this:proposal-')"/>
						</xsl:variable>
						<xsl:if test="$updates//*[@about=concat('this:proposal-',$index) and @property='planning:proposalReference']/text() != '' or $updates//*[@about=concat('this:applicant-',$index) and @property='foaf:name']/text() != '' or $updates//*[@about=concat('this:proposal-',$index) and @property='planning:proposalDescription']/text() != ''">
							<tr>
								<td>
									<xsl:if test="$updates//*[@about=concat('this:proposal-',$index) and @property='planning:proposalReference']/text() != ''">
										<span about="{$about}" property="planning:proposalReference" datatype="xsd:string">
											<xsl:value-of select="$updates//*[@about=concat('this:proposal-',$index) and @property='planning:proposalReference']/text()"/>
										</span>
									</xsl:if>
								</td>
								<td>
									<xsl:call-template name="address">
										<xsl:with-param name="updates" select="$updates"/>
										<xsl:with-param name="about" select="concat('this:proposal-',$index,'-address-1')"/>
									</xsl:call-template>
								</td>
								<td>
									<xsl:if test="$updates//*[@about=concat('this:applicant-',$index) and @property='foaf:name']/text() != ''">
										<span about="{concat('this:applicant-',$index)}" property="foaf:name">
											<xsl:value-of select="$updates//*[@about=concat('this:applicant-',$index) and @property='foaf:name']/text()"/>
										</span>
									</xsl:if>
								</td>
								<td>
									<xsl:if test="$updates//*[@about=concat('this:proposal-',$index) and @property='planning:proposalDescription']/text() != ''">
										<div about="{$about}" property="planning:proposalDescription" datatype="xsd:string" content="{normalize-space($updates//*[@about=concat('this:proposal-',$index) and @property='planning:proposalDescription']/text())}">
											<xsl:for-each select="tokenize($updates//*[@about=concat('this:proposal-',$index) and @property='planning:proposalDescription']/text(),'\n')">
												<p>
													<xsl:value-of select="."/>
												</p>
											</xsl:for-each>
										</div>
									</xsl:if>
								</td>
							</tr>
						</xsl:if>
					</xsl:for-each-group>
				</tbody>
			</table>
		</xsl:if>
		<xsl:if test="$updates//*[@about='this:notifiableThing' and @property='gaz:hasAdditionalInformation']/text() != ''">
			<div about="this:notifiableThing" property="gaz:hasAdditionalInformation" datatype="xsd:string" content="{normalize-space($updates//*[@about='this:notifiableThing' and @property='planning:hasAdditionalInformation']/text())}">
				<xsl:for-each select="tokenize($updates//*[@about='this:notifiableThing' and @property='gaz:hasAdditionalInformation']/text(),'\n')">
					<p>
						<xsl:value-of select="."/>
					</p>
				</xsl:for-each>
			</div>
		</xsl:if>
		<p>
			<xsl:if test="$updates//*[@about='this:signatory-1' and @property='foaf:name']/text() != ''">
				<em about="this:signatory-1" property="foaf:name" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:signatory-1' and @property='foaf:name']/text()"/>
				</em>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:role-signatory-1' and @property='person:roleName']/text() != ''">
				<span about="this:role-signatory-1" property="person:roleName" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:role-signatory-1' and @property='person:roleName']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:authority-2' and @property='gazorg:name']/text() != ''">
				<span about="this:authority-2" property="gazorg:name" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:authority-2' and @property='gazorg:name']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:authority-2' and @property='authority:hasDepartment']/text() != ''">
				<span about="this:authority-2" property="authority:hasDepartment" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:authority-2' and @property='authority:hasDepartment']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:call-template name="address">
				<xsl:with-param name="updates" select="$updates"/>
				<xsl:with-param name="about" select="'this:authority-2-address-1'"/>
			</xsl:call-template>
			<xsl:if test="$updates//*[@about='this:authority-2' and @property='gaz:telephone']/text() != ''">
				<xsl:text>Telephone number: </xsl:text>
				<span about="this:authority-2" property="gaz:telephone" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:authority-2' and @property='gaz:telephone']/text()"/>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:authority-2' and @property='gaz:fax']/text() != ''">
				<xsl:text>Fax: </xsl:text>
				<span about="this:authority-2" property="gaz:fax" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:authority-2' and @property='gaz:fax']/text()"/>
				</span>, </xsl:if>
			<xsl:if test="$updates//*[@about='this:authority-2' and @property='gaz:email']/text() != ''">
				<xsl:text>Email: </xsl:text>
				<span about="this:authority-2" property="gaz:email" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:authority-2' and @property='gaz:email']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:authority-2' and @property='authority:hasReferenceNumber']/text() != ''">
				<xsl:text> (Ref: </xsl:text>
				<span about="this:authority-2" property="authority:hasReferenceNumber" datatype="xsd:string">
					<xsl:value-of select="$updates//*[@about='this:authority-2' and @property='authority:hasReferenceNumber']/text()"/>
				</span>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:variable name="dateAuthorisationSigned">
				<xsl:value-of select="$updates//*[@about='this:authoriser-1' and @property='gaz:dateAuthorisationSigned']/text()"/>
			</xsl:variable>
			<xsl:if test="$updates//*[@about='this:authoriser-1' and @property='gaz:dateAuthorisationSigned']/text() != ''">
				<p>
					<span about="this:authoriser-1" property="gaz:dateAuthorisationSigned" datatype="xsd:date" content="{$dateAuthorisationSigned}">
						<xsl:value-of select="format-date(xs:date($dateAuthorisationSigned), '[FNn] [D01] [MNn] [Y0001]')"/>
					</span>
				</p>
			</xsl:if>
		</p>
	</xsl:template>
	<xsl:template name="boilerPlateText3301">
		<xsl:param name="updates"/>
		<xsl:if test="$updates//*[@about='https://www.thegazette.co.uk/id/honour/PointsOfLight' and @property='honours:hasAwardNumber']/text() != ''">
			<p data-gazettes="AwardNumber">Award Number: <span about="https://www.thegazette.co.uk/id/honour/PointsOfLight" property="honours:hasAwardNumber" typeof="honours:PointsOfLightAward">
					<xsl:value-of select="$updates//*[@about='https://www.thegazette.co.uk/id/honour/PointsOfLight' and @property='honours:hasAwardNumber']/text()"/>
				</span>
			</p>
		</xsl:if>
		<h2 property="gaz:hasAuthority" resource="this:authority-1" typeof="gaz:Authority">
			<span property="rdfs:label">The Prime Minister's Office</span>
		</h2>
		<div data-gazettes="Administration">
			<p data-gazettes="authoriser">
				<span property="gaz:hasAuthoriser" resource="this:authoriser" typeof="gaz:Authoriser">10 Downing Street, SW1A 2AA</span>
			</p>
		</div>
		<xsl:variable name="dateAuthorisationSigned">
			<xsl:value-of select="$updates//*[@about='this:authoriser-1' and @property='gaz:dateAuthorisationSigned']/text()"/>
		</xsl:variable>
		<xsl:if test="$updates//*[@about='this:authoriser-1' and @property='gaz:dateAuthorisationSigned']/text() != ''">
			<p data-gazettes="DateSigned">
				<span property="gaz:dateAuthorisationSigned" datatype="xsd:date" content="{$dateAuthorisationSigned}">
					<xsl:value-of select="format-date(xs:date($dateAuthorisationSigned), '[D01] [MNn] [Y0001]')"/>
				</span>
			</p>
		</xsl:if>
		<xsl:variable name="personName">
			<xsl:value-of select="$updates//*[@about='this:person' and @property='foaf:title']/text()"/>
			<xsl:if test="$updates//*[@about='this:person' and @property='foaf:title']/text() != ''">
				<xsl:value-of select="concat(' ', $updates//*[@about='this:person' and @property='foaf:firstName']/text())"/>
			</xsl:if>
			<xsl:if test="$updates//*[@about='this:person' and @property='foaf:title']/text() = ''">
				<xsl:value-of select="$updates//*[@about='this:person' and @property='foaf:firstName']/text()"/>
			</xsl:if>
			<xsl:value-of select="concat(' ', $updates//*[@about='this:person' and @property='foaf:givenName']/text())"/>
			<xsl:value-of select="concat(' ', $updates//*[@about='this:person' and @property='foaf:familyName']/text())"/>
			<xsl:value-of select="concat(' ', $updates//*[@about='this:person' and @property='person:honour']/text())"/>
		</xsl:variable>
		<div data-gazettes="Person" property="honours:hasAwardee" resource="this:person-1" typeof="person:Person">
			<h2 data-gazettes="PersonName">
				<span content="{$personName}" property="foaf:name"/>
				<xsl:if test="$updates//*[@about='this:person' and @property='foaf:title']/text() != ''">
					<span data-gazettes="Title" property="foaf:title">
						<xsl:value-of select="$updates//*[@about='this:person' and @property='foaf:title']/text()"/>
					</span>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:person' and @property='foaf:firstName']/text() != ''">
					<span data-gazettes="Forename" property="foaf:firstName">
						<xsl:value-of select="$updates//*[@about='this:person' and @property='foaf:firstName']/text()"/>
					</span>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:person' and @property='foaf:givenName']/text() != ''">
					<span data-gazettes="GivenName" property="foaf:givenName">
						<xsl:value-of select="$updates//*[@about='this:person' and @property='foaf:givenName']/text()"/>
					</span>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:person' and @property='foaf:familyName']/text() != ''">
					<span data-gazettes="Surname" property="foaf:familyName">
						<xsl:value-of select="$updates//*[@about='this:person' and @property='foaf:familyName']/text()"/>
					</span>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:if test="$updates//*[@about='this:person' and @property='person:honour']/text() != ''">
					<span data-gazettes="Honour" property="person:honour">
						<xsl:value-of select="$updates//*[@about='this:person' and @property='person:honour']/text()"/>
					</span>
				</xsl:if>
			</h2>
		</div>
		<xsl:if test="($updates//*[@about='this:person-address-1' and @property='vcard:locality']/text() != '') 
		or ($updates//*[@about='this:person-address-1' and @property='vcard:region']/text() != '')">
			<xsl:variable name="town">
				<xsl:call-template name="titlecase">
					<xsl:with-param name="text">
						<xsl:value-of select="$updates//*[@about='this:person-address-1' and @property='vcard:locality']/text()"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="region">
				<xsl:call-template name="titlecase">
					<xsl:with-param name="text">
						<xsl:value-of select="$updates//*[@about='this:person-address-1' and @property='vcard:region']/text()"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<p data-gazettes="PersonAddress" property="person:hasAddress" resource="this:person-1-PersonAddress-1" typeof="vcard:Address">
				<xsl:choose>
					<xsl:when test="($town/text() != '') and ($region/text() != '')">
						<span content="{$town}, {$region}" data-gazettes="AddressLineGroup" data-gazettes-class="Awardee" property="vcard:label"/>
					</xsl:when>
					<xsl:when test="($town/text() != '') and ($region/text() = '')">
						<span content="{$town}" data-gazettes="AddressLineGroup" data-gazettes-class="Awardee" property="vcard:label"/>
					</xsl:when>
					<xsl:when test="($town/text() = '') and ($region/text() != '')">
						<span content="{$region}" data-gazettes="AddressLineGroup" data-gazettes-class="Awardee" property="vcard:label"/>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="($updates//*[@about='this:person-address-1' and @property='vcard:locality']/text() != '')"> </xsl:if>
				<xsl:if test="$town/text() != ''">
					<span data-gazettes="AddressLine" property="vcard:locality">
						<xsl:call-template name="titlecase">
							<xsl:with-param name="text">
								<xsl:value-of select="$town/text()"/>
							</xsl:with-param>
						</xsl:call-template>
					</span>
					<xsl:if test="$region/text() != ''">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:if test="$region/text() != ''">
					<span data-gazettes="AddressLine" property="vcard:region">
						<xsl:call-template name="titlecase">
							<xsl:with-param name="text">
								<xsl:value-of select="$region/text()"/>
							</xsl:with-param>
						</xsl:call-template>
					</span>
				</xsl:if>
			</p>
		</xsl:if>
		<div data-gazettes="P">
			<p data-gazettes="Text">
				<xsl:value-of select="$updates//*[@about='https://www.thegazette.co.uk/id/honour/PointsOfLight' and @property='honours:hasCitation']/text()"/>
			</p>
		</div>
	</xsl:template>
	<xsl:template name="titlecase">
		<xsl:param name="text" as="xs:string"/>
		<xsl:sequence select="string-join(for $x in tokenize($text,'\s') return concat(upper-case(substring($x, 1, 1)), lower-case(substring($x, 2))), ' ')"/>
	</xsl:template>
	<xsl:template name="address">
		<xsl:param name="updates"/>
		<xsl:param name="about"/>
		<xsl:if test="$updates//*[@about=$about and @property='vcard:street-address']/text() != ''">
			<span about="{$about}" property="vcard:street-address" typeof="vcard:Address">
				<xsl:call-template name="titlecase">
					<xsl:with-param name="text">
						<xsl:value-of select="$updates//*[@about=$about and @property='vcard:street-address']/text()"/>
					</xsl:with-param>
				</xsl:call-template>
			</span>
			<xsl:text>, </xsl:text>
			<xsl:if test="$updates//*[@about=$about and @property='vcard:extended-address']/text() != ''">
				<span about="{$about}" property="vcard:extended-address">
					<xsl:call-template name="titlecase">
						<xsl:with-param name="text">
							<xsl:value-of select="$updates//*[@about=$about and @property='vcard:extended-address']/text()"/>
						</xsl:with-param>
					</xsl:call-template>
				</span>
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="$updates//*[@about=$about and @property='vcard:locality']/text() != ''">
				<span about="{$about}" property="vcard:locality">
					<xsl:call-template name="titlecase">
						<xsl:with-param name="text">
							<xsl:value-of select="$updates//*[@about=$about and @property='vcard:locality']/text()"/>
						</xsl:with-param>
					</xsl:call-template>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about=$about and @property='vcard:region']/text() != ''"> , <span about="{$about}" property="vcard:region">
					<xsl:call-template name="titlecase">
						<xsl:with-param name="text">
							<xsl:value-of select="$updates//*[@about=$about and @property='vcard:region']/text()"/>
						</xsl:with-param>
					</xsl:call-template>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about=$about and @property='vcard:postal-code']/text() != ''">
				<xsl:text> </xsl:text>
				<span about="{$about}" property="vcard:postal-code">
					<!--<xsl:if
            test="$about='this:company-principal-trading-address-1' or $about='this:previous-trading-address-1' or $about='this:company-previous-registered-office-1'">
            <xsl:attribute name="style">margin-right:-4px</xsl:attribute>
          </xsl:if>-->
					<xsl:value-of select="upper-case($updates//*[@about=$about and @property='vcard:postal-code']/text())"/>
				</span>
			</xsl:if>
			<xsl:if test="$updates//*[@about=$about and @property='vcard:country-name']/text() != ''">
				<span about="{$about}" property="vcard:country-name">
					<xsl:text> </xsl:text>
					<!-- Removed titlecase function to allow for UK, U.K, etc.. Should enhance the function in future -->
					<xsl:value-of select="$updates//*[@about=$about and @property='vcard:country-name']/text()"/>
				</span>
			</xsl:if>
			<xsl:if test="$about = 'this:authority-2-address-1'">
				<xsl:text>, </xsl:text>
			</xsl:if>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
