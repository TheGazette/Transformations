<?xml version="1.0" encoding="UTF-8"?>
<!--
	©  Crown copyright
	You may use and re-use this code free of charge under the terms of the Open Government Licence
	http://www.nationalarchives.gov.uk/doc/open-government-licence/
-->
<!--Version 1.0-->
<!--Created by Williams Lea XML Team-->
<!--
	  Purpose of transform: transform legacy pre-2005 DTD format into HTML-RDFa for all notice types except 2903
		Change history
		1.0 Initial Release: 20th January 2014
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0"
	xmlns:wlf="http://www.williamslea.com/xsl/functions" xmlns:gzc="http://www.tso.co.uk/assets/namespace/gazette/LGconfiguration" xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml">

	<xsl:output encoding="utf-8"/>


	<!-- Parameters to create metadata info -->
	<xsl:param name="edition" as="xs:string" required="yes"/>
	<xsl:param name="issueNumber" required="no"/>
	<xsl:param name="pageNumber" as="xs:string">0</xsl:param>
	<xsl:param name="bundleId" as="xs:string" required="yes"/>
	<xsl:param name="noticeId" as="xs:string" required="yes"/>
	<xsl:param name="legacyNoticeNumber" as="xs:string" required="yes"/>
	<xsl:param name="status" as="xs:string" required="yes"/>
	<xsl:param name="version-count" as="xs:string" required="yes"/>
	<xsl:param name="user-submitted" as="xs:string" required="yes"/>
	<xsl:param name="legal-information"/>
	<xsl:param name="mapping" as="node()"><a/></xsl:param>

	<!-- Load configuration file containing the conceptual hierarchy among the notice types. -->
	<xsl:variable name="vHTMLcompatible" select="false()" as="xs:boolean"/>
	<xsl:variable name="paramConfigXml" select="if (doc-available('LGconfiguration.xml')) then doc('LGconfiguration.xml') else ()"/>
	<xsl:variable name="gaz">https://www.thegazette.co.uk/</xsl:variable>
	<xsl:variable name="noticeType" select="notice/@code"/>
	<xsl:variable name="noticeNo">
		<xsl:choose>
			<xsl:when test="$legacyNoticeNumber != '' and (starts-with($noticeId,'L') or starts-with($noticeId,'B') or starts-with($noticeId,'E'))">
				<xsl:value-of select="translate(translate($legacyNoticeNumber,'(',''),')','')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$noticeId"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="idURI" select="concat($gaz,'id','/notice/', translate($noticeId,'/','-'))"/>
	<xsl:variable name="documentURI" select="concat($gaz,'notice/', translate($noticeId,'/','-'))"/>
	<xsl:variable name="noticeCode" select="notice/@code"/>
	<xsl:variable name="noticeURI" select="concat($gaz,'id','/notice/', translate($noticeId,'/','-'))"/>
	<xsl:variable name="oldNoticeURI" select="concat($gaz,'id/','edition/',$edition,'/issue/',$issueNumber,'/notice/', translate($noticeId,'/','-'))"/>
	<xsl:variable name="issueURI" select="concat($gaz,'id/','edition/',$edition,'/issue/',$issueNumber)"/>
	<xsl:variable name="editionURI" select="concat($gaz,'id/','edition/',$edition)"/>
	<xsl:variable name="getMonthofPubDate">
		<xsl:call-template name="getMonth">
			<xsl:with-param name="month" select="normalize-space(notice/date/month)"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="getDayofPubDate">
		<xsl:call-template name="getDay"/>
	</xsl:variable>
	<xsl:variable name="noticeDate">
		<xsl:value-of select="normalize-space(notice/date/year)"/>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="$getMonthofPubDate"/>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="$getDayofPubDate"/>
		<xsl:text>T01:00:00</xsl:text>
	</xsl:variable>
	<xsl:variable name="publicationDate">
		<xsl:choose>
			<xsl:when test="$noticeDate castable as xs:dateTime">
				<xsl:value-of select="format-dateTime(xs:dateTime($noticeDate), '[D] [MNn] [Y] [h]:[m]:[s] [P]')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(notice/date/day)"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="normalize-space(notice/date/month)"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="normalize-space(notice/date/year)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="category" select="$mapping//*:Map[@Code = $noticeType]/*:notice-category-codes"/>

	<!-- not currently used -->
	<xsl:function name="wlf:getAddress">
		<xsl:param name="address"/>
		<xsl:choose>
			<xsl:when test="contains($address,'&lt;?BR?&gt;')">
				<xsl:value-of select="substring-before($address,'&lt;?BR?&gt;')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:analyze-string select="$address" regex="^(.*?)((\d\d?)([n|r|s|t]?[d|h|t]?.)(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)([a-z]*.)(\d\d\d\d))(.*)$">
					<xsl:matching-substring>
						<xsl:value-of select="normalize-space(regex-group(1))"/>
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- not currently used -->
	<xsl:function name="wlf:getDeathofDate">
		<xsl:param name="address"/>
		<xsl:choose>
			<xsl:when test="contains($address,'&lt;?BR?&gt;')">
				<xsl:value-of select="substring-after($address,'&lt;?BR?&gt;')"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- xsl:analyze-string select="$address" regex="^(.*?)([0-9][0-9]?(rd|th|st|nd)\s+[January|February|March|April|May|June|July|August|September|October|November|December]\s+[0-9][0-9][0-9][0-9])(.*)$" -->
				<xsl:analyze-string select="$address" regex="((\d\d?)([n|r|s|t]?[d|h|t]?.)(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)([a-z]*.)(\d\d\d\d))">
					<xsl:matching-substring>
						<xsl:value-of select="normalize-space(regex-group(1))"/>
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- currently not used -->
	<xsl:function name="wlf:marklogicdate">
		<xsl:param name="olddate"/>
		<!-- xsl:analyze-string select="$olddate" regex="(\d\d?)\w?\w?\s+(\w\w\w)\w*\s+(\d\d\d\d)" -->
		<!-- p><xsl:value-of select="$olddate"/></p -->
		<xsl:variable name="olddate-cleaned" select="replace($olddate,' ',' ')"/>
		<xsl:analyze-string select="$olddate-cleaned" regex="(\d\d?)[n|r|s|t]?[d|h|t]?.(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*.(\d\d\d\d)">
			<xsl:matching-substring>
				<xsl:value-of select="regex-group(3)"/>
				<xsl:text>-</xsl:text>
				<xsl:choose>
					<xsl:when test="regex-group(2)='Jan'">01</xsl:when>
					<xsl:when test="regex-group(2)='Feb'">02</xsl:when>
					<xsl:when test="regex-group(2)='Mar'">03</xsl:when>
					<xsl:when test="regex-group(2)='Apr'">04</xsl:when>
					<xsl:when test="regex-group(2)='May'">05</xsl:when>
					<xsl:when test="regex-group(2)='Jun'">06</xsl:when>
					<xsl:when test="regex-group(2)='Jul'">07</xsl:when>
					<xsl:when test="regex-group(2)='Aug'">08</xsl:when>
					<xsl:when test="regex-group(2)='Sep'">09</xsl:when>
					<xsl:when test="regex-group(2)='Oct'">10</xsl:when>
					<xsl:when test="regex-group(2)='Nov'">11</xsl:when>
					<xsl:when test="regex-group(2)='Dec'">12</xsl:when>
				</xsl:choose>
				<xsl:text>-</xsl:text>
				<xsl:variable name="day" select="regex-group(1)"/>
				<xsl:if test="xs:integer($day)&lt;10">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:value-of select="$day"/>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>

	<xsl:template name="getMonth">
		<xsl:param name="month" required="yes"/>
		<xsl:choose>
			<xsl:when test="lower-case($month)='january'">01</xsl:when>
			<xsl:when test="lower-case($month)='february'">02</xsl:when>
			<xsl:when test="lower-case($month)='march'">03</xsl:when>
			<xsl:when test="lower-case($month)='april'">04</xsl:when>
			<xsl:when test="lower-case($month)='may'">05</xsl:when>
			<xsl:when test="lower-case($month)='june'">06</xsl:when>
			<xsl:when test="lower-case($month)='july'">07</xsl:when>
			<xsl:when test="lower-case($month)='august'">08</xsl:when>
			<xsl:when test="lower-case($month)='september'">09</xsl:when>
			<xsl:when test="lower-case($month)='october'">10</xsl:when>
			<xsl:when test="lower-case($month)='november'">11</xsl:when>
			<xsl:when test="lower-case($month)='december'">12</xsl:when>
			<xsl:when test="lower-case($month)='jan'">01</xsl:when>
			<xsl:when test="lower-case($month)='feb'">02</xsl:when>
			<xsl:when test="lower-case($month)='mar'">03</xsl:when>
			<xsl:when test="lower-case($month)='apr'">04</xsl:when>
			<xsl:when test="lower-case($month)='may'">05</xsl:when>
			<xsl:when test="lower-case($month)='jun'">06</xsl:when>
			<xsl:when test="lower-case($month)='jul'">07</xsl:when>
			<xsl:when test="lower-case($month)='aug'">08</xsl:when>
			<xsl:when test="lower-case($month)='sept'">09</xsl:when>
			<xsl:when test="lower-case($month)='oct'">10</xsl:when>
			<xsl:when test="lower-case($month)='nov'">11</xsl:when>
			<xsl:when test="lower-case($month)='dec'">12</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getDay">
		<xsl:variable name="dayInMonth">
			<xsl:value-of select="format-number(number(normalize-space(translate(translate(translate(translate(normalize-space(notice/date/day),'st',''),'nd',''),'rd',''),'th',''))),'00')"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$dayInMonth = 'NaN'">
				<xsl:value-of select="number(normalize-space(notice/date/weekday))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$dayInMonth"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:include href="owlClasses.xsl"/>

	<xsl:template match="processing-instruction('BR')">
		<br/>
	</xsl:template>

	<xsl:template match="processing-instruction('SPACE3')">
		<br/>
	</xsl:template>

	<xsl:template match="processing-instruction('SPACE6')">
		<br/>
	</xsl:template>

	<!-- ########################################### -->
	<!-- ############### START HERE ################ -->
	<!-- ########################################### -->
	<xsl:template match="/">
		<xsl:apply-templates select="notice"/>
	</xsl:template>
	<xsl:template match="notice">
		<html
			prefix="dc11: http://purl.org/dc/elements/1.1/             gaz: https://www.thegazette.co.uk/def/publication#             person: https://www.thegazette.co.uk/def/person#               personal-legal: https://www.thegazette.co.uk/def/personal-legal#               org: http://www.w3.org/ns/org#              this: {$idURI}#              prov: http://www.w3.org/ns/prov#">
			<xsl:if test="not($vHTMLcompatible)">
				<xsl:attribute name="DocumentURI" select="$documentURI"/>
				<xsl:attribute name="IdURI" select="$idURI"/>
				<xsl:attribute name="version">XHTML+RDFa 1.1</xsl:attribute>
			</xsl:if>
			<head>
				<title>
					<xsl:value-of select="normalize-space(string-join($paramConfigXml//gzc:Notice[@Code = $noticeType]/gzc:Name/text(), ' '))"/>
				</title>
				<xsl:if test="not($vHTMLcompatible)">
					<!-- metadata-->
					<gazette-metadata xmlns="http://www.gazettes.co.uk/metadata">
						<bundle-id>
							<xsl:value-of select="$bundleId"/>
						</bundle-id>
						<notice-id>
							<xsl:value-of select="translate($noticeId,'/','-')"/>
						</notice-id>
						<status>
							<xsl:value-of select="$status"/>
						</status>
						<version-count>
							<xsl:value-of select="$version-count"/>
						</version-count>
						<notice-code>
							<xsl:value-of select="$noticeType"/>
						</notice-code>
						<xsl:copy-of select="$category" exclude-result-prefixes="#all"/>
						<notice-capture-method>pre-2005-dtd-xml</notice-capture-method>
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
						<xsl:if test="date/year">
							<publication-date>
								<xsl:value-of select="$noticeDate"/>
							</publication-date>
							<publication-year>
								<xsl:value-of select="substring($noticeDate,1,4)"/>
							</publication-year>
						</xsl:if>
						<legacy-notice-number>
							<xsl:value-of select="$noticeNo"/>
						</legacy-notice-number>
						<user-submitted>
							<xsl:value-of select="$user-submitted"/>
						</user-submitted>
						<!-- source>DTD</source -->
					</gazette-metadata>
				</xsl:if>
			</head>
			<body>
				<article>
					<div class="rdfa-data">
						<!-- Build the non-line RDFa linking data for the notice. -->
						<span about="{$noticeURI}" property="dc11:publisher" content="TSO (The Stationery Office), St Crispins, Duke Street, Norwich, NR3 1PD, 01603 622211, customer.services@tso.co.uk"/>
						<span about="{$noticeURI}" property="gaz:isAbout" resource="this:notifiableThing"/>
						<span about="{$noticeURI}" property="owl:sameAs" resource="https://www.thegazette.co.uk/id/notice/{$noticeId}"/>
						<span about="{$noticeURI}" property="prov:has_provenance" resource="https://www.thegazette.co.uk/id/notice/{$noticeId}/provenance"/>
						<span about="{$noticeURI}" property="prov:has_anchor" resource="{$noticeURI}"/>
						<span resource="{$editionURI}" typeof="gaz:Edition"/>
						<xsl:if test="$issueNumber">
							<span about="{$noticeURI}" property="gaz:isInIssue" resource="{$issueURI}"/>
							<span resource="{$issueURI}" typeof="gaz:Issue"/>
							<span about="{$issueURI}" property="gaz:hasEdition" resource="{$editionURI}"/>
							<span about="{$issueURI}" content="{$issueNumber}" datatype="xsd:string" property="gaz:hasIssueNumber"/>
							<span about="https://www.thegazette.co.uk/id/notice/{$noticeId}" property="owl:sameAs"
								resource="https://www.thegazette.co.uk/id/edition/{$edition}/issue/{$issueNumber}/notice/{$noticeNo}" typeof="gaz:Notice"/>
							<span about="https://www.thegazette.co.uk/id/notice/{$noticeId}" property="prov:alternateOf"
								resource="http://www.{lower-case($edition)}-gazette.co.uk/id/issues/{$issueNumber}/notices/{$noticeNo}" typeof="gaz:Notice"/>
							<span about="https://www.thegazette.co.uk/id/notice/{$noticeId}" property="gaz:hasNoticeNumber" datatype="xsd:integer" content="{$noticeNo}"/>
						</xsl:if>
						<xsl:comment>Notice Classes</xsl:comment>
						<span resource="{$noticeURI}" typeof="https://www.thegazette.co.uk/def/publication#Notice"/>
						<xsl:for-each select="$class/*/*[@noticecode = $noticeType and @type='notice']">
							<span resource="{$noticeURI}" typeof="{.}"/>
						</xsl:for-each>
						<span about="https://www.thegazette.co.uk/id/notice/{$noticeId}" property="gaz:hasNoticeNumber" datatype="xsd:integer" content="{$noticeNo}"/>
						<span resource="this:notifiableThing" typeof="https://www.thegazette.co.uk/def/publication#NotifiableThing"/>
						<xsl:for-each select="$class/*/*[@noticecode = $noticeType and @type='notifiablething']">
							<span resource="this:notifiableThing" typeof="{.}"/>
						</xsl:for-each>
						<!-- Common to all 2903 notices -->
						<xsl:choose>
							<xsl:when test="$noticeType = '2903'">
								<span about="{$noticeURI}" property="gaz:isRequiredByLegislation" resource="http://www.legislation.gov.uk/ukpga/Geo5/15-16/19/section/27"/>
								<span resource="this:notifiableThing" typeof="personal-legal:NoticeForClaimsAgainstEstate/"/>
								<span about="this:notifiableThing" property="personal-legal:hasPersonalRepresentative" resource="this:estateExecutor"/>
								<span resource="this:addressOfDeceased" typeof="vcard:Address"/>
								<span resource="this:addressOfExecutor" typeof="vcard:Address"/>
								<span resource="this:estateExecutor" typeof="foaf:Agent"/>
								<span about="this:estateExecutor" property="vcard:adr" resource="this:addressOfExecutor"/>
								<!-- Needed for all 2903 notices -->
								<span resource="{$noticeURI}" typeof="gaz:DeceasedEstatesNotice gaz:WillsAndProbateNotice gaz:Notice"/>
							</xsl:when>
						</xsl:choose>
					</div>
					<dl class="metadata">
						<dt>Notice category:</dt>
						<dd data-ui-class="category">
							<xsl:value-of select="$paramConfigXml/gzc:Configuration//gzc:Category[@Code = substring($noticeType,1,2)]/@Name"/>
						</dd>
						<dt>Notice type:</dt>
						<dd data-ui-class="notice-type">
							<xsl:value-of select="$paramConfigXml/gzc:Configuration//gzc:Notice[@Code = $noticeCode]/gzc:Name"/>
						</dd>
						<dt>Publication date:</dt>
						<dd about="{$noticeURI}" property="gaz:earliestPublicationDate" datatype="xsd:dateTime" content="{$noticeDate}">
							<time datetime="{$noticeDate}">
								<xsl:value-of select="$publicationDate"/>
							</time>
						</dd>
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
						<dt>Notice code:</dt>
						<dd property="gaz:hasNoticeCode" datatype="xsd:integer" about="{$noticeURI}">
							<xsl:value-of select="$noticeCode"/>
						</dd>
					</dl>
					<div class="content">
						<xsl:variable name="content">
							<xsl:apply-templates/>
						</xsl:variable>
						<xsl:variable name="paragraphed">
							<xsl:for-each select="$content/*">
								<xsl:choose>
									<xsl:when test="name()='p'">
										<xsl:call-template name="pass2Recurse">
											<xsl:with-param name="remainingData" select="."/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:copy-of select="."/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:variable>
						<xsl:apply-templates select="$paragraphed" mode="remove-empty"/>
						<xsl:if test="$noticeCode = '2903' and $edition = 'London'">
							<section>
								<h2>Legal information</h2>
								<p>
									<xsl:value-of select="$legal-information"/>
								</p>
							</section>
						</xsl:if>
					</div>
				</article>
			</body>
		</html>
	</xsl:template>
	<!-- Handle various levels of headings. -->
	<xsl:template match="head3[1]">
		<xsl:if test="$paramConfigXml//gzc:Notice[@Code = $noticeType]/gzc:Name/text() != ./text()">
			<h3 data-gazettes="h3">
				<xsl:apply-templates/>
			</h3>
		</xsl:if>
	</xsl:template>
	<xsl:template match="head3">
		<h3 data-gazettes="h3">
			<xsl:apply-templates/>
		</h3>
	</xsl:template>
	<xsl:template match="head4">
		<h4 data-gazettes="h4">
			<xsl:apply-templates/>
		</h4>
	</xsl:template>
	<xsl:template match="head5">
		<h5 data-gazettes="h5">
			<xsl:apply-templates/>
		</h5>
	</xsl:template>
	<xsl:template match="text">
		<p data-gazettes="text">
			<xsl:apply-templates/>
		</p>
	</xsl:template>
	<xsl:template match="hw1|hw2|hw3|hw4">
		<xsl:choose>
			<xsl:when test="not(count(*) = 0 and normalize-space() = '')">
				<xsl:choose>
					<xsl:when test="local-name() = 'hw2' and $noticeCode = ('1105','1120')">
						<!-- By inspection hw2 is used for as italic headings -->
						<em data-gazettes="{local-name(.)}">
							<xsl:apply-templates/>
						</em>
					</xsl:when>
					<xsl:when test="local-name() = 'hw4' and $noticeCode = ('1105','1120')">
						<!-- By inspection hw4 is used for The Queen and should be styled as all caps -->
						<em class="small-caps" data-gazettes="{local-name(.)}">
							<xsl:apply-templates/>
						</em>
					</xsl:when>
					<xsl:otherwise>
						<strong data-gazettes="{local-name(.)}">
							<xsl:apply-templates/>
						</strong>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<br/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Handle sig elements in the source data. -->
	<xsl:template match="sig">
		<span data-gazettes="sig">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	<!-- Suppress -->
	<xsl:template match="number"/>
	<!-- p data-gazettes="number"><xsl:apply-templates/></p>
  </xsl:template -->
	<xsl:template match="notice/date"/>
	<xsl:template match="img">
		<xsl:copy-of select="@*"/>
		<xsl:copy-of select="."/>
	</xsl:template>
	<xsl:template match="IMG">
		<xsl:copy-of select="@*"/>
		<xsl:copy-of select="."/>
	</xsl:template>
	<!-- Handle line breaking and spacing elements. -->
	<xsl:template match="br">
		<br/>
	</xsl:template>
	<xsl:template match="BR">
		<br/>
	</xsl:template>
	<xsl:template match="space3">
		<br/>
	</xsl:template>
	<xsl:template match="SPACE3">
		<br/>
	</xsl:template>
	<!-- Table handling. -->
	<xsl:template match="t">
		<table>
			<xsl:if test="@cols">
				<colgroup>
					<xsl:for-each select="1 to @cols">
						<col span="1"/>
					</xsl:for-each>
				</colgroup>
			</xsl:if>
			<xsl:apply-templates/>
		</table>
	</xsl:template>
	<xsl:template match="bt">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- Table rows. -->
	<xsl:template match="r">
		<tr>
			<xsl:apply-templates/>
		</tr>
	</xsl:template>
	<!-- Table cells. -->
	<xsl:template match="c">
		<td>
			<xsl:apply-templates/>
		</td>
	</xsl:template>
	<xsl:template match="@*|node()" mode="remove-empty">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="remove-empty"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*:p" mode="remove-empty">
		<xsl:if test="normalize-space(.) != ''">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="remove-empty"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	<xsl:template name="pass2Recurse">
		<xsl:param name="remainingData"/>
		<p>
			<xsl:for-each select="$remainingData/node()[not(self::*:br) and not(preceding-sibling::*:br)]">
				<xsl:choose>
					<xsl:when test="self::text()">
						<xsl:if test="normalize-space(.) != ''">
							<xsl:value-of select="."/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy>
							<xsl:apply-templates select="@*|node()" mode="remove-empty"/>
						</xsl:copy>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</p>
		<!-- If some br left in reamining data. Call template again -->
		<xsl:if test="$remainingData/*:br">
			<xsl:call-template name="pass2Recurse">
				<xsl:with-param name="remainingData">
					<xsl:copy-of select="$remainingData/node()[preceding-sibling::*:br]"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>