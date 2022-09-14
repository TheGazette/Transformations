<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
<!ENTITY ndash  "&#8211;" >
<!ENTITY mdash  "&#8212;" >
<!ENTITY nbsp	"&#160;" >
]>
<!--
(c)  Crown copyright
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2
-->
<!-- Version 1.02 -->
<!-- Created by Williams Lea XML Team -->
<!-- 
Change history

1.0 Initial release         

-->
<!-- This transformation is used for displaying dynamic contents for single notice -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes" xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:f="http://www.gazettes.co.uk/facets" xmlns:tax="http://www.gazettes.co.uk/assets/taxonomy"
	xmlns:m="http://www.gazettes.co.uk/metadata" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:saxon="http://saxon.sf.net/"
	xmlns:gfn="http://www.thegazette.co.uk/ns/functions" version="2.0"
	exclude-result-prefixes="#all" extension-element-prefixes="saxon">
	
	<xsl:output indent="no" method="xhtml" encoding="ascii" omit-xml-declaration="yes"/>
	<!-- the string should contain base64 encoded image/png -->
	<xsl:param name="barcode" required="yes" as="xs:string"/>
	<!-- page number -->
	<xsl:param name="initial-page" required="yes"/>
	<!-- isbn number ## -->
	<xsl:param name="isbn-number" required="no"/>
	<!-- issn number ## -->
	<xsl:param name="ISSN" required="no" select="''"/>
	<!-- decimal #.## value -->
	<xsl:param name="cover-price" as="xs:string" required="no" select="''"/>
	<!-- limit the table of contents to just the comma separated list of top level notice categories , blank or not set = all -->
	<xsl:param name="limit-table-of-contents" as="xs:string">
		<xsl:choose>
			<xsl:when test="$classreadyedition = 'insolvency'">
				<xsl:text>G106000000,G105000000</xsl:text>
			</xsl:when>
			<xsl:when test="$classreadyedition = 'wills-and-probate'">
				<xsl:text>G106000000</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<!-- SVG file of the Gazette Crest -->
	<xsl:param name="crest" as="node()" select="doc('local-test/gazette.svg')"/>
	<!-- SVG file of the TSO logo -->
	<xsl:param name="tso_logo" as="node()" select="doc('local-test/tso-gazettes.svg')"/>
	<!-- publication date (dd-mm-yyyy) -->
	<xsl:param name="publication-date" required="yes" as="xs:date"/>
	<!-- start of the search range (dd-mm-yyyy) -->
	<xsl:param name="publication-date-start"/>
	<!-- end of the search range (dd-mm-yyyy) -->
	<xsl:param name="publication-date-end"/>
	<!-- issue number -->
	<xsl:param name="number" required="yes"/>
	<!-- edition name needs to be passed as printed e.g. "London Gazette" ## -->
	<xsl:param name="edition-name" required="yes"/>
	<!-- Should the edition carry the thick black mourning border -->
	<xsl:param name="mourningBorder" select="'false'"/>
	<!-- Is this a bespoke gazette -->
	<xsl:param name="bespoke" select="'false'"/>
	<!-- Created should be firstname surname, only used for Bespoke gazettes -->
	<xsl:param name="created"/>
	<!-- What sort of bookmarks should be created - one of 'notice' or 'section'-->
	<xsl:param name="bookmarks" select="'notice'"/>
	<!-- we need access to the FULL taxonomy to create the table of contents and section headings - therefore mandatory -->
	<xsl:param name="taxonomy-notice-type" as="node()" select="doc('new-taxonomy.xml')"/>
	<!-- HTML document containing terms and conditions -->
	<!-- Java layer should make the choice as to which terms and conditions to pass -->
	<!-- local-test/terms.xhtml as test, production drawn from ML -->
	<xsl:param name="terms-and-conditions" as="node()" select="doc('local-test/terms.xhtml')"/>
	<xsl:param name="legislationText" as="node()" select="doc('legislation_text.xml')"/>
	<!-- HTML document containing contact information -->
	<!-- local-test/contact.xhtml as test, production drawn from ML  -->
	<xsl:param name="contact-document" as="node()" select="doc('local-test/contact.xhtml')"/>
	<!-- HTML document containing information needed to generate pricing table -->
	<!-- local-test/prices.xhtml as test, production drawn from ML -->
	<xsl:param name="prices" as="node()" select="doc('local-test/prices.xhtml')"/>
	<!-- total number of pages modulo 4 = number of extra pages ## -->
	<!-- to be used on the second pass to add an appropriate number of advert pages  (1-3) -->
	<!-- if number of extra pages = 0, no need to push it through a second time -->
	<xsl:param name="number-of-extra-pages" as="xs:integer" select="0"/>
	<!-- used for retrieving images, no trailing slash-->
	<xsl:param name="gazette-host-name" as="xs:string"/>
	<!-- prints out extra information for debugging -->
	<xsl:param name="DEBUG">false</xsl:param>
	<xsl:variable name="feed" select="/"/>
    <xsl:variable name="initial-counter">
        <xsl:value-of select="xs:integer($initial-page) - 1" />
    </xsl:variable>
	<xsl:variable name="classreadyedition1">
		<xsl:value-of
			select="lower-case(replace(normalize-space(replace(replace(replace($edition-name,' &amp; ',' and '),'The',''),'Gazette','')),' ','-'))"
		/>
	</xsl:variable>
	<xsl:variable name="classreadyedition">
		<xsl:choose>
			<xsl:when
				test="$classreadyedition1 = ('london','edinburgh','belfast','all-notices','wills-and-probate','insolvency')">
				<xsl:text>standard </xsl:text>
				<xsl:value-of select="$classreadyedition1"/>
			</xsl:when>
			<xsl:when test="$bespoke = 'true'">bespoke</xsl:when>
			<xsl:otherwise>
				<xsl:text>all-notices standard</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="existing">
		<xsl:for-each select="//atom:entry">
			<xsl:choose>
				<xsl:when
					test=".//*:notice-category-code/text() = ('G101000000','G102000000','G103000000','G104000000','G107000000')">
					<xsl:choose>
						<xsl:when
							test=".//*:notice-category-code/text() = ('G406010003','G406010002','G406010001','G206030000','G205010000')">
							<xsl:for-each select=".//*:notice-category-code">
								<xsl:if
									test="not(text() = ('G101000000','G102000000','G103000000','G104000000','G107000000'))">
									<code>
										<xsl:value-of select="."/>
									</code>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select=".//*:notice-category-code">
								<code>
									<xsl:value-of select="."/>
								</code>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select=".//*:notice-category-code">
						<code>
							<xsl:value-of select="."/>
						</code>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="publishingStatement">
		<xsl:choose>
			<xsl:when
				test="$publication-date-start castable as xs:dateTime and $publication-date-end castable as xs:dateTime">
				<xsl:text> all notices published online</xsl:text>
				<xsl:choose>
					<!-- only one day's notices -->
					<xsl:when
						test="format-dateTime($publication-date-start,'[Y0001][M01][D01]') = format-dateTime($publication-date-end,'[Y0001][M01][D01]')">
						<xsl:text> on </xsl:text>
						<xsl:value-of
							select="format-dateTime($publication-date-end,'[D] [MNn] [Y0001]')"/>
					</xsl:when>
					<!-- more than one day's notices -->
					<xsl:otherwise>
						<xsl:text> between </xsl:text>
						<!-- define format -->
						<xsl:choose>
							<!-- different day same month -->
							<xsl:when
								test="format-dateTime($publication-date-start,'[Y0001][M01]') = format-dateTime($publication-date-end,'[Y0001][M01]')">
								<xsl:value-of
									select="format-dateTime($publication-date-start,'[D]')"/>
							</xsl:when>
							<!-- different day and month same year -->
							<xsl:when
								test="format-dateTime($publication-date-start,'[Y0001]') = format-dateTime($publication-date-end,'[Y0001]')">
								<xsl:value-of
									select="format-dateTime($publication-date-start,'[D] [MNn]')"/>
							</xsl:when>
							<!-- different day, month and year -->
							<xsl:otherwise>
								<xsl:value-of
									select="format-dateTime($publication-date-start,'[D] [MNn] [Y0001]')"
								/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text> and </xsl:text>
						<xsl:value-of
							select="format-dateTime($publication-date-end,'[D] [MNn] [Y0001]')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="@*|node()" mode="post-process">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="post-process"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template
		match="xhtml:section[@class='notice-category'][./xhtml:section[1][@class='notice-type']/xhtml:article[1][contains(@class,'full-width')]]"
		mode="post-process">
		<xsl:copy>
			<xsl:copy-of select="@id"/>
			<xsl:copy-of select="@class"/>
			<header class="full-width">
				<xsl:copy-of select="xhtml:header/*"/>
			</header>
			<xsl:for-each select="xhtml:section|xhtml:article">
				<xsl:apply-templates select="." mode="post-process"/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xhtml:section/xhtml:table" mode="post-process" priority="6">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="post-process"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xhtml:table" mode="post-process">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="post-process"/>
			<xsl:choose>
				<xsl:when test="xhtml:thead">
					<xsl:apply-templates mode="post-process"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="xhtml:colgroup">
						<xsl:apply-templates select="xhtml:colgroup" mode="post-process"/>
					</xsl:if>
					<xsl:choose>
						<xsl:when
							test="count(.//xhtml:tr[1]/xhtml:td) = count(.//xhtml:tr[1]/xhtml:td/xhtml:strong)">
							<thead>
								<xsl:apply-templates select=".//xhtml:tr[1]" mode="post-process"/>
							</thead>
							<tbody>
								<xsl:for-each select=".//xhtml:tr">
									<xsl:if test="position() != 1">
										<xsl:apply-templates select="." mode="post-process"/>
									</xsl:if>
								</xsl:for-each>
							</tbody>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="xhtml:tbody">
									<xsl:apply-templates select="xhtml:tbody " mode="post-process"/>
								</xsl:when>
								<xsl:otherwise>
									<tbody>
										<xsl:apply-templates select=" .//xhtml:tr"
											mode="post-process"/>
									</tbody>
								</xsl:otherwise>
							</xsl:choose>

						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	<xsl:template
		match="xhtml:section[@class='notice-category']/xhtml:section[1][@class='notice-type']"
		mode="post-process">
		<xsl:copy>
			<xsl:copy-of select="@id"/>
			<xsl:attribute name="class">
				<xsl:value-of select="@class"/>
				<xsl:text> first-child</xsl:text>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="xhtml:article[1][contains(@class,'full-width')]">
					<header class="full-width">
						<xsl:copy-of select="xhtml:header/*"/>
					</header>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="xhtml:header"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:for-each select="*[local-name() != 'header']">
				<xsl:apply-templates select="." mode="post-process"/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="xhtml:section[@class='notice-type']/xhtml:article[1]" mode="post-process">
		<xsl:copy>
			<xsl:attribute name="class">
				<xsl:value-of select="@class"/>
				<xsl:text> first-notice</xsl:text>
			</xsl:attribute>
			<xsl:apply-templates select="node()" mode="post-process"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="atom:feed">
		<!-- Force the HTML5 doctype. -->
		<xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;
    </xsl:text>
		<html data-initial-page="{$initial-page}" data-initial-counter="{$initial-counter}">
			<xsl:if test="$mourningBorder = 'true'">
				<xsl:attribute name="class" select="'mourning'"/>
			</xsl:if>
			<head>
				<title>
					<xsl:choose>
						<xsl:when test="$bespoke = 'true'">Bespoke Gazette</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$edition-name"/>
						</xsl:otherwise>
					</xsl:choose>
				</title>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
				<xsl:if test="$DEBUG = 'true'">
					<link href="../css/print-production.css" rel="stylesheet" type="text/css"/>
				</xsl:if>
			</head>
			<body>
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="$bespoke = 'true'">
							<xsl:text>bespoke</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>standard </xsl:text>
							<xsl:value-of select="$classreadyedition"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="$bookmarks = 'section'">
							<xsl:text> bookmark-sections</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text> bookmark-notices</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:call-template name="front-cover"/>
				<section class="two-columns">
					<xsl:variable name="notices">
						<xsl:for-each
							select="$taxonomy-notice-type/tax:notice-taxonomy/tax:notice-type">
							<xsl:sort select="@sort" data-type="number"/>
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</xsl:variable>
					<xsl:apply-templates select="$notices" mode="post-process"/>
				</section>
				<xsl:call-template name="adverts"/>
				<xsl:if test="$bespoke != 'true'">
					<xsl:call-template name="terms"/>
				</xsl:if>
				<xsl:call-template name="back-cover"/>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="*:notice-type">
		<xsl:variable name="code" select="@code"/>
		<xsl:variable name="this" select="."/>
		<xsl:variable name="sortByXPath" select="ancestor-or-self::*/@sortByXPath[1]"/>
		<xsl:if test="count($existing/*:code[text() = $code]) &gt;0">
			<xsl:variable name="class">
				<xsl:choose>
					<xsl:when test="@level='notice' and @name!='Other Notices'">
						<xsl:text>notice-type</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>notice-category</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="heading">
				<xsl:choose>
					<xsl:when test="@level='category' or @name='Other Notices'">
						<xsl:text>h1</xsl:text>
					</xsl:when>
					<xsl:when test="@level='section'">
						<xsl:text>h2</xsl:text>
					</xsl:when>
					<xsl:when test="@level='subsection'">
						<xsl:text>h3</xsl:text>
					</xsl:when>
					<xsl:when test="@level='notice'">
						<xsl:text>h4</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>p</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="@level='notice'">
					<xsl:variable name="first"
						select="$feed//atom:entry[*//*:notice-category-code[not(@secondary)]/text() = $code][1]"/>
					<xsl:choose>
						<xsl:when test="$first//*:notice-code = 2903">
							<section id="nt-{@code}" class="{$class}">
							    <xsl:if test="count($feed//atom:entry[*//*:notice-category-code/text() = $code and *//*:edition/text() = 'London']) &gt; 0">
    								<section id="ntl-{@code}" class="{$class}">
    									<xsl:variable name="edition">
    										<xsl:value-of select="$first/*//*:edition/text()"/>
    									</xsl:variable>
    									<header>
    										<xsl:element name="{$heading}">
    											<xsl:value-of select="@name"/>
    											<xsl:text>&nbsp;&ndash;&nbsp;London Edition</xsl:text>
    										</xsl:element>
    									</header>
    									<div class="legal-notice">
    										<!-- @TODO: Legal text for 2903 notices needs passed through by Java Layer or drawn from the notices -->
    										<xsl:for-each select="$legislationText//legislation[@edition='London']/p">
    											<p>
    												<xsl:value-of select="."/>
    											</p>
    										</xsl:for-each>
    									</div>
    									<xsl:if test="$feed//atom:entry[*//*:edition/text() = 'London']//*:div[@about='this:notifiableThing' and *:dl]">
    										<table class="wills-and-probate-2903-table">
    											<thead>
    												<tr>
    													<th class="name">Name of Deceased (Surname
    													first)</th>
    													<th class="address">Address, description and date of
    													death of Deceased</th>
    													<th class="represent">Names addresses and
    													descriptions of Persons to whom notices of claims
    													are to be given and names, in parentheses, of
    													Personal Representatives</th>
    													<th class="claimsDate">Date before which notice of
    													claims to be given</th>
    													<th class="noticeNum"/>
    												</tr>
    											</thead>
    											<tbody>
    												<xsl:for-each
    													select="$feed//atom:entry[*//*:notice-category-code/text() = $code and *//*:edition/text() = 'London']">
    													<xsl:sort
    													select=".//*:dd[@property = 'foaf:familyName' and @about='this:deceasedPerson']"/>
    													<xsl:call-template name="table_2903"/>
    												</xsl:for-each>
    											</tbody>
    										</table>
    									</xsl:if>
    								</section><!-- 
								<xsl:if test="$feed//atom:entry//*:div[not(@resource='this:deceasedPerson' and *:dl)] and $feed//atom:entry[*//*:edition/text() = 'London']">
									<section id="nt-{@code}" class="two-columns">
										<br/>
										<xsl:for-each select="$feed//atom:entry[*//*:notice-category-code/text() = $code and not(*//*:div[@resource='this:deceasedPerson']) and *//*:edition/text() = 'London']">
											<xsl:sort select=".//*:dd[@property = 'foaf:familyName' and @about='this:deceasedPerson']"/>
											<xsl:apply-templates/>
										</xsl:for-each>		
									</section>
								</xsl:if> -->
							</xsl:if>
							    <xsl:if test="count($feed//atom:entry[*//*:notice-category-code/text() = $code and *//*:edition/text() = 'Belfast']) &gt; 0">
								<section id="ntb1-{@code}" class="{$class}">
									<xsl:variable name="edition">
										<xsl:value-of select="$first/*//*:edition/text()"/>
									</xsl:variable>
									<br/>
									<header>
										<xsl:element name="{$heading}">
											<xsl:value-of select="@name"/>
											<xsl:text>&nbsp;&ndash;&nbsp;Belfast Edition</xsl:text>
										</xsl:element>
									</header>
									<div class="legal-notice">
										<!-- @TODO: Legal text for 2903 notices needs passed through by Java Layer or drawn from the notices -->
										<xsl:for-each select="$legislationText//legislation[@edition='Belfast']/p">
											<p>
												<xsl:value-of select="."/>
											</p>
										</xsl:for-each>
									</div>
									<xsl:if test="$feed//atom:entry[*//*:edition/text() = 'Belfast']//*:div[@about='this:notifiableThing' and *:dl]">
										<table class="wills-and-probate-2903-table">
											<thead>
												<tr>
													<th class="name">Name of Deceased (Surname
														first)</th>
													<th class="address">Address, description and date of
														death of Deceased</th>
													<th class="represent">Names addresses and
														descriptions of Persons to whom notices of claims
														are to be given and names, in parentheses, of
														Personal Representatives</th>
													<th class="claimsDate">Date before which notice of
														claims to be given</th>
													<th class="noticeNum"/>
												</tr>
											</thead>
											<tbody>
												<xsl:for-each
													select="$feed//atom:entry[*//*:notice-category-code/text() = $code and *//*:edition/text() = 'Belfast']">
													<xsl:sort
														select=".//*:dd[@property = 'foaf:familyName' and @about='this:deceasedPerson']"/>
													<xsl:call-template name="table_2903"/>
												</xsl:for-each>
											</tbody>
										</table>
									</xsl:if>
								</section>
								<xsl:if test="$feed//atom:entry[*//*:edition/text() = 'Belfast' and not(*//*:div[@about='this:notifiableThing' and *:dl])]">
									<section id="ntb2-{@code}" class="two-columns">
										<br/>
										<xsl:for-each select="$feed//atom:entry[*//*:notice-category-code/text() = $code and not(*//*:div[@about='this:notifiableThing' and *:dl]) and *//*:edition/text() = 'Belfast']">
											<xsl:sort select=".//*:dd[@property = 'foaf:familyName' and @about='this:deceasedPerson']"/>
											<xsl:apply-templates/>
										</xsl:for-each>		
									</section>
								</xsl:if>
							</xsl:if>
							    <xsl:if test="count($feed//atom:entry[*//*:notice-category-code/text() = $code and *//*:edition/text() = 'Edinburgh']) &gt; 0">
								<section id="nte1-{@code}" class="{$class}">
									<xsl:variable name="edition">
										<xsl:value-of select="$first/*//*:edition/text()"/>
									</xsl:variable>
									<br/>
									<header>
										<xsl:element name="{$heading}">
											<xsl:value-of select="@name"/>
											<xsl:text>&nbsp;&ndash;&nbsp;Edinburgh Edition</xsl:text>
										</xsl:element>
									</header>
									<div class="legal-notice">
										<!-- @TODO: Legal text for 2903 notices needs passed through by Java Layer or drawn from the notices -->
										<xsl:for-each select="$legislationText//legislation[@edition='Edinburgh']/p">
											<p>
												<xsl:value-of select="."/>
											</p>
										</xsl:for-each>
									</div>
									<xsl:if test="$feed//atom:entry[*//*:edition/text() = 'Edinburgh']//*:div[@about='this:notifiableThing' and *:dl]">						
										<table class="wills-and-probate-2903-table">
											<thead>
												<tr>
													<th class="name">Name of Deceased (Surname
														first)</th>
													<th class="address">Address, description and date of
														death of Deceased</th>
													<th class="represent">Names addresses and
														descriptions of Persons to whom notices of claims
														are to be given and names, in parentheses, of
														Personal Representatives</th>
													<th class="claimsDate">Date before which notice of
														claims to be given</th>
													<th class="noticeNum"/>
												</tr>
											</thead>
											<tbody>
    											<xsl:for-each
    												select="$feed//atom:entry[*//*:notice-category-code/text() = $code and *//*:edition/text() = 'Edinburgh']">
    												<xsl:sort
    													select=".//*:dd[@property = 'foaf:familyName' and @about='this:deceasedPerson']"/>
    												<xsl:call-template name="table_2903"/>
    											</xsl:for-each>
											</tbody>
										</table>
										</xsl:if>
								</section>
								<xsl:if test="$feed//atom:entry[*//*:edition/text() = 'Edinburgh' and not(*//*:div[@about='this:notifiableThing' and *:dl])]">
									<section id="nte2-{@code}" class="two-columns">
										<br/>
										<xsl:for-each select="$feed//atom:entry[*//*:notice-category-code/text() = $code and not(*//*:div[@about='this:notifiableThing' and *:dl]) and *//*:edition/text() = 'Edinburgh']">
											<xsl:sort select=".//*:dd[@property = 'foaf:familyName' and @about='this:deceasedPerson']"/>
											<xsl:apply-templates/>
										</xsl:for-each>		
									</section>
								</xsl:if>
							</xsl:if>
							<!-- 
							<xsl:if
								test="count($feed//atom:entry[*//*:notice-category-code/text() = $code and *//*:edition/text() != 'London']) &gt; 0">
								<xsl:if
									test="count($feed//atom:entry[*//*:notice-category-code/text() = $code and *//*:edition/text() ='London']) &gt; 0">
									<xsl:text disable-output-escaping="yes">&lt;/section&gt;&lt;section&gt;</xsl:text>
								</xsl:if>
								<section class="{$class}">
									<xsl:attribute name="class">
										<xsl:value-of select="$class"/>
										<xsl:if
											test="count($feed//atom:entry[*//*:notice-category-code/text() = $code and *//*:edition/text() ='London']) &gt; 0">
											<xsl:text> full-width</xsl:text>
										</xsl:if>
									</xsl:attribute>
									<xsl:for-each
										select="$feed//atom:entry[*//*:notice-category-code/text() = $code and *//*:edition/text() != 'London']">
										<xsl:sort
											select=".//*:dd[@property = 'foaf:familyName' and @about='this:deceasedPerson']"/>
										<xsl:apply-templates/>
									</xsl:for-each>
								</section>
							</xsl:if>
							-->
							</section>
						</xsl:when>
						<xsl:when test="$first//*:notice-code = 2904">
							<xsl:if
								test="count($feed//atom:entry[*//*:notice-category-code/text() = $code]) &gt; 0">
								<section id="nt-{@code}" class="{$class}">
									<header>
										<xsl:element name="{$heading}">
											<xsl:value-of select="@name"/>
										</xsl:element>
									</header>
									<div class="legal-notice">
										<xsl:variable name="edition">
											<xsl:value-of select="$first/*//*:edition/text()"/>
										</xsl:variable>
										<!-- @TODO: Legal text for 2903 notices needs passed through by Java Layer or drawn from the notices -->
										<xsl:for-each select="$legislationText//legislation[@edition=$edition]/p">
											<p>
												<xsl:value-of select="."/>
											</p>
										</xsl:for-each>
										<!--<p>Notice is hereby given pursuant to s. 27 of the Trustee
											Act 1925, that any person having a claim against or an
											interest in the estate of any of the deceased persons
											whose names and addresses are set out above is hereby
											required to send particulars in writing of his claim or
											interest to the person or persons whose names and
											addresses are set out above, and to send such
											particulars before the date specified in relation to
											that deceased person displayed above, after which date
											the personal representatives will distribute the estate
											among the persons entitled thereto having regard only to
											the claims and interests of which they have had notice
											and will not, as respects the property so distributed,
											be liable to any person of whose claim they shall not
											then have had notice</p>-->
									</div>
									<table class="wills-and-probate-2903-table">
										<thead>
											<tr>
												<th class="name">Name of Deceased (Surname
													first)</th>
												<th class="address">Address, description and date of
													death of Deceased</th>
												<th class="represent">Names addresses and
													descriptions of Persons to whom notices of claims
													are to be given and names, in parentheses, of
													Personal Representatives</th>
												<th class="claimsDate">Date before which notice of
													claims to be given</th>
												<th class="noticeNum"/>
											</tr>
										</thead>
										<tbody>
											<xsl:for-each
												select="$feed//atom:entry[*//*:notice-category-code/text() = $code]">
												<xsl:sort
													select=".//*:dd[@property = 'foaf:familyName' and @about='this:deceasedPerson']"/>
												<xsl:call-template name="table_2904"/>
											</xsl:for-each>											
										</tbody>
									</table>
								</section>
							</xsl:if>
							<!--<xsl:if
								test="count($feed//atom:entry[*//*:notice-category-code/text() = $code and *//*:edition/text() != 'London']) &gt; 0">
								<xsl:if
									test="count($feed//atom:entry[*//*:notice-category-code/text() = $code and *//*:edition/text() ='London']) &gt; 0">
									<xsl:text disable-output-escaping="yes">&lt;/section&gt;&lt;section&gt;</xsl:text>
								</xsl:if>
								<section class="{$class}">
									<xsl:attribute name="class">
										<xsl:value-of select="$class"/>
										<xsl:if
											test="count($feed//atom:entry[*//*:notice-category-code/text() = $code and *//*:edition/text() ='London']) &gt; 0">
											<xsl:text> full-width</xsl:text>
										</xsl:if>
									</xsl:attribute>
									<xsl:for-each
										select="$feed//atom:entry[*//*:notice-category-code/text() = $code and *//*:edition/text() != 'London']">
										<xsl:sort
											select=".//*:dd[@property = 'foaf:familyName' and @about='this:deceasedPerson']"/>
										<xsl:apply-templates/>
									</xsl:for-each>
								</section>
							</xsl:if>-->
						</xsl:when>
						<!-- Sorting drawn from Taxonomy File -->
						<xsl:when test="exists($sortByXPath)">
							<section id="nt-{@code}" class="{$class}">
								<header>
									<xsl:element name="{$heading}">
										<xsl:value-of select="@name"/>
									</xsl:element>
								</header>
								<xsl:for-each
									select="$feed//atom:entry[*//*:notice-category-code/text() = $code]">
									<xsl:sort select="saxon:evaluate($sortByXPath)[1]"/>
									<xsl:apply-templates/>
								</xsl:for-each>
							</section>
						</xsl:when>
						<xsl:otherwise>
							<section id="nt-{@code}" class="{$class}">
								<header>
									<xsl:element name="{$heading}">
										<xsl:value-of select="@name"/>
									</xsl:element>
								</header>
								<xsl:for-each
									select="$feed//atom:entry[*//*:notice-category-code/text() = $code]">
									<xsl:apply-templates/>
								</xsl:for-each>
							</section>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<!-- MH 10/08/2015 only display the heading if there will be notices appearing under it -->
					<xsl:variable name="taxonomyNotices" select = "$taxonomy-notice-type/tax:notice-taxonomy//tax:notice-type[@code = $code]//tax:notice-type[@level = 'notice']/@code"/>
					<xsl:variable name="codesForNotice" select="$existing/*:code"/>
					<xsl:variable name="showHeading" select="$codesForNotice = $taxonomyNotices"/>
						<xsl:if test="$showHeading">
						<section id="nt-{@code}" class="{$class}">
							<header>
							    <xsl:if test="@name = 'People'">
							        <xsl:attribute name="class">
							            <xsl:text>header-full-width</xsl:text>
							        </xsl:attribute>
							    </xsl:if>
								<xsl:element name="{$heading}">
									<xsl:value-of select="@name"/>
								</xsl:element>
							</header>
						<xsl:apply-templates/>
						</section>
						</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<xsl:template match="atom:entry | atom:content | *:div">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template
		match="f:* | atom:id | atom:link | atom:title | atom:updated | atom:openSearch | atom:author | m:gazette-metadata"/>
	<xsl:template match="*:dd" mode="table_2903">
		<xsl:variable name="attribute">
			<xsl:if test="$DEBUG = 'true'">
				<xsl:text>color:</xsl:text>
				<xsl:choose>
					<xsl:when test="@property='foaf:familyName'">
						<xsl:text>#f44a8c</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>#ED8B00</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>;font-style:bold;</xsl:text>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="property" select="@property"/>
		<xsl:for-each select="node()">
			<xsl:text> </xsl:text>
			<xsl:choose>
				<xsl:when test="self::text() and $property = 'foaf:familyName'">
					<span class="familyName">
						<xsl:value-of select="."/>
					</span>
				</xsl:when>
				<xsl:when test="self::text()">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<span style="{$attribute}">
						<xsl:value-of select="."/>
					</span>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:if
			test="$property = 'foaf:familyName' and ./following-sibling::*:dd[1][@about='this:deceasedPerson' and @property != 'personal-legal:dateOfDeath']">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>
	<xsl:template
		match="*:dd[@property=('person:alsoKnownAs','person:hasMaidenName','something:something')]"
		mode="table_2903">
		<xsl:if test="text() and text() != ''">
			<xsl:variable name="attribute">
				<xsl:if test="$DEBUG = 'true'">
					<xsl:text>color:</xsl:text>
					<xsl:choose>
						<xsl:when test="@property='person:alsoKnownAs'">
							<xsl:text>#90BD00</xsl:text>
						</xsl:when>
						<xsl:when test="@property='person:hasMaidenName'">
							<xsl:text>#41AAE6</xsl:text>
						</xsl:when>
						<xsl:when test="@property='something:something'">
							<xsl:text>yellow</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			</xsl:variable>
			<span style="{$attribute}">
				<xsl:variable name="first"
					select="./preceding-sibling::*:dd[1][@about='this:deceasedPerson' and not(@property = ('person:alsoKnownAs','person:hasMaidenName'))]"/>
				<xsl:if test="$first">
					<xsl:text> (</xsl:text>
				</xsl:if>
				<xsl:if test="./preceding-sibling::*:dt[1][@data-gazettes = 'custom-title']">
					<xsl:variable name="title"
						select="concat(replace(./preceding-sibling::*:dt[1],':',''),' ')"/>
					<span>
						<xsl:if test="$DEBUG = 'true'">
							<xsl:attribute name="style">font-weight:bold</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="lower-case(substring($title,1,1))"/>
						<xsl:value-of select="substring($title,2)"/>
					</span>
				</xsl:if>
				<xsl:value-of select="."/>
				<xsl:choose>
					<xsl:when test="./following-sibling::*:dd[1][@property != 'person:alsoKnownAs']">
						<xsl:text>)</xsl:text>
					</xsl:when>
					<xsl:when
						test="./following-sibling::*:dd[1][@about='this:deceasedPerson' and @property = 'personal-legal:dateOfDeath']">
						<xsl:text>)</xsl:text>
					</xsl:when>
					<xsl:when test="./following-sibling::*:dd[1][@about ='this:deceasedPerson']"/>
					<xsl:when
						test="./following-sibling::*:dd[1][not(@property = ('person:alsoKnownAs','person:hasMaidenName'))]">
						<xsl:text>)</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>)</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if
					test="./following-sibling::*:dd[1][@about='this:deceasedPerson' and @property != 'personal-legal:dateOfDeath'] ">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</span>
		</xsl:if>
	</xsl:template>
	<xsl:template match="*:dd[@property='personal-legal:dateOfDeath']" mode="table_2903"/>
	
	<xsl:template name="table_2903">
		<xsl:variable name="noticeid" select=".//*[@property='gaz:hasNoticeID']"/>
		<!-- START -->
		<xsl:if test=".//*:p[@class='retraction']">
			<tr>
				<td class="substitution" colspan="5">
					<xsl:apply-templates select=".//*:p[@class='retraction']"
						mode="substitution_2903"/>
				</td>
			</tr>
		</xsl:if>
		<tr>
			<td>
				<!-- The familyName is set to uppercase by the css. -->
				<span class="familyName">
					<xsl:value-of select=".//*:dd[@property='foaf:familyName' and @about='this:deceasedPerson']"/>
				</span>
				<xsl:if test=".//*:dd[@property='person:postNominal' and @about='this:deceasedPerson']">
				    <xsl:text> </xsl:text>
					<xsl:value-of select=".//*:dd[@property='person:postNominal' and @about='this:deceasedPerson']"/>
				</xsl:if>
				<xsl:if test=".//*:dd[@property='person:honour' and @about='this:deceasedPerson']">
				    <xsl:text> </xsl:text>
					<xsl:value-of select=".//*:dd[@property='person:honour' and @about='this:deceasedPerson']"/>
				</xsl:if>
				<xsl:text>, </xsl:text>
				<xsl:if test=".//*:dd[@property='person:rank' and @about='this:deceasedPerson']">
					<xsl:value-of select=".//*:dd[@property='person:rank' and @about='this:deceasedPerson']"/>
				</xsl:if>
				<xsl:text> </xsl:text>
				<xsl:if test=".//*:dd[@property='foaf:title' and @about='this:deceasedPerson']">
					<xsl:value-of select=".//*:dd[@property='foaf:title' and @about='this:deceasedPerson']"/>
				</xsl:if>
				<xsl:text> </xsl:text>
				<xsl:value-of select=".//*:dd[@property='foaf:firstName' and @about='this:deceasedPerson']"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select=".//*:dd[@property='foaf:givenName' and @about='this:deceasedPerson']"/>
				<xsl:if test=".//*:dd[@property='person:alsoKnownAs' and @about='this:deceasedPerson']/node()">
					<xsl:text> (</xsl:text>
					<xsl:value-of select=".//*:dd[@property='person:alsoKnownAs' and @about='this:deceasedPerson']"/>
					<xsl:text>)</xsl:text>
				</xsl:if>
				<xsl:if test=".//*:p[@class='substitution']">
					<xsl:apply-templates select=".//*:p[@class='substitution']" mode="substitution_2903"/>
				</xsl:if>
				<!-- @TODO, check this, can there be more than 1? -->
				<!--	<xsl:if test=".//*:dd[@property='person:alsoKnownAs' and @about='this:deceasedPerson'] != ''">
					<xsl:text> </xsl:text>
					<xsl:if
						test="not(contains(.//*:dd[@property='person:alsoKnownAs' and @about='this:deceasedPerson'],'otherwise') or contains(.//*:dd[@property='person:alsoKnownAs' and @about='this:deceasedPerson'],'also known as'))">
						<xsl:text>otherwise </xsl:text>
					</xsl:if>
					<xsl:value-of select=".//*:dd[@property='person:alsoKnownAs' and @about='this:deceasedPerson']"/>
				</xsl:if>-->
				<!-- @TODO, Maiden name? -->
			</td>
			<td>
				<!-- Find all the different @about contents which relate to an address of the deceased. -->
				<xsl:variable name="addressSections"
					select=".//*[@property='person:hasAddress' and @about='this:deceasedPerson']"/>
				<xsl:variable name="addressCell">
					<xsl:choose>
						<xsl:when test="count(.//*:dd[@about=$addressSections[1]/@resource]) &gt; 0">
							
							<xsl:for-each select=".//*:dd[@about=$addressSections[1]/@resource and node()]">
								<xsl:if test="position() != 1">
									<xsl:text>, </xsl:text>
								</xsl:if>
								<xsl:value-of select="."/>
							</xsl:for-each>
							<xsl:if test="count($addressSections/@resource) &gt; 1">
								<xsl:for-each select="$addressSections">
									<xsl:variable name="resource" select="./@resource"/>
									<xsl:if test="position() != 1">
										<xsl:for-each select=".//*:dd[@about=$resource]">
											<xsl:if test="position() != 1">
												<xsl:text>, </xsl:text>
											</xsl:if>
											<xsl:value-of select="."/>
										</xsl:for-each>
									</xsl:if>
								</xsl:for-each>
							</xsl:if>
						</xsl:when>
						<xsl:when test=".//*:dd[@about='this:addressOfDeceased-address-1']">
							<xsl:value-of
								select=".//*:dd[@about='this:addressOfDeceased-address-1']"/>
						</xsl:when>
						<xsl:when test="count($addressSections/@resource) = 0">
							<xsl:value-of
								select=".//*:dd[@about='this:addressOfDeceased-address-1']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select=".//*:dd[@about=$addressSections[1]/@resource]"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>. </xsl:text>
				    <xsl:if test=".//*:div[@property='person:hasPreviousAddress']">				        
				        <xsl:for-each select=".//*:div[@property='person:hasPreviousAddress']">
				            <xsl:for-each select="*:dl/*:dd[node()]">
        				        <xsl:if test="position() != 1">
        				            <xsl:text>, </xsl:text>
        				        </xsl:if>
        				        <xsl:value-of select="."/>
				                <xsl:if test="position() = last()">
				                    <xsl:text>. </xsl:text>
				                </xsl:if>
				            </xsl:for-each>
    				    </xsl:for-each>
				    </xsl:if>
					<xsl:if test=".//*:dd[@property='person:jobTitle']">
						<xsl:value-of select=".//*:dd[@property='person:jobTitle']"/>
						<xsl:text>. </xsl:text>
					</xsl:if>
				</xsl:variable>
				<xsl:value-of select="replace($addressCell,'\.\.','.')"/>
				<xsl:choose>
					<!-- Date Range -->
					<xsl:when
						test=".//*:span[@property='personal-legal:startDateOfDeath']/. and .//*:span[@property='personal-legal:endDateOfDeath']">
						<xsl:text>Between </xsl:text>
						<xsl:if test=".//*:span[@property='personal-legal:startDateOfDeath' and @content]">
							<xsl:value-of
							select="gfn:safe-date(.//*:span[@property='personal-legal:startDateOfDeath']/@content)"/>
						</xsl:if>
						<xsl:if test=".//*:span[@property='personal-legal:startDateOfDeath' and not(@content)]">
							<xsl:value-of
								select="gfn:safe-date(.//*:span[@property='personal-legal:startDateOfDeath']/text())"/>
						</xsl:if>
						<xsl:text> and </xsl:text>
						<xsl:if test=".//*:span[@property='personal-legal:endDateOfDeath' and @content]">
							<xsl:value-of
								select="gfn:safe-date(.//*:span[@property='personal-legal:endDateOfDeath']/@content)"/>
						</xsl:if>
						<xsl:if test=".//*:span[@property='personal-legal:endDateOfDeath' and not(@content)]">
							<xsl:value-of
								select="gfn:safe-date(.//*:span[@property='personal-legal:endDateOfDeath']/text())"/>
						</xsl:if>
					</xsl:when>
					<!-- Exact Date -->
					<xsl:when test=".//*:dd[@property='personal-legal:dateOfDeath']/@content">
						<xsl:value-of
							select="gfn:safe-date(.//*:dd[@property='personal-legal:dateOfDeath']/@content)"
						/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="gfn:safe-date(.//*:dd[@property='personal-legal:dateOfDeath']/text())"
						/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="count(.//*:dd[contains(@about,'this:estateExecutor')]) &gt; 1 or count(.//*:dd[@about='this:addressOfExecutor-1']) &gt; 1">
						
						<xsl:if test=".//*:dd[@about='this:estateExecutor' and @property='foaf:name']">
							<xsl:value-of select=".//*:dd[@about='this:estateExecutor' and @property='foaf:name']"/>								
						</xsl:if>
						<xsl:if test=".//*:dd[@about='this:estateExecutor' and @property='foaf:name'] and .//*:dd[@about='this:estateExecutor' and @property='foaf:firstName']">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:if test=".//*:dd[@about='this:estateExecutor' and @property='foaf:firstName']">								
							<xsl:value-of
								select="concat(.//*:dd[@about='this:estateExecutor' and @property='foaf:firstName'],' ')"/>
						</xsl:if>
						<xsl:if
							test=".//*:dd[@about='this:estateExecutor' and @property='foaf:givenName']">
							<xsl:value-of
								select="concat(.//*:dd[@about='this:estateExecutor' and @property='foaf:givenName'],' ')"/>
						</xsl:if>
						<xsl:value-of
							select=".//*:dd[@about='this:estateExecutor' and @property='foaf:familyName']"/>	
						<xsl:if test=".//*:dd[@property='person:postNominal' and @about='this:estateExecutor']">
							<xsl:text> </xsl:text>
							<xsl:value-of select=".//*:dd[@property='person:postNominal' and @about='this:estateExecutor']"/>
						</xsl:if>
						<xsl:if test=".//*:dd[@property='person:rank' and @about='this:estateExecutor']">
							<xsl:text> </xsl:text>
							<xsl:value-of select=".//*:dd[@property='person:rank' and @about='this:estateExecutor']"/>
						</xsl:if>
						<xsl:if test=".//*:dd[@property='foaf:title' and @about='this:estateExecutor']">
							<xsl:text> </xsl:text>		
							<xsl:value-of select=".//*:dd[@property='foaf:title' and @about='this:estateExecutor']"/>
						</xsl:if>
					    
					    <!-- Support for numbered webform executors -->
					    <xsl:if test=".//*:dd[@about='this:estateExecutor-1' and @property='foaf:name']">
					        <xsl:value-of select=".//*:dd[@about='this:estateExecutor-1' and @property='foaf:name']"/>								
					    </xsl:if>
					    <xsl:if test=".//*:dd[@about='this:estateExecutor-1' and @property='foaf:name'] and .//*:dd[@about='this:estateExecutor-1' and @property='foaf:firstName']">
					        <xsl:text>, </xsl:text>
					    </xsl:if>
					    <xsl:if test=".//*:dd[@about='this:estateExecutor-1' and @property='foaf:firstName']">								
					        <xsl:value-of select="concat(.//*:dd[@about='this:estateExecutor-1' and @property='foaf:firstName'],' ')"/>
					    </xsl:if>
					    <xsl:if test=".//*:dd[@about='this:estateExecutor-1' and @property='foaf:givenName']">
					        <xsl:value-of select="concat(.//*:dd[@about='this:estateExecutor-1' and @property='foaf:givenName'],' ')"/>
					    </xsl:if>
					    <xsl:value-of select=".//*:dd[@about='this:estateExecutor-1' and @property='foaf:familyName']"/>	
					    					    
						<xsl:text>, </xsl:text>
						
						<xsl:for-each select=".//*:dd[@about='this:addressOfExecutor-1' and node()]">
							<xsl:if test="position() != 1">
								<xsl:text>, </xsl:text>
							</xsl:if>
							<xsl:value-of select="."/>
						</xsl:for-each>
						<xsl:for-each select=".//*:dd[@about='this:addressOfExecutor' and node()]">
							<xsl:if test="position() != 1">
								<xsl:text>, </xsl:text>
							</xsl:if>
							<xsl:value-of select="."/>
						</xsl:for-each>
						<xsl:text>. </xsl:text>		
					    
					    <xsl:if test=".//*:dd[@about='this:estateExecutor-2']">
					        <xsl:text>(</xsl:text>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-2' and @property='foaf:name']">
					            <xsl:value-of select=".//*:dd[@about='this:estateExecutor-2' and @property='foaf:name']"/>								
					        </xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-2' and @property='foaf:name'] and .//*:dd[@about='this:estateExecutor-2' and @property='foaf:firstName']">
					            <xsl:text>, </xsl:text>
					        </xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-2' and @property='foaf:firstName']">								
					            <xsl:value-of select="concat(.//*:dd[@about='this:estateExecutor-2' and @property='foaf:firstName'],' ')"/>
					        </xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-2' and @property='foaf:givenName']">
					            <xsl:value-of select="concat(.//*:dd[@about='this:estateExecutor-2' and @property='foaf:givenName'],' ')"/>
					        </xsl:if>
					    	<xsl:if test=".//*:dd[@about='this:estateExecutor-2' and @property='foaf:familyName']">
					        	<xsl:value-of select=".//*:dd[@about='this:estateExecutor-2' and @property='foaf:familyName']"/>
					    		<xsl:text>, </xsl:text>
					    	</xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-3' and @property='foaf:name']">
					            <xsl:value-of select=".//*:dd[@about='this:estateExecutor-3' and @property='foaf:name']"/>								
					        </xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-3' and @property='foaf:name'] and .//*:dd[@about='this:estateExecutor-3' and @property='foaf:firstName']">
					            <xsl:text>, </xsl:text>
					        </xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-3' and @property='foaf:firstName']">								
					            <xsl:value-of select="concat(.//*:dd[@about='this:estateExecutor-3' and @property='foaf:firstName'],' ')"/>
					        </xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-3' and @property='foaf:givenName']">
					            <xsl:value-of select="concat(.//*:dd[@about='this:estateExecutor-3' and @property='foaf:givenName'],' ')"/>
					        </xsl:if>
					    	<xsl:if test=".//*:dd[@about='this:estateExecutor-3' and @property='foaf:familyName']">
					    		<xsl:value-of select=".//*:dd[@about='this:estateExecutor-3' and @property='foaf:familyName']"/>
					    		<xsl:text>, </xsl:text>
					    	</xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-4' and @property='foaf:name']">
					            <xsl:value-of select=".//*:dd[@about='this:estateExecutor-4' and @property='foaf:name']"/>								
					        </xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-4' and @property='foaf:name'] and .//*:dd[@about='this:estateExecutor-4' and @property='foaf:firstName']">
					            <xsl:text>, </xsl:text>
					        </xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-4' and @property='foaf:firstName']">								
					            <xsl:value-of select="concat(.//*:dd[@about='this:estateExecutor-4' and @property='foaf:firstName'],' ')"/>
					        </xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-4' and @property='foaf:givenName']">
					            <xsl:value-of select="concat(.//*:dd[@about='this:estateExecutor-4' and @property='foaf:givenName'],' ')"/>
					        </xsl:if>
					    	<xsl:if test=".//*:dd[@about='this:estateExecutor-4' and @property='foaf:familyName']">
					    		<xsl:value-of select=".//*:dd[@about='this:estateExecutor-4' and @property='foaf:familyName']"/>
					    		<xsl:text>, </xsl:text>
					    	</xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-5' and @property='foaf:name']">
					            <xsl:value-of select=".//*:dd[@about='this:estateExecutor-5' and @property='foaf:name']"/>								
					        </xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-5' and @property='foaf:name'] and .//*:dd[@about='this:estateExecutor-5' and @property='foaf:firstName']">
					            <xsl:text>, </xsl:text>
					        </xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-5' and @property='foaf:firstName']">								
					            <xsl:value-of select="concat(.//*:dd[@about='this:estateExecutor-5' and @property='foaf:firstName'],' ')"/>
					        </xsl:if>
					        <xsl:if test=".//*:dd[@about='this:estateExecutor-5' and @property='foaf:givenName']">
					            <xsl:value-of select="concat(.//*:dd[@about='this:estateExecutor-5' and @property='foaf:givenName'],' ')"/>
					        </xsl:if>
					    	<xsl:if test=".//*:dd[@about='this:estateExecutor-5' and @property='foaf:familyName']">
					    		<xsl:value-of select=".//*:dd[@about='this:estateExecutor-5' and @property='foaf:familyName']"/>
					    		<xsl:text>, </xsl:text>
					    	</xsl:if><xsl:text>)</xsl:text>
					    </xsl:if>
					    
					    
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select=".//*:dd[@about='this:estateExecutor']"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when
						test="exists(.//*:dd[@property='personal-legal:hasClaimDeadline'][1]/@content)">
						<xsl:value-of
							select="gfn:safe-date(.//*:dd[@property='personal-legal:hasClaimDeadline'][1]/@content)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="gfn:safe-date(.//*:dl[@class='metadata']/*:dd[@property='personal-legal:hasClaimDeadline'][1]/text())" />
					</xsl:otherwise>
				</xsl:choose>	
			</td>
			<td>
				<xsl:text>(</xsl:text>
				<span property="gaz:hasNoticeID">
					<xsl:value-of select="gfn:short-notice-id($noticeid)"/>
				</span>
				<xsl:text>)</xsl:text>
			</td>
		</tr>		
		<!-- END -->
	</xsl:template>
	
	<xsl:template name="table_2904">
		<xsl:variable name="noticeid" select=".//*[@property='gaz:hasNoticeID']"/>
		<!-- START -->
		<xsl:if test=".//*:p[@class='retraction']">
			<tr>
				<td class="substitution" colspan="5">
					<xsl:apply-templates select=".//*:p[@class='retraction']"
						mode="substitution_2903"/>
				</td>
			</tr>
		</xsl:if>
		<tr>
			<td>
				<!-- The familyName is set to uppercase by the css. -->
				<span class="familyName">
					<xsl:value-of select=".//*:dd[@property='foaf:familyName' and @about='this:deceasedPerson']"/>
				</span>
				<xsl:text> </xsl:text>
				<xsl:if test=".//*:dd[@property='person:postNominal' and @about='this:deceasedPerson']">
					<xsl:value-of select=".//*:dd[@property='person:postNominal' and @about='this:deceasedPerson']"/>
				</xsl:if>
				<xsl:text> </xsl:text>
				<xsl:if test=".//*:dd[@property='person:honour' and @about='this:deceasedPerson']">
					<xsl:value-of select=".//*:dd[@property='person:honour' and @about='this:deceasedPerson']"/>
				</xsl:if>
				<xsl:text>, </xsl:text>
				<xsl:if test=".//*:dd[@property='person:rank' and @about='this:deceasedPerson']">
					<xsl:value-of select=".//*:dd[@property='person:rank' and @about='this:deceasedPerson']"/>
				</xsl:if>
				<xsl:text> </xsl:text>
				<xsl:if test=".//*:dd[@property='foaf:title' and @about='this:deceasedPerson']">
					<xsl:value-of select=".//*:dd[@property='foaf:title' and @about='this:deceasedPerson']"/>
				</xsl:if>
				<xsl:text> </xsl:text>
				<xsl:value-of select=".//*:dd[@property='foaf:firstName' and @about='this:deceasedPerson']"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select=".//*:dd[@property='foaf:givenName' and @about='this:deceasedPerson']"/>
				<xsl:if test=".//*:dd[@property='foaf:familyName' and @about='this:deceasedPerson']/following-sibling::*:dd[@property='person:alsoKnownAs' and @about='this:deceasedPerson']/node()">
					<xsl:text> (</xsl:text>
					<xsl:value-of select=".//*:dd[@property='person:alsoKnownAs' and @about='this:deceasedPerson']"/>
					<xsl:text>)</xsl:text>
				</xsl:if>
				<xsl:if test=".//*:p[@class='substitution']">
					<xsl:apply-templates select=".//*:p[@class='substitution']" mode="substitution_2903"/>
				</xsl:if>
				<!-- @TODO, check this, can there be more than 1? -->
				<!--	<xsl:if test=".//*:dd[@property='person:alsoKnownAs' and @about='this:deceasedPerson'] != ''">
				<xsl:text> </xsl:text>
				<xsl:if
					test="not(contains(.//*:dd[@property='person:alsoKnownAs' and @about='this:deceasedPerson'],'otherwise') or contains(.//*:dd[@property='person:alsoKnownAs' and @about='this:deceasedPerson'],'also known as'))">
					<xsl:text>otherwise </xsl:text>
				</xsl:if>
				<xsl:value-of select=".//*:dd[@property='person:alsoKnownAs' and @about='this:deceasedPerson']"/>
			</xsl:if>-->
				<!-- @TODO, Maiden name? -->
			</td>
			<td>
				<!-- Address no longer required in 2904 table - Wissam Asfahani 03/12/2015 -->
				<!-- Address now required again in 2904 table - Wissam Asfahani 23/02/2016 -->
				<!-- Find all the different @about contents which relate to an address of the deceased. -->
			    <xsl:if test=".//*[@property='person:hasAddress' and @about='this:deceasedPerson']">
    				<xsl:variable name="addressSections"
    					select=".//*[@property='person:hasAddress' and @about='this:deceasedPerson']"/>
    				<xsl:variable name="addressCell">
    					<xsl:choose>
    						<xsl:when test="count(.//*:dd[@about=$addressSections[1]/@resource]) &gt; 0">    							
    							<xsl:for-each select=".//*:dd[@about=$addressSections[1]/@resource and node()]">
    								<xsl:if test="position() != 1">
    									<xsl:text>, </xsl:text>
    								</xsl:if>
    								<xsl:value-of select="."/>
    							</xsl:for-each>
    							<xsl:if test="count($addressSections/@resource) &gt; 1">
    								<xsl:for-each select="$addressSections">
    									<xsl:variable name="resource" select="./@resource"/>
    									<xsl:if test="position() != 1">
    										<xsl:for-each select=".//*:dd[@about=$resource]">
    											<xsl:if test="position() != 1">
    												<xsl:text>, </xsl:text>
    											</xsl:if>
    											<xsl:value-of select="."/>
    										</xsl:for-each>
    									</xsl:if>
    								</xsl:for-each>
    							</xsl:if>
    						</xsl:when>
    						<xsl:when test=".//*:dd[@about='this:addressOfDeceased-address-1']">
    							<xsl:value-of
    								select=".//*:dd[@about='this:addressOfDeceased-address-1']"/>
    						</xsl:when>
    						<xsl:when test="count($addressSections/@resource) = 0">
    							<xsl:value-of
    								select=".//*:dd[@about='this:addressOfDeceased-address-1']"/>
    						</xsl:when>
    						<xsl:otherwise>
    							<xsl:value-of select=".//*:dd[@about=$addressSections[1]/@resource]"/>
    						</xsl:otherwise>
    					</xsl:choose>
    					<xsl:if test=".//*[@property='person:hasAddress' and @about='this:deceasedPerson']">
    						<xsl:text>. </xsl:text>
    					</xsl:if>					
    				</xsl:variable>
    				<xsl:value-of select="replace($addressCell,'\.\.','.')"/>
			    </xsl:if>
			    <xsl:if test=".//*:dd[@property='person:jobTitle']">
			        <xsl:value-of select=".//*:dd[@property='person:jobTitle']"/>
			        <xsl:text>. </xsl:text>
			    </xsl:if>
				<xsl:choose>
					<!-- Date Range -->
					<xsl:when
						test=".//*:span[@property='personal-legal:startDateOfDeath']/. and .//*:span[@property='personal-legal:endDateOfDeath']">
						<xsl:text>Between </xsl:text>
						<xsl:if test=".//*:span[@property='personal-legal:startDateOfDeath' and @content]">
							<xsl:value-of
								select="gfn:safe-date(.//*:span[@property='personal-legal:startDateOfDeath']/@content)"/>
						</xsl:if>
						<xsl:if test=".//*:span[@property='personal-legal:startDateOfDeath' and not(@content)]">
							<xsl:value-of
								select="gfn:safe-date(.//*:span[@property='personal-legal:startDateOfDeath']/text())"/>
						</xsl:if>
						<xsl:text> and </xsl:text>
						<xsl:if test=".//*:span[@property='personal-legal:endDateOfDeath' and @content]">
							<xsl:value-of
								select="gfn:safe-date(.//*:span[@property='personal-legal:endDateOfDeath']/@content)"/>
						</xsl:if>
						<xsl:if test=".//*:span[@property='personal-legal:endDateOfDeath' and not(@content)]">
							<xsl:value-of
								select="gfn:safe-date(.//*:span[@property='personal-legal:endDateOfDeath']/text())"/>
						</xsl:if>
					</xsl:when>
					<!-- Exact Date -->
					<xsl:when test=".//*:dd[@property='personal-legal:dateOfDeath']/@content">
						<xsl:value-of
							select="gfn:safe-date(.//*:dd[@property='personal-legal:dateOfDeath']/@content)"
						/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="gfn:safe-date(.//*:dd[@property='personal-legal:dateOfDeath']/text())"
						/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="count(.//*:dd[@about='this:estateExecutor']) &gt; 1 or count(.//*:dd[@about='this:addressOfExecutor-1']) &gt; 1">
						
						<xsl:if test=".//*:dd[@about='this:estateExecutor' and @property='foaf:name']">
							<xsl:value-of select=".//*:dd[@about='this:estateExecutor' and @property='foaf:name']"/>								
						</xsl:if>
						
						<xsl:if test=".//*:dd[@about='this:estateExecutor' and @property='foaf:name'] and .//*:dd[@about='this:estateExecutor' and @property='foaf:firstName']">
							<xsl:text>, </xsl:text>
						</xsl:if>
						
						<xsl:if test=".//*:dd[@about='this:estateExecutor' and @property='foaf:firstName']">								
							<xsl:value-of
								select="concat(.//*:dd[@about='this:estateExecutor' and @property='foaf:firstName'],' ')"/>
						</xsl:if>
						
						<xsl:if
							test=".//*:dd[@about='this:estateExecutor' and @property='foaf:givenName']">
							<xsl:value-of
								select="concat(.//*:dd[@about='this:estateExecutor' and @property='foaf:givenName'],' ')"/>
						</xsl:if>
						
						<xsl:value-of
							select=".//*:dd[@about='this:estateExecutor' and @property='foaf:familyName']"/>	
						
						<xsl:if test=".//*:dd[@property='person:postNominal' and @about='this:estateExecutor']">
							<xsl:text> </xsl:text>
							<xsl:value-of select=".//*:dd[@property='person:postNominal' and @about='this:estateExecutor']"/>
						</xsl:if>
						
						<xsl:if test=".//*:dd[@property='person:rank' and @about='this:estateExecutor']">
							<xsl:text> </xsl:text>
							<xsl:value-of select=".//*:dd[@property='person:rank' and @about='this:estateExecutor']"/>
						</xsl:if>
						
						<xsl:if test=".//*:dd[@property='foaf:title' and @about='this:estateExecutor']">
							<xsl:text> </xsl:text>		
							<xsl:value-of select=".//*:dd[@property='foaf:title' and @about='this:estateExecutor']"/>
						</xsl:if>
						
						<xsl:text>, </xsl:text>		
						
						<xsl:for-each select=".//*:dd[@about='this:addressOfExecutor-1' and node()]">
							<xsl:if test="position() != 1">
								<xsl:text>, </xsl:text>
							</xsl:if>
							<xsl:value-of select="."/>
						</xsl:for-each>
						<xsl:for-each select=".//*:dd[@about='this:addressOfExecutor' and node()]">
							<xsl:if test="position() != 1">
								<xsl:text>, </xsl:text>
							</xsl:if>
							<xsl:value-of select="."/>
						</xsl:for-each>
						<xsl:text>. </xsl:text>							
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select=".//*:dd[@about='this:estateExecutor']"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when
						test="exists(.//*:dd[@property='personal-legal:hasClaimDeadline'][1]/@content)">
						<xsl:value-of
							select="gfn:safe-date(.//*:dd[@property='personal-legal:hasClaimDeadline'][1]/@content)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="gfn:safe-date(.//*:dl[@class='metadata']/*:dd[@property='personal-legal:hasClaimDeadline'][1]/text())" />
					</xsl:otherwise>
				</xsl:choose>	
			</td>
			<td>
				<xsl:text>(</xsl:text>
				<span property="gaz:hasNoticeID">
					<xsl:value-of select="gfn:short-notice-id($noticeid)"/>
				</span>
				<xsl:text>)</xsl:text>
			</td>
		</tr>
		<!-- END -->
	</xsl:template>
	
	<xsl:template match="@*|node()" mode="substitution_2903">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="substitution_2903"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="*:p" mode="substitution_2903" priority="1">
		<xsl:apply-templates mode="substitution_2903"/>
	</xsl:template>
	<xsl:template match="*:article">
		<xsl:variable name="noticeid" select="descendant::*[@property = 'gaz:hasNoticeID'][1]"/>
		<article>
			<xsl:attribute name="class">
				<xsl:text>full-notice </xsl:text>
				<xsl:value-of
					select="concat('full-notice-',.//*:dd[@property='gaz:hasNoticeCode'][1])"/>
				<xsl:text> </xsl:text>
				<xsl:value-of
					select="concat('full-notice-',substring(.//*:dd[@property='gaz:hasNoticeCode'][1],1,2))"/>
				<xsl:choose>
					<xsl:when test=".//*:div[@class='content' and @data-gazettes-colspan='2']">
						<xsl:text> full-width</xsl:text>
					</xsl:when>
					<xsl:when
						test=".//*:div[@class='content']//*[@data-original-width] and not(substring(.//*:dd[@property='gaz:hasNoticeCode'][1],1,2) = ('24','25','26','27','28','29'))">
						<xsl:variable name="widths" as="xs:integer*">
							<xsl:for-each
								select=".//*:div[@class='content']//*[@data-original-width]">
								<xsl:variable name="this"
									select="replace(@data-original-width,'pt','')"/>
								<xsl:if test="$this castable as xs:integer">
									<xsl:value-of select="$this"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="max($widths) &gt; 383">
								<xsl:text> full-width</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text> single-width</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> single-width</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<div class="content">
				<span property="gaz:hasNoticeID" class="metadata">
					<xsl:value-of select="$noticeid"/>
				</span>
				<xsl:variable name="noticeContent">
					<xsl:apply-templates select=".//*:div[@class='content']/*" mode="notice"/>
				</xsl:variable>
				<!-- Look for the last div > p and put a span in it for the notice id -->
				<!-- otherwise last div and add a paragraph for the notice id -->
				<!-- otherwise after the last node and add a paragraph for the notice id -->
				<xsl:for-each select="$noticeContent/*">
					<xsl:choose>
						<xsl:when test="position() = last()">
							<xsl:choose>
								<xsl:when test="local-name(.) = 'div'">
									<xsl:for-each select="*">
										<xsl:choose>
											<xsl:when test="position() = last()">
												<xsl:choose>
												<xsl:when test="name(.) = 'p'">
												<p>
												<xsl:copy-of select="@*"/>
												<xsl:copy-of select="node()"/>
												<span class="noticeID">
												<xsl:text>(</xsl:text>
												<xsl:value-of
												select="gfn:short-notice-id($noticeid)"/>
												<xsl:text>)</xsl:text>
												</span>
												</p>
												</xsl:when>
												<xsl:otherwise>
												<xsl:copy-of select="."/>
												<p class="noticeID">
												<xsl:text>(</xsl:text>
												<xsl:value-of
												select="gfn:short-notice-id($noticeid)"/>
												<xsl:text>)</xsl:text>
												</p>
												</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise>
												<xsl:copy-of select="."/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="local-name(.) = 'p'">
									<p>
										<xsl:copy-of select="@*"/>
										<xsl:copy-of select="node()"/>
										<span class="noticeID">
											<xsl:text>(</xsl:text>
											<xsl:value-of select="gfn:short-notice-id($noticeid)"/>
											<xsl:text>)</xsl:text>
										</span>
									</p>
								</xsl:when>
								<xsl:otherwise>
									<xsl:copy-of select="."/>
									<p class="noticeID">
										<xsl:text>(</xsl:text>
										<xsl:value-of select="gfn:short-notice-id($noticeid)"/>
										<xsl:text>)</xsl:text>
									</p>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</div>
			<!--footer>
				<p>
					<xsl:text>(</xsl:text>
					<xsl:value-of select=""/>
					<xsl:text>)</xsl:text>
				</p>
			</footer-->
		</article>
	</xsl:template>
	<!-- Generic node pass-trough mechanism with tweaks for tables, table cells and images. -->
	<xsl:template match="*" mode="notice">
		<xsl:choose>
			<xsl:when test="name() = 'table'">
				<table>
					<xsl:if test="@cols">
						<xsl:attribute name="cols">
							<xsl:value-of select="@cols"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@data-width">
						<xsl:attribute name="width">
							<xsl:choose>
								<xsl:when test="matches(@data-width,'pt')"><xsl:variable
										name="numeric"
										select="number(replace(@data-width,'pt','')) * 0.352777778"
										/><xsl:value-of select="format-number($numeric,'###.##')"
									/>mm</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@data-width"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates mode="notice"/>
				</table>
			</xsl:when>
			<xsl:when test="name() = 'td'">
				<td>
					<xsl:if test="@colspan">
						<xsl:attribute name="colspan">
							<xsl:value-of select="@colspan"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@rowspan">
						<xsl:attribute name="rowspan">
							<xsl:value-of select="@rowspan"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@class">
						<xsl:attribute name="class">
							<xsl:value-of select="@class"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="matches(.,'\d*/\d*/[a-zA-Z0-9]*')">
							<xsl:for-each select="tokenize(.,'/')">
								<xsl:value-of select="."/>
								<xsl:if test="position() != last()">
									<xsl:text>/&#x00AD;</xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates mode="notice"/>
						</xsl:otherwise>
					</xsl:choose>
				</td>
			</xsl:when>
			<xsl:when test="name() = 'img'">
				<img>
					<xsl:if test="@width">
						<xsl:attribute name="width">
							<xsl:choose>
								<xsl:when test="matches(@width,'pt')"><xsl:variable name="numeric"
										select="number(replace(@width,'pt','')) * 0.352777778"
										/><xsl:value-of select="format-number($numeric,'###.##')"
									/>mm</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@width"/>
									<xsl:text>px</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@Width">
						<xsl:attribute name="width">
							<xsl:choose>
								<xsl:when test="matches(@Width,'pt')"><xsl:variable name="numeric"
										select="number(replace(@Width,'pt','')) * 0.352777778"
										/><xsl:value-of select="format-number($numeric,'###.##')"
									/>mm</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@Width"/>
									<xsl:text>px</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@height">
						<xsl:attribute name="height">
							<xsl:choose>
								<xsl:when test="matches(@height,'pt')"><xsl:variable name="numeric"
										select="number(replace(@height,'pt','')) * 0.352777778"
										/><xsl:value-of select="format-number($numeric,'###.##')"
									/>mm</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@height"/>
									<xsl:text>px</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@Height">
						<xsl:attribute name="height">
							<xsl:choose>
								<xsl:when test="matches(@Height,'pt')"><xsl:variable name="numeric"
										select="number(replace(@Height,'pt','')) * 0.352777778"
										/><xsl:value-of select="format-number($numeric,'###.##')"
									/>mm</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@Height"/>
									<xsl:text>px</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</xsl:if>
					<xsl:attribute name="src">
						<xsl:value-of select="$gazette-host-name"/>
						<xsl:choose>
							<xsl:when test="contains(@src,'-orig')">
								<xsl:value-of select="@src"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="substring-before(@src,'.')"/>
								<xsl:text>-orig.</xsl:text>
								<xsl:value-of select="substring-after(@src,'.')"/>
							</xsl:otherwise>
						</xsl:choose>
						<!--<xsl:text>.png/original</xsl:text>-->
					</xsl:attribute>
				</img>
			</xsl:when>
			<xsl:otherwise>
				<!-- Copy the element but remove the id tag. -->
				<xsl:element name="{name()}">
					<xsl:copy-of select="@*[not(name() = 'id')]"/>
					<xsl:apply-templates mode="notice"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="front-cover">
		<article class="front-cover">
			<header>
				<xsl:copy-of select="$crest"/>
				<h1 class="sub-title">
					<xsl:choose>
						<xsl:when test="$bespoke = 'true'">Bespoke edition</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$edition-name"/>
						</xsl:otherwise>
					</xsl:choose>
				</h1>
				<xsl:if test="$bespoke = 'true'">
					<div class="bespoke-title">
						<h2>
							<xsl:value-of select="$edition-name"/>
						</h2>
						<xsl:if test="$created">
							<h3>Created by <xsl:value-of select="$created"/></h3>
						</xsl:if>
					</div>
				</xsl:if>
			</header>
			<section class="publication-details">
				<!-- Date and issue number to be passed through. -->
				<xsl:choose>
					<xsl:when
						test="$publishingStatement and $publishingStatement != '' and $bespoke != 'true'">
						<p class="bold">
							<!-- content span class="publication-date" is used as the middle part of the running foot -->
							<span class="publication-date">
								<xsl:text>Containing </xsl:text>
								<xsl:value-of select="$publishingStatement"/>
							</span>
						</p>
						<p class="bold">
							<xsl:choose>
								<xsl:when test="$bespoke = 'true'">
									<xsl:text>Created on </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>Printed on </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:value-of
								select="format-date($publication-date,'[D] [MNn] [Y0001]')"/>
							<xsl:if test="$number != '' and $bespoke != 'true'">
								<xsl:text> | Number </xsl:text>
								<xsl:value-of select="$number"/>
							</xsl:if>
						</p>
					</xsl:when>
					<xsl:otherwise>
						<p class="bold">
							<xsl:choose>
								<xsl:when test="$bespoke = 'true'">
									<xsl:text>Created on </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>Printed on </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
							<span class="publication-date">
								<xsl:value-of
									select="format-date($publication-date,'[D] [MNn] [Y0001]')"/>
							</span>
							<xsl:if test="$number != '' and $bespoke != 'true'">
								<xsl:text> | Number </xsl:text>
								<xsl:value-of select="$number"/>
							</xsl:if>
						</p>
					</xsl:otherwise>
				</xsl:choose>
				<p>Published by Authority | Established 1665</p>
				<p>www.thegazette.co.uk</p>
			</section>
			<section class="table-of-contents">
				<header>Contents</header>
				<xsl:variable name="limits">
					<allowable-codes>
						<xsl:for-each select="tokenize($limit-table-of-contents,',')">
							<code value="{.}"/>
						</xsl:for-each>
					</allowable-codes>
				</xsl:variable>
				<ul>
					<xsl:for-each select="$taxonomy-notice-type/tax:notice-taxonomy/tax:notice-type">
						<xsl:sort select="@sort" data-type="number"/>
						<xsl:variable name="code" select="@code"/>
						<!-- Display the ToC item if there is a list of limits and the code is in it, or if there isn't a list. -->
						<xsl:if
							test="(count($limits//*:code) != 0 and $limits//.[@value=$code]) or (count($limits//*:code) = 0)">
							<li>
								<xsl:variable name="code" select="@code"/>
								<xsl:choose>
									<xsl:when test="count($existing/*:code[text() = $code]) &gt;0">
										<xsl:attribute name="class">active</xsl:attribute>
										<a href="#nt-{@code}">
											<xsl:apply-templates select="@name"/>
											<xsl:text>/</xsl:text>
										</a>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="@name"/>
										<xsl:text>/</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</li>
						</xsl:if>
					</xsl:for-each>
					<xsl:if test="count($terms-and-conditions//*:body//*:article/*)">
						<li class="active">
							<a href="#terms">Terms &amp; Conditions<xsl:if test="$bespoke != 'true'"
									>/</xsl:if>
							</a>
						</li>
					</xsl:if>
				</ul>
				<xsl:if
					test="$bespoke != 'true' and ($publishingStatement and $publishingStatement != '')">
					<footer>
						<xsl:text>* Containing </xsl:text>
						<xsl:value-of select="$publishingStatement"/>
					</footer>
				</xsl:if>
			</section>
		</article>
	</xsl:template>
	<xsl:template name="terms">
		<xsl:if test="count($terms-and-conditions//*:body//*:article/*) &gt; 0">
			<article class="terms-and-conditions" id="terms">
				<xsl:copy-of select="$terms-and-conditions//*:body//*:article/*"/>
			</article>
		</xsl:if>
	</xsl:template>
	<xsl:template name="adverts">
		<xsl:if test="$number-of-extra-pages  &gt; 0">
			<article class="advert advert-1">
				<!--h1>advert 1</h1-->
				<img src="{$gazette-host-name}/print-production/adverts/1.tif" width="170mm"/>
			</article>
		</xsl:if>
		<xsl:if test="$number-of-extra-pages  &gt; 1">
			<article class="advert advert-2">
				<!--h1>advert 2</h1-->
				<img src="{$gazette-host-name}/print-production/adverts/2.tif" width="170mm"/>
			</article>
		</xsl:if>
		<xsl:if test="$number-of-extra-pages  &gt; 2">
			<article class="advert advert-3">
				<img src="{$gazette-host-name}/print-production/adverts/3.tif" width="170mm"/>
			</article>
		</xsl:if>
	</xsl:template>
	<xsl:template name="back-cover">
		<article class="back-cover">
			<xsl:if test="$bespoke != 'true'">
				<header>
					<div class="contact">
						<xsl:copy-of select="$contact-document//*:article/*:header/*"/>
					</div>
					<div class="crest">
						<!-- TODO: needs checked -->
						<xsl:copy-of select="$crest"/>
						<h2>
							<xsl:choose>
								<xsl:when test="$bespoke = 'true'">Bespoke edition</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$edition-name"/>
								</xsl:otherwise>
							</xsl:choose>
						</h2>
					</div>
				</header>
				<section class="charges">
					<!--<xsl:copy-of select="$prices//*:body/*"/>-->
					<xsl:apply-templates select="$prices//*:body/*:table" mode="notice"/>
					<xsl:apply-templates
						select="$prices//*:body/*:footer/*:div[@id='subscriptions']" mode="notice"/>
					<!--<xsl:if
						test="$bespoke != 'true' and ($publishingStatement and $publishingStatement != '')">
						<p>
							<xsl:text>This printed edition contains </xsl:text>
							<xsl:value-of select="$publishingStatement"/>
							<xsl:text>.</xsl:text>
						</p>
					</xsl:if>-->
					<xsl:apply-templates select="$prices//*:body/*:footer/*:div[@id='moreInfo']"
						mode="notice"/>
				</section>
			</xsl:if>
			<div class="sales">
				<section class="contact-information">
					<header>
						<!--TODO: needs checked-->
						<xsl:copy-of select="$tso_logo"/>
						<xsl:copy-of
							select="$contact-document//*:article/*:section[@class='contact-information']/*:header/*"
						/>
					</header>
					<xsl:copy-of
						select="$contact-document//*:article/*:section[@class='contact-information']/*:div[@class='content']/*"/>
					<xsl:if test="$cover-price or $ISSN">
						<dl>
							<xsl:if test="$cover-price">
								<dt>Price:</dt>
								<dd>&#x00A3; <xsl:value-of
										select="format-number(number($cover-price),'###,###.00')"
									/></dd>
							</xsl:if>
							<xsl:if test="$ISSN">
								<dt>ISSN:</dt>
								<dd>
									<xsl:value-of select="$ISSN"/>
								</dd>
							</xsl:if>
						</dl>
					</xsl:if>
				</section>
				<xsl:if test="$barcode != ''">
					<section class="isbn">
						<img>
							<xsl:attribute name="src">
								<xsl:text>data:image/png;base64,</xsl:text>
								<xsl:value-of select="$barcode" disable-output-escaping="yes"/>
							</xsl:attribute>
						</img>
					</section>
				</xsl:if>
			</div>
			<footer class="page-footer">
				<xsl:copy-of select="$contact-document//*:article/*:footer/*"/>
			</footer>
		</article>
	</xsl:template>
	<!-- Safe date formatting function; accepts dateTime, date and string without erroring -->
	<xsl:function name="gfn:safe-date">
		<xsl:param name="date"/>
		<xsl:param name="picture"/>
		<xsl:choose>
			<xsl:when test="$date castable as xs:dateTime">
				<xsl:value-of select="format-date($date,$picture)"/>
			</xsl:when>
			<xsl:when test="$date castable as xs:date">
				<xsl:value-of select="format-date($date,$picture)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$date"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="gfn:safe-date">
		<xsl:param name="date"/>
		<xsl:value-of select="gfn:safe-date($date,'[D] [MNn] [Y0001]')"/>
	</xsl:function>
	<xsl:function name="gfn:short-notice-id">
		<xsl:param name="noticeid"/>
		<xsl:choose>
			<xsl:when
				test="starts-with($noticeid,'L') or starts-with($noticeid,'E') or starts-with($noticeid,'B')">
				<xsl:value-of select="substring-after(substring-after($noticeid,'-'),'-')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$noticeid"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
</xsl:stylesheet>
