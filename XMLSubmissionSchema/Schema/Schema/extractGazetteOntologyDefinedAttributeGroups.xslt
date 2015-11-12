<!-- Version 1.00 -->
<!-- Created by Griff Chamberlain -->
<!-- THIS IS AN XSLT v2 STYLESHEET -->
<!-- used for extracting property names from Gazette ontology to generate the schemaGazetteOntologyDefinedAttributeGroups.xsd schema module -->
<!-- This is run against files.xml - which contains a list of ontology modules and generates the appropriate attribute values from teh ontology datatype properties-->

<!-- EXAMPLE OF FILES.XML-->
<!-- The filepath to the ontology can be specified with the strOntologyPath parameter otherwise it is run relative to the files
<OntologyDatatypes>
	<files>
		<file>authority.owl</file>
		<file>consultation.owl</file>
	</files>	
	<ommissions>
		<omitValues attributeGroup="ThingClass">
			<omitValue>organisation:name</omitValue>
			<omitValue>person:initial</omitValue>
		</omitValues>	
	</ommissions>
	<deprecated>
		<deprecatedValues attributeGroup="DateTimeClass">
			<deprecatedValue>Appointment</deprecatedValue>
			<deprecatedValue>General</deprecatedValue>
		</deprecatedValues>
	</deprecated>
	<additional>
		<additionalValues attributeGroup="DateTimeClass">
			<additionalValue></additionalValue>
		</additionalValues>
	</additional>
</OntologyDatatypes>
-->

<!-- Example command line invoking saxon.bat -->
<!-- saxon9 -o schemaGazetteOntologyDefinedAttributeGroups.xsd files.xml extractGazetteOntologyDefinedAttributeGroups.xslt -->

<!--A single attribute group can be invoke by specifying the strClass parameter - for example: -->
<!-- saxon9 -o duration.xml files.xml extractGazetteOntologyDefinedAttribtueGroups.xslt "strClass=Duration" -->
<!-- Values for strClass are:
	DateTime
	Time
	Duration
	Thing
	Value
	All

All is the default -->

<!-- Last changed  -->

<!-- Change history

	09/01/2009		Griff Chamberlain	Added processing of annotation and object properties. Added predicate attribute group
									Allow for rdf:Property elements
	29/12/2008		Griff Chamberlain	Created	

 -->



<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
	xmlns:tso="http://tso.com/functions"
	
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"

	xmlns:corp-insolvency="http://www.gazettes-online.co.uk/ontology/corp-insolvency#"
	xmlns:personal-legal="http://www.gazettes-online.co.uk/ontology/personal-legal#"
	xmlns:partnerships="http://www.gazettes-online.co.uk/ontology/partnerships#"
	xmlns:transport="http://www.gazettes-online.co.uk/ontology/transport#"
	xmlns:planning="http://www.gazettes-online.co.uk/ontology/planning#"
	xmlns:water="http://www.gazettes-online.co.uk/ontology/water#"
	xmlns:environment="http://www.gazettes-online.co.uk/ontology/environment#"

	xmlns:legislation="http://www.gazettes-online.co.uk/ontology/legislation#"
	xmlns:person="http://www.gazettes-online.co.uk/ontology/person#"
	xmlns:organisation="http://www.gazettes-online.co.uk/ontology/organisation#"
	xmlns:court="http://www.gazettes-online.co.uk/ontology/court#"
	xmlns:authority="http://www.gazettes-online.co.uk/ontology/authority#"
	xmlns:consultation="http://www.gazettes-online.co.uk/ontology/consultation#"
	xmlns:duration="http://www.gazettes-online.co.uk/ontology/duration#"

	xmlns:legislation-individuals="http://www.gazettes-online.co.uk/ontology/resources/legislation-individuals#"
	xmlns:itc="http://www.gazettes-online.co.uk/ontology/resources/ITC#"
	xmlns:official-receivers="http://www.gazettes-online.co.uk/ontology/resources/official-receivers#"
	xmlns:courts="http://www.gazettes-online.co.uk/ontology/resources/courts#"

	xmlns:AdministrativeGeography="http://www.ordnancesurvey.co.uk/ontology/v1/AdministrativeGeography.rdf#"
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:dcq="http://purl.org/dc/terms/"
	xmlns:geo="http://www.geonames.org/ontology#"
	xmlns:time="http://www.w3.org/2006/time#" 
	xmlns:dcterms="http://purl.org/dc/terms/"
	exclude-result-prefixes="tso owl dc rdf rdfs corp-insolvency personal-legal partnerships transport planning water environment legislation person organisation court authority duration consultation legislation-individuals itc official-receivers courts AdministrativeGeography geo time dcterms"
	>

	<xsl:output method="xml" version="1.0" indent="yes" />

	<!--insert classname  here to restrict the output to particular attribute class - possible values are DateTime, Duration, Time, Thing, Value, Predicate or All-->
	<xsl:param name="strClass">All</xsl:param>
	<!--author of the stylesheet generation-->
	<xsl:param name="strAuthor">Griff Chamberlain</xsl:param>
	<!--version of the stylesheet -->
	<xsl:param name="strVersion">1.01</xsl:param>
	<!--path to ontology files -->
	<xsl:param name="strOntologyPath"></xsl:param>
	<!--nodeset of properties to be Ommitted -->
	<xsl:param name="nstOmmissions"><xsl:copy-of select="//ommissions"/>
	</xsl:param>
	<!--nodeset of existing deprecated  enumerations-->
	<xsl:param name="nstDeprecated"><xsl:copy-of select="//deprecated"/>
	</xsl:param>
	<!--nodeset of any additional  enumerations-->
	<xsl:param name="nstAdditional"><xsl:copy-of select="//additional"/>
	</xsl:param>
	
	
	
	

	<xsl:template match="/">
		
		<!--  capture the ontology properties from each module into a single nodeset -->
		<xsl:variable name="nstDatatypes">
			  <wholeOntology>
				<xsl:apply-templates mode="phase-1"/>
			  </wholeOntology>
		</xsl:variable>		
		
		<xsd:schema xmlns="http://www.tso.co.uk/assets/namespace/gazette" 
					xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
					targetNamespace="http://www.tso.co.uk/assets/namespace/gazette" 
					elementFormDefault="qualified" 
					attributeFormDefault="unqualified" 
					version="1.0" 
					id="schemaGazetteOntologyDefinedAttributeGroups">
		<xsl:namespace name="ns1" select="'http://purl.org/dc/terms/'"/>

		<!--by default we will build the annotations into the output schema-->
		<xsl:if test="$strClass = 'All'">
			<xsd:annotation>
				<xsl:namespace name="dcq"
                  select="'http://purl.org/dc/terms/'"/>
				<xsl:namespace name="dc"
                  select="'http://purl.org/dc/elements/1.1/'"/>
				<xsd:appinfo>
					<dc:title>Ontology defined attribute groups</dc:title>
					<dc:description>Attribute groups whose values are defined by the Gazette ontology
									THIS IS AUTO GENERATED FROM AN XSLT STYLESHEET
									extractGazetteOntologyDefinedAttributeGroups.xslt
									DO NOT AMEND THIS SCHEMA MANUALLY</dc:description>
					<dc:contributor><xsl:value-of select="$strAuthor"/></dc:contributor>
					<dc:creator>TSO</dc:creator>
					<dc:identifier>schemaGazetteOntologyDefinedAttributeGroups</dc:identifier>
					<dc:language>en</dc:language>
					<dc:publisher>The Stationery Office</dc:publisher>
					<dc:rights>Copyright The Stationery Office 2008</dc:rights>
					<dc:date>
						<dcq:created><xsl:value-of select="current-dateTime()"/></dcq:created>
					</dc:date>
					<dc:date>
						<dcq:modified><xsl:value-of select="current-dateTime()"/></dcq:modified>
					</dc:date>
					<xsd:documentation>
					Modification information
					Version				Name
						<xsl:value-of select="$strVersion"/>
						<xsl:text>		</xsl:text>
						<xsl:value-of select="$strAuthor"/>	
					</xsd:documentation>
				</xsd:appinfo>
			</xsd:annotation>
		</xsl:if>
		
		
		<!--Generate the DateTimeClass Attribute group-->
		<xsl:if test="$strClass = 'DateTime' or $strClass = 'All'">
			<xsd:attributeGroup name="DateTimeClass">
				<xsd:attribute name="Class" use="required">
					<xsd:annotation>
						<xsd:documentation>The non-prefixed values are previous attribute values retained for backward compatibility</xsd:documentation>
						<xsd:documentation>The prefixed values are date, year and datetime datatype properties extracted from the Gazette ontology</xsd:documentation>
					</xsd:annotation>
					<xsd:simpleType>
						<!--<xsd:list>
							<xsd:simpleType>-->
								<xsd:restriction base="xsd:string">
									<!-- insert deprecated values-->
									<xsl:sequence select="tso:deprecatedEnumerations('DateTimeClass')"/>
									<xsl:sequence select="tso:additionalEnumerations('DateTimeClass')"/>
									<xsl:for-each-group select="$nstDatatypes//wholeOntology/Datatype" 
														group-by="@type">
										<xsl:variable name="strDatatype" select="tso:datatype(@type)"/>
										<xsl:if test="$strDatatype = 'date' or $strDatatype = 'dateTime'  or $strDatatype = 'gYear'">
											
											
											<xsl:for-each select="current-group()"><xsl:sort select="."/>
												<xsl:if test="not(@value = $nstOmmissions//omitValues[@attributeGroup='DateTimeClass']/omitValue)">
													<xsd:enumeration value="{@value}">
													<xsl:if test="annotation">
														<xsd:annotation>
															<xsd:documentation>
																<xsl:value-of select="annotation"/>
															</xsd:documentation>
														</xsd:annotation>
													</xsl:if>
												</xsd:enumeration>
												</xsl:if>
											</xsl:for-each>
										</xsl:if>
									</xsl:for-each-group>
								</xsd:restriction>
							<!--</xsd:simpleType>
						</xsd:list>-->
					</xsd:simpleType>
				</xsd:attribute>
			</xsd:attributeGroup>
		</xsl:if>
		
		<!--Generate the DurationClass Attribute group-->
		<xsl:if test="$strClass = 'Duration' or $strClass = 'All'">
			<xsd:attributeGroup name="DurationClass">
				<xsd:attribute name="Class" use="required">
					<xsd:annotation>
						<xsd:documentation>Duration datatypes extracted from the Gazette ontology</xsd:documentation>
					</xsd:annotation>
					<xsd:simpleType>
						<xsd:restriction base="xsd:string">
							<xsl:sequence select="tso:deprecatedEnumerations('DurationClass')"/>
							<xsl:sequence select="tso:additionalEnumerations('DurationClass')"/>
							<xsl:for-each-group select="$nstDatatypes//wholeOntology/Datatype" 
													group-by="@type">
								<xsl:variable name="strDatatype" select="tso:datatype(@type)"/>
								<xsl:if test="$strDatatype = 'duration'">
									<xsl:for-each select="current-group()"><xsl:sort select="."/>
										<xsl:if test="not(@value = $nstOmmissions//omitValues[@attributeGroup='DurationClass']/omitValue)">
											<xsd:enumeration value="{@value}">
											<xsl:if test="annotation">
												<xsd:annotation>
													<xsd:documentation>
														<xsl:value-of select="annotation"/>
													</xsd:documentation>
												</xsd:annotation>
											</xsl:if>
										</xsd:enumeration>
										</xsl:if>
									</xsl:for-each>
								</xsl:if>
							</xsl:for-each-group>
						</xsd:restriction>
					</xsd:simpleType>
				</xsd:attribute>
			</xsd:attributeGroup>		
		</xsl:if>
		
		<!--Generate the TimeClass Attribute group-->
		<xsl:if test="$strClass = 'Time' or $strClass = 'All'">
			<xsd:attributeGroup name="TimeClass">
				<xsd:attribute name="Class" use="required">
				<xsd:annotation>
					<xsd:documentation>The non-prefixed values are previous attribute values retained for backward compatibility</xsd:documentation>
					<xsd:documentation>The prefixed values are time and dateTime datatype properties extracted from the Gazette ontology</xsd:documentation>
				</xsd:annotation>
				<xsd:simpleType>
					<xsd:restriction base="xsd:string">
						<xsl:sequence select="tso:deprecatedEnumerations('TimeClass')"/>
						<xsl:sequence select="tso:additionalEnumerations('TimeClass')"/>
						<xsl:for-each-group select="$nstDatatypes//wholeOntology/Datatype" 
												group-by="@type">
								<xsl:variable name="strDatatype" select="tso:datatype(@type)"/>
								<xsl:if test="$strDatatype = 'time' or $strDatatype = 'dateTime'">
									<xsl:for-each select="current-group()"><xsl:sort select="."/>
										<xsl:if test="not(@value = $nstOmmissions//omitValues[@attributeGroup='TimeClass']/omitValue)">
											<xsd:enumeration value="{@value}">
											<xsl:if test="annotation">
												<xsd:annotation>
													<xsd:documentation>
														<xsl:value-of select="annotation"/>
													</xsd:documentation>
												</xsd:annotation>
											</xsl:if>
										</xsd:enumeration>
										</xsl:if>
									</xsl:for-each>
								</xsl:if>
							</xsl:for-each-group>
						</xsd:restriction>
					</xsd:simpleType>
				</xsd:attribute>
			</xsd:attributeGroup>		
		</xsl:if>
		
		<!--Generate the ThingClass Attribute group-->
		<xsl:if test="$strClass = 'Thing' or $strClass = 'All'">
			<xsd:attributeGroup name="ThingClass">
				<xsd:attribute name="Class" use="required">
					<xsd:annotation>
						<xsd:documentation>String datatype and annotation properties extracted from the Gazette ontology</xsd:documentation>
					</xsd:annotation>
					<xsd:simpleType>
						<xsd:restriction base="xsd:string">
							<xsl:sequence select="tso:deprecatedEnumerations('ThingClass')"/>
							<xsl:sequence select="tso:additionalEnumerations('ThingClass')"/>
							<xsl:for-each-group select="$nstDatatypes//wholeOntology/Datatype" 
													group-by="@type">
								<xsl:variable name="strDatatype" select="tso:datatype(@type)"/>
								<xsl:if test="$strDatatype = 'string' or $strDatatype = 'NotSpecified' or $strDatatype = 'Annotation property'">
									<xsl:for-each select="current-group()"><xsl:sort select="."/>
										<xsl:if test="not(@value = $nstOmmissions//omitValues[@attributeGroup='ThingClass']/omitValue)">
											<xsd:enumeration value="{@value}">
											<xsl:if test="annotation">
												<xsd:annotation>
													<xsd:documentation>
														<xsl:value-of select="annotation"/>
													</xsd:documentation>
												</xsd:annotation>
											</xsl:if>
										</xsd:enumeration>
										</xsl:if>
									</xsl:for-each>
								</xsl:if>
							</xsl:for-each-group>
						</xsd:restriction>
					</xsd:simpleType>
				</xsd:attribute>
			</xsd:attributeGroup>		
		</xsl:if>

		<!--Generate the ValueClass Attribute group-->
		<xsl:if test="$strClass = 'Value' or $strClass = 'All'">
			<xsd:attributeGroup name="ValueClass">
				<xsd:attribute name="Class" use="required">
					<xsd:annotation>
						<xsd:documentation>Boolean, double and integer datatype properties extracted from the Gazette ontology</xsd:documentation>
					</xsd:annotation>
					<xsd:simpleType>
						<xsd:restriction base="xsd:string">
							<xsl:sequence select="tso:deprecatedEnumerations('ValueClass')"/>
							<xsl:sequence select="tso:additionalEnumerations('ValueClass')"/>
							<xsl:for-each-group select="$nstDatatypes//wholeOntology/Datatype" 
													group-by="@type">
								<xsl:variable name="strDatatype" select="tso:datatype(@type)"/>
								<xsl:if test="$strDatatype = 'boolean' or $strDatatype = 'double'  or $strDatatype = 'integer' or $strDatatype = 'int'">
									<xsl:for-each select="current-group()"><xsl:sort select="."/>
										<xsl:if test="not(@value = $nstOmmissions//omitValues[@attributeGroup='ValueClass']/omitValue)">
											<xsd:enumeration value="{@value}">
											<xsl:if test="annotation">
												<xsd:annotation>
													<xsd:documentation>
														<xsl:value-of select="annotation"/>
													</xsd:documentation>
												</xsd:annotation>
											</xsl:if>
										</xsd:enumeration>
										</xsl:if>
									</xsl:for-each>
								</xsl:if>
							</xsl:for-each-group>
						</xsd:restriction>
					</xsd:simpleType>
				</xsd:attribute>
			</xsd:attributeGroup>		
		</xsl:if>


	
		<!--Generate the ValueClass Attribute group-->
		<xsl:if test="$strClass = 'Predicate' or $strClass = 'All'"><!--<xsl:sequence select="$nstDatatypes"/>-->
			<xsd:attributeGroup name="PredicateClass">
				<xsd:attribute name="Predicate" use="required">
					<xsd:annotation>
						<xsd:documentation>All properties extracted from the Gazette ontology</xsd:documentation>
					</xsd:annotation>
					<xsd:simpleType>
						<xsd:restriction base="xsd:string">
							<xsl:sequence select="tso:deprecatedEnumerations('PredicateClass')"/>
							<xsl:sequence select="tso:additionalEnumerations('PredicateClass')"/>
							<xsl:for-each-group select="$nstDatatypes//wholeOntology/Datatype | $nstDatatypes//wholeOntology/Object" 
													group-by="@type">
								<xsl:variable name="strDatatype" select="tso:datatype(@type)"/>
								<xsl:for-each select="current-group()"><xsl:sort select="."/>
									<xsl:if test="not(@value = $nstOmmissions//omitValues[@attributeGroup='PredicateClass']/omitValue)">
										<xsd:enumeration value="{@value}">
											<xsd:annotation>
												<xsd:documentation>
													<xsl:value-of select="$strDatatype"/>
													<xsl:if test="annotation">
														<xsl:text>: </xsl:text>
														<xsl:value-of select="annotation"/>
													</xsl:if>
												</xsd:documentation>
											</xsd:annotation>
										</xsd:enumeration>
									</xsl:if>
								</xsl:for-each>
							</xsl:for-each-group>
						</xsd:restriction>
					</xsd:simpleType>
				</xsd:attribute>
			</xsd:attributeGroup>		
		</xsl:if>
		</xsd:schema>
	</xsl:template>	
	
	
	<xsl:template match="Files | OntologyDatatypes">
		<xsl:apply-templates/>
	</xsl:template>	
	
	<xsl:template match="ommissions | deprecated | additional" mode="phase-1">
		
	</xsl:template>
	
	
	
	<!-- Apply templates to all properties in the ontology-->
	<xsl:template match="file" mode="phase-1">
		<!--check for a specified filepath to the ontology using the strOntologyPath parameter - if so prepend this to the filename-->
		<xsl:variable name="strFilepath">
			<xsl:choose>
				<xsl:when test="ends-with(translate($strOntologyPath,'\','/'),'/')">
					<xsl:value-of select="translate($strOntologyPath,'\','/')"/><xsl:value-of select="."/>
				</xsl:when>
				<xsl:when test="$strOntologyPath != ''">
					<xsl:value-of select="translate($strOntologyPath,'\','/')"/>/<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:message><xsl:value-of select="$strFilepath"/></xsl:message>
		<xsl:apply-templates select="document($strFilepath)//owl:DatatypeProperty | 
	document($strFilepath)//owl:AnnotationProperty | 
	document($strFilepath)//owl:FunctionalProperty[rdf:type/@rdf:resource='http://www.w3.org/2002/07/owl#DatatypeProperty'] 
	| document($strFilepath)//owl:ObjectProperty
	| document($strFilepath)//owl:FunctionalProperty[rdf:type/@rdf:resource='http://www.w3.org/2002/07/owl#ObjectProperty']
	| document($strFilepath)//rdf:Property" mode="phase-1">
		<xsl:with-param name="strNamespace" select="tso:ontologyName(.)"/>
		</xsl:apply-templates>
	</xsl:template>	
	
	
	
	

	<!-- datatype properties-->
	<xsl:template match="owl:DatatypeProperty | owl:FunctionalProperty[rdf:type/@rdf:resource='http://www.w3.org/2002/07/owl#DatatypeProperty']" mode="phase-1">
		<xsl:param name="strNamespace"/>
		<xsl:if test="child::*">
			<xsl:choose>
				<xsl:when test="@rdf:ID">
					<Datatype type="{rdfs:range/@rdf:resource}" value="{$strNamespace}:{@rdf:ID}">
						<xsl:if test="rdfs:comment">
							<annotation><xsl:value-of select="rdfs:comment"/></annotation>
						</xsl:if>
					</Datatype>
				</xsl:when>
				<xsl:when test="@rdf:about">
					<Datatype type="{rdfs:range/@rdf:resource}" value="{$strNamespace}:{substring-after(@rdf:about,'#')}">
						<xsl:if test="rdfs:comment">
							<annotation><xsl:value-of select="rdfs:comment"/></annotation>
						</xsl:if>
					</Datatype>
				</xsl:when>
				<xsl:otherwise>
				
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	
	<!--FOAF and wgs84_pos use rdf:Property-->
	<xsl:template match="rdf:Property" mode="phase-1">
		<xsl:param name="strNamespace"/>
		<xsl:variable name="comment">
			<xsl:choose>
				<xsl:when test="@rdfs:comment">
					<xsl:value-of select="@rdfs:comment"/>
				</xsl:when>
				<xsl:when test="rdfs:comment">
					<xsl:value-of select="rdfs:comment"/>
				</xsl:when>
				<xsl:otherwise>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="child::*">
			<xsl:choose>
			<xsl:when test="rdf:type/@rdf:resource = 'http://www.w3.org/2002/07/owl#ObjectProperty'">
				<xsl:choose>
					<xsl:when test="@rdf:ID">
						<Object type="Object" value="{$strNamespace}:{@rdf:ID}">
							<xsl:if test="rdfs:comment">
								<annotation><xsl:value-of select="@rdfs:comment"/></annotation>
							</xsl:if>
						</Object>
					</xsl:when>
					<xsl:when test="@rdf:about">
						<Object type="Object" value="{$strNamespace}:{tso:finalSubstring(@rdf:about,'/')}">
							<xsl:if test="$comment != ''">
								<annotation><xsl:value-of select="$comment"/></annotation>
							</xsl:if>
						</Object>
					</xsl:when>
					<xsl:otherwise>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="rdf:type/@rdf:resource = 'http://www.w3.org/2002/07/owl#DatatypeProperty' or not(rdf:type)">
				<xsl:choose>
					<xsl:when test="@rdf:ID">
						<xsl:variable name="strName" select="if (contains(@rdf:ID,'#')) then substring-after(@rdf:ID,'#') else tso:finalSubstring(@rdf:ID,'/') "/>
						<Datatype type="{rdfs:range/@rdf:resource}" value="{$strNamespace}:{$strName}">
							<xsl:if test="rdfs:comment">
								<annotation><xsl:value-of select="@rdfs:comment"/></annotation>
							</xsl:if>
						</Datatype>
					</xsl:when>
					<xsl:when test="@rdf:about">
						<xsl:variable name="strName" select="if (contains(@rdf:about,'#')) then substring-after(@rdf:about,'#') else tso:finalSubstring(@rdf:about,'/') "/>
						<Datatype type="{rdfs:range/@rdf:resource}" value="{$strNamespace}:{$strName}">
							<xsl:if test="$comment != ''">
								<annotation><xsl:value-of select="$comment"/></annotation>
							</xsl:if>
						</Datatype>
					</xsl:when>
					<xsl:otherwise>
					
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			</xsl:choose>
		
		</xsl:if>
	</xsl:template>	
	
	
	<xsl:template match="owl:AnnotationProperty" mode="phase-1">
		<xsl:param name="strNamespace"/>
		<xsl:if test="child::*">
			<xsl:choose>
				<xsl:when test="@rdf:ID">
					<Datatype type="Annotation" value="{$strNamespace}:{@rdf:ID}">
						<xsl:if test="rdfs:comment">
							<annotation><xsl:value-of select="rdfs:comment"/></annotation>
						</xsl:if>
					</Datatype>
				</xsl:when>
				<xsl:when test="@rdf:about">
					<Datatype type="Annotation" value="{$strNamespace}:{substring-after(@rdf:about,'#')}">
						<xsl:if test="rdfs:comment">
							<annotation><xsl:value-of select="rdfs:comment"/></annotation>
						</xsl:if>
					</Datatype>
				</xsl:when>
				<xsl:otherwise>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>	

	<xsl:template match="owl:ObjectProperty | owl:FunctionalProperty[rdf:type/@rdf:resource='http://www.w3.org/2002/07/owl#ObjectProperty']" mode="phase-1">
		<xsl:param name="strNamespace"/>
		<xsl:if test="child::*">
			<xsl:choose>
				<xsl:when test="@rdf:ID">
					<Object type="Object" value="{$strNamespace}:{@rdf:ID}">
						<xsl:if test="rdfs:comment">
							<annotation><xsl:value-of select="rdfs:comment"/></annotation>
						</xsl:if>
					</Object>
				</xsl:when>
				<xsl:when test="@rdf:about">
					<Object type="Object" value="{$strNamespace}:{substring-after(@rdf:about,'#')}">
						<xsl:if test="rdfs:comment">
							<annotation><xsl:value-of select="rdfs:comment"/></annotation>
						</xsl:if>
					</Object>
				</xsl:when>
				<xsl:otherwise>
				
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	
	<!--create the ontology namespace based upon the filename-->
	<xsl:function name="tso:ontologyName" as="xsd:string">
		<xsl:param name="strFile" as="xsd:string"/>
		<!--if the filename is part of a directory listing run it through the tso:finalSubstring -->
		<xsl:variable name="strFilteredFile">
			<xsl:choose>
				<xsl:when test="contains(translate($strFile,'\','/'),'/')">
					<xsl:value-of select="tso:finalSubstring($strFile,'/')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$strFile"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($strFilteredFile,'.owl')">
				<xsl:value-of select="substring-before($strFilteredFile,'.owl')"/>
			</xsl:when>
			<xsl:when test="contains($strFilteredFile,'ontology_v2.0_Lite')">
				<xsl:value-of select="'geoNames'"/>
			</xsl:when>
			<xsl:when test="contains($strFilteredFile,'.rdf')">
				<xsl:value-of select="substring-before($strFilteredFile,'.rdf')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-before($strFilteredFile,'.')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- function for determining the datatype-->
	<xsl:function name="tso:datatype" as="xsd:string">
		<xsl:param name="strType" as="xsd:string"/>
		<xsl:choose>
			<xsl:when test="contains($strType,'#')">
				<xsl:value-of select="substring-after($strType,'#')"/>
			</xsl:when>
			<xsl:when test="$strType = 'Object'">
				<xsl:value-of select="'Object property'"/>
			</xsl:when>
			<xsl:when test="$strType = 'Annotation'">
				<xsl:value-of select="'Annotation property'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>NotSpecified</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>	
	
	<!-- common function for adding deprecated enumerations -->
	<xsl:function name="tso:deprecatedEnumerations">
		<xsl:param name="strAttributeClass" as="xsd:string"/>
		<xsl:for-each select="$nstDeprecated//deprecatedValues[@attributeGroup=$strAttributeClass]/deprecatedValue">
			<xsl:if test=". != ''">
				<xsd:enumeration value="{.}"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>

	<!-- common function for adding additional enumerations -->
	<xsl:function name="tso:additionalEnumerations">
		<xsl:param name="strAttributeClass" as="xsd:string"/>
		<xsl:for-each select="$nstAdditional//additionalValues[@attributeGroup=$strAttributeClass]/additionalValue">
			<xsl:if test=". != ''">
				<xsd:enumeration value="{.}"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>	

	<!-- funstion for finding the last substring after a given character-->
	<!-- In this stylesheet this is used primarily for obtaining the filename from a file/directory listing -->
	<xsl:function name="tso:finalSubstring" as="xsd:string">
		<xsl:param name="strString" as="xsd:string"/>
		<xsl:param name="strCharacter" as="xsd:string"/>
		<xsl:choose>
			<xsl:when test="contains($strString,$strCharacter)">
				<xsl:value-of select="tso:finalSubstring(substring-after($strString,$strCharacter),$strCharacter)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$strString"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	
</xsl:stylesheet>
 
