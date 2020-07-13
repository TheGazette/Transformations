<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata" xmlns:lga="http://www.tso.co.uk/assets/namespace/gazette" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:tso="http://www.tso.co.uk/econtent/namespaces/tso" xmlns="http://www.w3.org/1999/xhtml" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:g="http://www.gazettes-online.co.uk/ontology#" xmlns:legislation="http://www.gazettes-online.co.uk/ontology/legislation#" xmlns:corp-insolvency="http://www.gazettes-online.co.uk/ontology/corp-insolvency#" xmlns:personal-legal="http://www.gazettes-online.co.uk/ontology/personal-legal#" xmlns:AdministrativeGeography="http://www.ordnancesurvey.co.uk/ontology/v1/AdministrativeGeography.rdf#" xmlns:court="http://www.gazettes-online.co.uk/ontology/court#" xmlns:person="http://www.gazettes-online.co.uk/ontology/person#" xmlns:authority="http://www.gazettes-online.co.uk/ontology/authority#" xmlns:organisation="http://www.gazettes-online.co.uk/ontology/organisation#" xmlns:councils="http://www.gazettes-online.co.uk/ontology/resources/councils#" xmlns:vCard="http://www.w3.org/2006/vcard/ns#" xmlns:courts="http://www.gazettes-online.co.uk/ontology/resources/courts#" xmlns:location="http://www.gazettes-online.co.uk/ontology/location#" xmlns:itc="http://www.gazettes-online.co.uk/ontology/resources/ITC#" xmlns:geoNames="http://www.geonames.org/ontology#" xmlns:proxy="http://www.gazettes-online.co.uk/id/proxy/" version="2.0" exclude-result-prefixes="xs ukm lga dc xhtml tso fo">

<!-- ========== Structure comparison code ========== -->
	
<xsl:import href="post2005legacy2RDFa/post2005legacy2RDFa_structure_test.xslt"/>
	
<!-- ========== Default generation of RDFa+XHTML ============ -->

<xsl:import href="post2005legacy2RDFa/post2005legacy2RDFa_common.xsl"/>
	
<!-- ========== Whitespace fixup code ========== -->

<xsl:import href="post2005legacy2RDFa/post2005legacy2RDFa_whitespace.xsl"/>

<!-- ========== Parameters ========== -->

<!-- Default to 'noformatting.xml' for filename being processed. This parameter needs to be set by the processing application -->
<xsl:param name="strFilename" as="xs:string" select="'noformatting.xml'"/>
  
<!-- Path to setup file - this controls the location of all the other files -->
<xsl:param name="strSetupFilename" as="xs:string" select="resolve-uri($ndsPathToSetup, base-uri($ndsPathToSetup))"/>

<!-- The issue number. This parameter needs to be set by the processing application -->
<xsl:param name="g_strIssueNumber" as="xs:string" select="''"/>

<!-- Gazette publication -->
<xsl:param name="g_strGazette">London</xsl:param>

<!-- ========== Notice category-specific processing ============ -->

<xsl:include href="post2005legacy2RDFa/post2005legacy2RDFa_water_trans_plan_env.xsl"/>
<xsl:include href="post2005legacy2RDFa/post2005legacy2RDFa_corp-insolvency.xsl"/>
<xsl:include href="post2005legacy2RDFa/post2005legacy2RDFa_personal-legal.xsl"/>
<xsl:include href="post2005legacy2RDFa/post2005legacy2RDFa_transport.xsl"/>
<xsl:include href="post2005legacy2RDFa/post2005legacy2RDFa_planning.xsl"/>
<xsl:include href="post2005legacy2RDFa/post2005legacy2RDFa_environment.xsl"/>
<xsl:include href="post2005legacy2RDFa/post2005legacy2RDFa_water.xsl"/>
<xsl:include href="post2005legacy2RDFa/post2005legacy2RDFa_partnerships.xsl"/>
	
<!-- ========== Setup ========== -->

<!-- Path-to-setup document -->
<xsl:variable name="ndsPathToSetup" as="element(PathToSetup)" select="document('post2005legacy2RDFa/post2005legacy2RDFa_path.xml')/PathToSetup"/>
  
<!-- Setup document -->
<xsl:variable name="ndsSetup" as="document-node()" select="document($strSetupFilename)"/>
  
<!-- Configuration document -->
<xsl:variable name="ndsConfiguration" as="document-node()" select="document(concat('',$ndsSetup//Publication[@Gazette=$g_strGazette]/ConfigurationFilename))"/>

<!-- Legacy Notice configuration document -->
<xsl:variable name="ndsLegacyNotices" select="document('post2005legacy2RDFa/common/Gazette_RDFa_Legacy_Notices.xml')"/>
	
<xsl:param name="g_strPublishDateFormat" as="xs:string" select="'[FNn], [D] [MNn] [Y]'"/>

<!-- ========== Main processing =========== -->

<xsl:key name="keyNoticesByCode" match="Notice" use="xs:integer(@Code)"/>

<!-- Create a union of the in-use Notice types with the legacy notice types -->
<xsl:variable name="ndsNoticeTypes">
	<Configuration>
		<xsl:sequence select="$ndsConfiguration//Notice"/>
		<xsl:sequence select="$ndsLegacyNotices//Notice"/>
	</Configuration>
</xsl:variable>

<!-- Union of notices in configuration file and in legacy notice file could overlap, so return the first one if there is more than one match -->
<xsl:function name="lga:noticeConfig" as="element(Notice)">
	<xsl:param name="intCode" as="xs:integer"/>
	<xsl:sequence select="key('keyNoticesByCode', $intCode, $ndsNoticeTypes)[1]"/>
</xsl:function>

<xsl:template match="/"><xsl:message>ndssetup<xsl:value-of select="$ndsPathToSetup"/></xsl:message>
	<xsl:variable name="nstWhitespaceFixedup">
		<xsl:apply-templates select="." mode="GazetteWhitespaceFixup"/>
	</xsl:variable>
	<xsl:apply-templates select="$nstWhitespaceFixedup/node()"/>
</xsl:template>

<xsl:template match="lga:Gazette">
	<div>
		<xsl:apply-templates select="lga:Body"/>
	</div>
</xsl:template>
	
<xsl:template match="lga:Notice" mode="NoticeHeading">
	<xsl:variable name="intNoticeCode" as="xs:integer" select="@Type"/>
	<xsl:variable name="ndsNoticeConfig" as="element(Notice)" select="lga:noticeConfig($intNoticeCode)"/>
	<xsl:if test="lga:NoticeHeading or $ndsNoticeConfig/Name != ''">
	  <p> <!-- OLD: <p style="font-weight: bold;"> -->
			<xsl:choose>
				<xsl:when test="lga:NoticeHeading">
					<xsl:apply-templates select="lga:NoticeHeading">
						<xsl:with-param name="intType" select="$intNoticeCode" tunnel="yes"/>
						<xsl:with-param name="blnBold" select="true()" tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:when>
			<xsl:otherwise>
					<xsl:call-template name="TSOprocessText">
						<xsl:with-param name="strText" select="$ndsNoticeConfig/Name"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</p>
	</xsl:if>
</xsl:template>
	
<xsl:template match="lga:Notice" mode="NoticeContent">
	<xsl:variable name="intNoticeCode" as="xs:integer" select="@Type"/>
	<xsl:choose>
		<xsl:when test="$intNoticeCode = (2403,2405,2407,2406,2408)"/>
		<xsl:otherwise><xsl:apply-templates select="." mode="NoticeHeading"/></xsl:otherwise>
	</xsl:choose>	
	
	<!-- *** TODO *** -->
	<xsl:variable name="strIsStructureOK">
		<xsl:call-template name="FuncStructureCompare"/>
	</xsl:variable>
	<xsl:variable name="blnConformingStructure" as="xs:boolean" select="not(ukm:Metadata/ukm:ContentClass = 'FREEFORM') and            not(contains($strIsStructureOK, 'false'))"/>
	<xsl:choose>
		<xsl:when test="$blnConformingStructure">
			<xsl:choose>
				<!-- For entries that need the content rearranging -->
				<xsl:when test="$intNoticeCode eq 2452">
					<xsl:call-template name="TSOformatType-2452">
						<xsl:with-param name="intType" select="$intNoticeCode" tunnel="yes"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$intNoticeCode eq 2453">
					<xsl:call-template name="TSOformatType-2453">
						<xsl:with-param name="intType" select="$intNoticeCode" tunnel="yes"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$intNoticeCode eq 2503">
					<xsl:call-template name="TSOformatType-2503">
						<xsl:with-param name="intType" select="$intNoticeCode" tunnel="yes"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$intNoticeCode eq 2504">
					<xsl:call-template name="TSOformatType-2504">
						<xsl:with-param name="intType" select="$intNoticeCode" tunnel="yes"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$intNoticeCode eq 2505">
					<xsl:call-template name="TSOformatType-2505">
						<xsl:with-param name="intType" select="$intNoticeCode" tunnel="yes"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$intNoticeCode eq 2506">
					<xsl:call-template name="TSOformatType-2506">
						<xsl:with-param name="intType" select="$intNoticeCode" tunnel="yes"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$intNoticeCode eq 2512">
					<xsl:call-template name="TSOformatType-2512">
						<xsl:with-param name="intType" select="$intNoticeCode" tunnel="yes"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$intNoticeCode eq 2515">
					<xsl:call-template name="TSOformatType-2515">
						<xsl:with-param name="intType" select="$intNoticeCode" tunnel="yes"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="lga:* except lga:NoticeHeading">
						<xsl:with-param name="intType" select="$intNoticeCode" tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!-- For entries where order of content is as in XML -->
	<xsl:otherwise>
			<xsl:apply-templates select="lga:* except lga:NoticeHeading">
				<xsl:with-param name="intType" select="$intNoticeCode" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:otherwise> 
	</xsl:choose>
</xsl:template>


<xsl:template name="TSOformatType-2503">
	<p>
		<xsl:for-each select="lga:Person">
			<xsl:if test="preceding-sibling::lga:Person"> and </xsl:if>
			<xsl:apply-templates select="lga:PersonName/node()"/>
		</xsl:for-each>	
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="lga:Person/lga:PersonAddress"/> <!-- 2011-03-07 CRJC: 'apply' added-->
		<xsl:call-template name="TSOformatDateOfBirth"/> <!-- 2011-03-10 CRJC: 'call' added -->
		<xsl:apply-templates select="lga:Person/lga:PersonDetails/node()"/>
		<xsl:call-template name="TSOformatCourtName"/>
		<xsl:call-template name="TSOformatCourtDistrictName"/>
		<xsl:call-template name="TSOformatPetitionFilingDate"/>
		<xsl:call-template name="TSOformatCourtNumber"/>
		<xsl:call-template name="TSOformatBankruptcyOrderDate"/>
		<xsl:call-template name="TSOformatPetitionType"/>
		<xsl:call-template name="TSOformatBankruptcyOrderTime"/> <!-- 2011-03-07 CRJC: 'call' added for BOT. Inserted following PetitionType, as that seems to be where they are in the PDF currently, but it may be wrong... -->
		<xsl:call-template name="TSOformatPetitioner"/> <!-- 2011-03-07 CRJC: 'call' added for Petitioner -->
		<xsl:call-template name="TSOformatOfficialReceiver"/>
	</p>	
</xsl:template>

<xsl:template name="TSOformatType-2504">
	<p>
	  <span> <!-- <span style="font-weight: bold;"> -->
			<xsl:apply-templates select="lga:Partnership/lga:PartnershipName/node()">
				<xsl:with-param name="blnBold" select="true()" tunnel="yes"/>
			</xsl:apply-templates>
		</span>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="lga:Partnership/lga:PartnershipDetails/node()"/>
		<xsl:apply-templates select="lga:P/lga:Text/node()"/>
		<xsl:call-template name="TSOformatCourtName"/>
		<xsl:call-template name="TSOformatCourtDistrictName"/>
		<xsl:call-template name="TSOformatPetitionFilingDate"/>
		<xsl:call-template name="TSOformatCourtNumber"/>
		<xsl:call-template name="TSOformatBankruptcyOrderDate"/>
		<xsl:call-template name="TSOformatPetitionType"/>
		<xsl:call-template name="TSOformatBankruptcyOrderTime"/> <!-- 2011-03-07 CRJC: 'call' added for BOT. Inserted following PetitionType, as that seems to be where they are in the PDF currently, but it may be wrong... -->
		<xsl:call-template name="TSOformatPetitioner"/> <!-- 2011-03-07 CRJC: 'call' added for Petitioner -->
		<xsl:call-template name="TSOformatOfficialReceiver"/>
	</p>	
</xsl:template>

<xsl:template name="TSOformatType-2505">
	<p>
		<xsl:apply-templates select="lga:Person/lga:PersonName/node()"/>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="lga:Person/lga:PersonAddress"/> <!-- 2011-03-07 CRJC: 'apply' added-->
		<xsl:call-template name="TSOformatDateOfBirth"/> <!-- 2011-03-10 CRJC: 'call' added -->
		<xsl:apply-templates select="lga:Person/lga:PersonDetails/node()"/>
		<xsl:call-template name="TSOformatCourtName"/>
		<xsl:call-template name="TSOformatPetitionFilingDate"/>
		<xsl:call-template name="TSOformatCourtNumber"/>
		<xsl:if test="lga:Administration/lga:AdministrationOrderMade">
			<xsl:text>. </xsl:text>		
			<xsl:choose>
				<xsl:when test="lga:Administration/lga:AdministrationOrderMade/@Type">
					<xsl:apply-templates select="lga:Administration/lga:AdministrationOrderMade" mode="AutoTextOverrides"/>				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Date of Administration Order&#x97;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>						
			<xsl:apply-templates select="lga:Administration/lga:AdministrationOrderMade/node()"/>
		</xsl:if>		
		<xsl:call-template name="TSOformatPetitionType"/>
		<xsl:call-template name="TSOformatPetitioner"/> <!-- 2011-03-07 CRJC: 'call' added for Petitioner -->
		<xsl:call-template name="TSOformatOfficialReceiver"/>
	</p>	
</xsl:template>

<xsl:template name="TSOformatType-2506">
	<p>
		<xsl:apply-templates select="lga:Person/lga:PersonName/node()"/>
		<xsl:text>, </xsl:text>
		<xsl:call-template name="TSOformatDateOfBirth"/> <!-- 2011-03-10 CRJC: 'call' added -->
		<xsl:apply-templates select="lga:Person/lga:PersonDetails/node()"/>
		<xsl:call-template name="TSOformatCourtName"/>
		<xsl:call-template name="TSOformatCourtNumber"/>
		<xsl:call-template name="TSOformatBankruptcyOrderDate"/>
		<xsl:text>. These proceedings where previously advertised in </xsl:text>
		<span style="font-style: italic;">The London Gazette</span>
		<xsl:text> under the description: </xsl:text>
		<xsl:for-each select="lga:P/lga:Text">
			<xsl:apply-templates select="node()"/>
			<xsl:if test="not(position() = last())">
				<xsl:text>.</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:call-template name="TSOformatOfficialReceiver"/>
	</p>	
</xsl:template>

<xsl:template name="TSOformatType-2512">
	<p>
		<xsl:apply-templates select="lga:Person/lga:PersonName/node()"/>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="lga:Person/lga:PersonAddress"/> <!-- 2011-03-07 CRJC: 'apply' added-->
		<xsl:call-template name="TSOformatDateOfBirth"/> <!-- 2011-03-10 CRJC: 'call' added -->
		<xsl:apply-templates select="lga:Person/lga:PersonDetails/node()"/>
		<xsl:call-template name="TSOformatCourtName"/>
		<xsl:call-template name="TSOformatCourtNumber"/>
		<xsl:call-template name="TSOformatBankruptcyOrderDate"/>
		<xsl:if test="lga:Court/lga:DateOfAnnulment">
			<xsl:text>. </xsl:text>		
			<xsl:choose>
				<xsl:when test="lga:Court/lga:DateOfAnnulment/@Type">
					<xsl:apply-templates select="lga:Court/lga:DateOfAnnulment" mode="AutoTextOverrides"/>				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Date of Annulment&#x97;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>						
			<xsl:apply-templates select="lga:Court/lga:DateOfAnnulment/node()"/>
		</xsl:if>
		<xsl:if test="lga:Court/lga:GroundsOfAnnulment">
			<xsl:text>. </xsl:text>		
			<xsl:choose>
				<xsl:when test="lga:Court/lga:GroundsOfAnnulment/@Type">
					<xsl:apply-templates select="lga:Court/lga:GroundsOfAnnulment" mode="AutoTextOverrides"/>				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Grounds of Annulment&#x97;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>						
			<xsl:apply-templates select="lga:Court/lga:GroundsOfAnnulment/node()"/>
		</xsl:if>
		<xsl:call-template name="TSOformatOfficialReceiver"/>
	</p>	
</xsl:template>

<xsl:template name="TSOformatType-2515">
	<p>
		<xsl:apply-templates select="lga:Person/lga:PersonName/node()"/>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="lga:Person/lga:PersonAddress"/> <!-- 2011-03-07 CRJC: 'apply' added-->
		<xsl:call-template name="TSOformatDateOfBirth"/> <!-- 2011-03-10 CRJC: 'call' added -->
		<xsl:apply-templates select="lga:Person/lga:PersonDetails/node()"/>
		<xsl:call-template name="TSOformatCourtName"/>
		<xsl:call-template name="TSOformatCourtNumber"/>
		<xsl:call-template name="TSOformatBankruptcyOrderDate"/>
		<xsl:if test="lga:Court/lga:DateOfDischarge">
			<xsl:text>. </xsl:text>		
			<xsl:choose>
				<xsl:when test="lga:Court/lga:DateOfDischarge/@Type">
					<xsl:apply-templates select="lga:Court/lga:DateOfDischarge" mode="AutoTextOverrides"/>				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Date of Discharge&#x97;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>						
			<xsl:apply-templates select="lga:Court/lga:DateOfDischarge/node()"/>
		</xsl:if>
		<xsl:if test="lga:Court/lga:DateOfCertificateOfDischarge"> <!-- 2011-03-07 CRJC: 'if' added -->
			<xsl:text>. </xsl:text>		
			<xsl:choose>
				<xsl:when test="lga:Court/lga:DateOfCertificateOfDischarge/@Type">
					<xsl:apply-templates select="lga:Court/lga:DateOfCertificateOfDischarge" mode="AutoTextOverrides"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Date of Certificate of Discharge&#x97;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>						
			<xsl:apply-templates select="lga:Court/lga:DateOfCertificateOfDischarge/node()"/>
		</xsl:if>
		<xsl:call-template name="TSOformatOfficialReceiver"/>
	</p>	
</xsl:template>

<xsl:template name="TSOformatWindingUpOrder">
	<xsl:if test="lga:Court/lga:WindingUpOrderDate">
		<xsl:text>. </xsl:text>		
		<xsl:choose>
			<xsl:when test="lga:Court/lga:WindingUpOrderDate/@Type">
				<xsl:apply-templates select="lga:Court/lga:WindingUpOrderDate" mode="AutoTextOverrides"/>			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Winding-up Order made on&#x97;</xsl:text> <!-- 2011-03-07 CRJC: text changed from "Date of Winding-up Order" at the behest of the IS -->
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates select="lga:Court/lga:WindingUpOrderDate/node()" mode="#current"/>
	</xsl:if>				
</xsl:template>
	
<xsl:template name="TSOformatVolWindingUpResolution"> <!-- 2011-03-07 CRJC: template created -->
	<xsl:if test="lga:Court/lga:VolWindingUpResolutionDate">
		<xsl:text>. </xsl:text>		
		<xsl:choose>
			<xsl:when test="lga:Court/lga:VolWindingUpResolutionDate/@Type">
				<xsl:apply-templates select="lga:Court/lga:VolWindingUpResolutionDate" mode="AutoTextOverrides"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Date of Resolution for Voluntary Winding-up&#x97;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates select="lga:Court/lga:VolWindingUpResolutionDate/node()" mode="#current"/>
	</xsl:if>				
</xsl:template>

<!-- This would only get called if special layout notices were in freeform mode -->
<xsl:template match="lga:DateOfAnnulment">
	<p>
		<xsl:choose>
			<xsl:when test="@Type">
				<xsl:apply-templates select="." mode="AutoTextOverrides"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Date of Annulment: </xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates/>
		<xsl:choose>
			<xsl:when test="starts-with(@Type, '(')">)</xsl:when>
			<xsl:otherwise>.</xsl:otherwise>
		</xsl:choose>
	</p>
</xsl:template>

<!-- This would only get called if special layout notices were in freeform mode -->
<xsl:template match="lga:DateOfDischarge">
	<p>
		<xsl:choose>
			<xsl:when test="@Type">
				<xsl:apply-templates select="." mode="AutoTextOverrides"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Date of Discharge: </xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates/>
		<xsl:choose>
			<xsl:when test="starts-with(@Type, '(')">)</xsl:when>
			<xsl:otherwise>.</xsl:otherwise>
		</xsl:choose>
	</p>
</xsl:template>

<xsl:template match="lga:DateOfCertificateOfDischarge">
	<p>
		<xsl:choose>
			<xsl:when test="@Type">
				<xsl:apply-templates select="." mode="AutoTextOverrides"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Date of Certificate of Discharge: </xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates/>
		<xsl:choose>
			<xsl:when test="starts-with(@Type, '(')">)</xsl:when>
			<xsl:otherwise>.</xsl:otherwise>
		</xsl:choose>
	</p>
</xsl:template>

	<xsl:template match="lga:GroundsOfAnnulment">
	<p>
		<xsl:choose>
			<xsl:when test="@Type">
				<xsl:apply-templates select="." mode="AutoTextOverrides"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Grounds of Annulment: </xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates/>
		<xsl:choose>
			<xsl:when test="starts-with(@Type, '(')">)</xsl:when>
			<xsl:otherwise>.</xsl:otherwise>
		</xsl:choose>
	</p>
</xsl:template>

<xsl:template name="TSOformatPetitionFilingDate">
	<xsl:if test="lga:Court/lga:PetitionFilingDate">
		<xsl:text>. </xsl:text>
		<xsl:choose>
			<xsl:when test="lga:Court/lga:PetitionFilingDate/@Type">
				<xsl:apply-templates select="lga:Court/lga:PetitionFilingDate" mode="AutoTextOverrides"/>			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Date of Filing Petition&#x97;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>				
		<xsl:apply-templates select="lga:Court/lga:PetitionFilingDate/node()" mode="#current"/>
	</xsl:if>
</xsl:template>

<xsl:template name="TSOformatDateOfBirth"> <!-- 2011-03-10 CRJC: new template created -->
	<xsl:if test="lga:Person/lga:BirthDetails/lga:Date/node()">
  	<xsl:text>Date of Birth&#x97;</xsl:text>
		<xsl:apply-templates select="lga:Person/lga:BirthDetails/lga:Date/node()" mode="#current"/>
	</xsl:if>
</xsl:template>



<xsl:template name="TSOformatPetitionType">
	<xsl:if test="lga:Court/lga:TypeOfPetition">
		<xsl:text>. </xsl:text>		
		<xsl:choose>
			<xsl:when test="lga:Court/lga:TypeOfPetition/@Type">
				<xsl:apply-templates select="lga:Court/lga:TypeOfPetition" mode="AutoTextOverrides"/>			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Whether Debtor's or Creditor's Petition&#x97;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates select="lga:Court/lga:TypeOfPetition/node()"/>
	</xsl:if>
</xsl:template>

<!-- This would only get called if special layout notices were in freeform mode -->
<xsl:template match="lga:TypeOfPetition">
	<p>
		<xsl:choose>
			<xsl:when test="@Type">
				<xsl:apply-templates select="." mode="AutoTextOverrides"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Whether Debtor's or Creditor's Petition&#x97;: </xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates/>
		<xsl:choose>
			<xsl:when test="starts-with(@Type, '(')">)</xsl:when>
			<xsl:otherwise>.</xsl:otherwise>
		</xsl:choose>
	</p>
</xsl:template>

<xsl:template name="TSOformatOfficialReceiver">
	<xsl:if test="lga:Administration/lga:Administrator">
		<xsl:text>. </xsl:text>		
		<xsl:choose>
			<xsl:when test="lga:Administration/lga:Administrator/@Type">
				<xsl:apply-templates select="lga:Administration/lga:Administrator" mode="AutoTextOverrides"/>			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Official Receiver&#x97;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates select="lga:Administration/lga:Administrator/node()" mode="#current"/>
	</xsl:if>
</xsl:template>

<xsl:template name="TSOformatBankruptcyOrderDate">
	<xsl:if test="lga:Court/lga:BankruptcyOrderDate">
		<xsl:text>. </xsl:text>		
		<xsl:choose>
			<xsl:when test="lga:Court/lga:BankruptcyOrderDate/@Type">
				<xsl:apply-templates select="lga:Court/lga:BankruptcyOrderDate" mode="AutoTextOverrides"/>			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Date of Bankruptcy Order&#x97;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates select="lga:Court/lga:BankruptcyOrderDate/node()"/>
	</xsl:if>
</xsl:template>

<xsl:template match="lga:BankruptcyOrderDate">
	<p>
		<xsl:choose>
			<xsl:when test="@Type">
				<xsl:apply-templates select="." mode="AutoTextOverrides"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Date of Bankruptcy Order: </xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates/>
		<xsl:choose>
			<xsl:when test="starts-with(@Type, '(')">)</xsl:when>
			<xsl:otherwise>.</xsl:otherwise>
		</xsl:choose>
	</p>
</xsl:template>

<xsl:template name="TSOformatBankruptcyOrderTime"> <!-- 2011-03-07 CRJC: template added -->
	<xsl:if test="lga:Court/lga:BankruptcyOrderTime">
		<xsl:text>. </xsl:text>
		<xsl:choose>
			<xsl:when test="lga:Court/lga:BankruptcyOrderTime/@Type">
				<xsl:apply-templates select="lga:Court/lga:BankruptcyOrderTime" mode="AutoTextOverrides"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Time of Bankruptcy Order&#x97;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates select="lga:Court/lga:BankruptcyOrderTime/node()"/>
	</xsl:if>
</xsl:template>

<xsl:template match="lga:BankruptcyOrderTime"> <!-- 2011-03-07 CRJC: template added -->
	<p>
		<xsl:choose>
			<xsl:when test="@Type">
				<xsl:apply-templates select="." mode="AutoTextOverrides"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Time of Bankruptcy Order: </xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates/>
		<xsl:choose>
			<xsl:when test="starts-with(@Type, '(')">)</xsl:when>
			<xsl:otherwise>.</xsl:otherwise>
		</xsl:choose>
	</p>
</xsl:template>

<xsl:template name="TSOformatPetitioner"> <!-- 2011-03-07 CRJC: template created -->
	<xsl:text>Name and Address of Petitioner&#x97;</xsl:text>
	<xsl:apply-templates select="lga:Court/lga:Petitioner/*"/>
</xsl:template>

<xsl:template match="lga:Petitioner"> <!-- 2011-03-07 CRJC: template created -->
	<p>
		<xsl:choose>
			<xsl:when test="@Type">
				<xsl:apply-templates select="*" mode="AutoTextOverrides"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Name and Address of Petitioner: </xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates select="lga:PetitionerName"/>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="lga:PetitionerAddress"/>
		<xsl:text>.</xsl:text>
	</p>
</xsl:template>

<xsl:template match="lga:PetitionerName | lga:PetitionerAddress">
	<xsl:apply-templates/>
</xsl:template>

<!-- Format court name for special layout notices. These have the same way of doing the court name -->
<xsl:template name="TSOformatCourtName">
	<xsl:if test="lga:Court/lga:CourtName">
		<xsl:text>. </xsl:text>		
		<xsl:choose>
			<xsl:when test="lga:Court/lga:CourtName/@Type">
				<xsl:apply-templates select="lga:Court/lga:CourtName" mode="AutoTextOverrides"/>			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Court&#x97;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates select="lga:Court/lga:CourtName/node()" mode="#current"/>
	</xsl:if>
</xsl:template>

<xsl:template name="TSOformatCourtDistrictName">
	<xsl:if test="lga:Court/lga:CourtDistrict">
		<xsl:text>. </xsl:text>		
		<xsl:choose>
			<xsl:when test="lga:Court/lga:CourtDistrict/@Type">
				<xsl:apply-templates select="lga:Court/lga:CourtDistrict" mode="AutoTextOverrides"/>			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Court&#x97;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates select="lga:Court/lga:CourtDistrict/node()" mode="#current"/>
	</xsl:if>
</xsl:template>

<xsl:template name="TSOformatCourtNumber">
	<xsl:if test="lga:Court/lga:CourtNumber">
		<xsl:text>. </xsl:text>		
		<xsl:choose>
			<xsl:when test="lga:Court/lga:CourtNumber/@Type">
				<xsl:apply-templates select="lga:Court/lga:CourtNumber" mode="AutoTextOverrides"/>			</xsl:when>
			<xsl:otherwise>
				<xsl:text>No. of Matter&#x97;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>						
		<xsl:apply-templates select="lga:Court/lga:CourtNumber/@Number"/>
		<xsl:text> of </xsl:text>
		<xsl:apply-templates select="lga:Court/lga:CourtNumber/@Year"/>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>