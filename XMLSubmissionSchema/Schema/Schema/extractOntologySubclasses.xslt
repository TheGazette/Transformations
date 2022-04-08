<!-- Version 1.00 -->
<!-- Created by Griff Chamberlain -->
<!-- Last changed  -->

<!-- Change history
XSLT for finding all subclasses of a superclass in an ontology
use the $superclass param to set the name of the class to interigate
	29/12/2008		Created

 -->

<!-- saxon9 -o classes.xml files.xml extractOntologySubclasses.xslt "strSuperclass=http://www.gazettes-online.co.uk/ontology/organisation#Organisation" -->

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
	xmlns:geo="http://www.geonames.org/ontology#"
	xmlns:time="http://www.w3.org/2006/time#" 
	xmlns:dcterms="http://purl.org/dc/terms/"
	exclude-result-prefixes="tso owl rdf rdfs xsd corp-insolvency personal-legal partnerships transport planning water environment legislation person organisation court authority duration consultation legislation-individuals itc official-receivers courts AdministrativeGeography dc geo time dcterms"
	>

<xsl:output method="xml" version="1.0" indent="yes" />

<!--class to query-->
<xsl:param name="strSuperclass">http://www.gazettes-online.co.uk/ontology/organisation#Organisation</xsl:param>

<!--set whether to include namespace in the output-->
<xsl:param name="strIncludeNamespaceInOutput">false</xsl:param>



	<xsl:template match="/">
		<classes>
			<xsl:namespace name="xsd" select="'http://www.w3.org/2001/XMLSchema'"/>
			<!--create a nodeset of all the classes referenced in the ontology-->
			<xsl:variable name="classes">
				<classes>
					<xsl:for-each select="//file">
						<xsl:apply-templates select="document(.)//owl:Class" mode="bydoc">
							<xsl:with-param name="file" select="tso:ontologyName(.)"/>
							<xsl:sort select="@rdf:ID | @rdf:about"/>
						</xsl:apply-templates>
					</xsl:for-each>
				</classes>
			</xsl:variable>

			<!--determine the unique nodes within the nodeset -->
			<xsl:variable name="nstUniqueClasses">
				<xsl:for-each-group  select="$classes//class" group-by="@name">
					<class name="{@name}">
						<xsl:for-each select="current-group()">
							<xsl:if test="@superclass!=''">
								<superclass><xsl:value-of select="@superclass"></xsl:value-of></superclass>
							</xsl:if>
						</xsl:for-each>
					</class>
				</xsl:for-each-group>
			</xsl:variable>

			<!-- query the nodeset to search back to see if each individual node has a final superclass of that requested-->
			<xsl:choose>
				<xsl:when test="contains($strSuperclass,'#')">
					<xsd:enumeration value="{if ($strIncludeNamespaceInOutput != 'true') then substring-after($strSuperclass,'#') else $strSuperclass}"/>
					<xsl:for-each select="$nstUniqueClasses//class">
						<xsl:call-template name="search">
							<xsl:with-param name="class"><xsl:value-of select="@name"/></xsl:with-param>
							<xsl:with-param name="term"><xsl:value-of select="@name"/></xsl:with-param>
							<xsl:with-param name="searchTerm"><xsl:value-of select="$strSuperclass"/></xsl:with-param>
							<xsl:with-param name="classes" select="$nstUniqueClasses"/>
						</xsl:call-template>
					</xsl:for-each>	
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$nstUniqueClasses"/>
				</xsl:otherwise>
			</xsl:choose>
			
		</classes>
	</xsl:template>

	<xsl:template match="Files">
		<xsl:apply-templates/>
	</xsl:template>	
	

	

	
	
	
	<xsl:template match="file">
		

	</xsl:template>		


	<xsl:template match="owl:Class" mode="bydoc">
		<xsl:param name="file"/>
		<xsl:if test="@rdf:ID | @rdf:about">
		<xsl:variable name="strName" select="@rdf:ID | @rdf:about"/>	
		<xsl:variable name="strNamespace">	
			<xsl:choose>
				<xsl:when test="substring-before($strName,'#')">
					<xsl:value-of select="substring-before($strName,'#')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="base-uri()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="strClass">	
			<xsl:choose>
				<xsl:when test="contains($strName,'#')">
					<xsl:value-of select="substring-after($strName,'#')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$strName"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="strSuperclass">	
			<xsl:choose>
				<xsl:when test="rdfs:subClassOf/owl:Class">
					<xsl:value-of select="rdfs:subClassOf/owl:Class/@*"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="rdfs:subClassOf/@rdf:resource"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="strSuperclassNamespace">	
			<xsl:choose>
				<xsl:when test="substring-before($strSuperclass,'#')">
					<xsl:value-of select="substring-before($strSuperclass,'#')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="base-uri()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="strSuperclassLocalname">	
			<xsl:choose>
				<xsl:when test="contains($strSuperclass,'#')">
					<xsl:value-of select="substring-after($strSuperclass,'#')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$strSuperclass"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<class name="{$strNamespace}#{$strClass}">
			<xsl:if test="$strSuperclassLocalname!=''">
				<xsl:attribute name="superclass">
					<xsl:value-of select="$strSuperclassNamespace"/>#<xsl:value-of select="$strSuperclassLocalname"/>
				</xsl:attribute>
			</xsl:if>
		</class>
		</xsl:if>
	</xsl:template>


	<!--template to loop through the superclasses until the searchterm is found-->	
	<xsl:template name="search">
		<xsl:param name="class"/>
		<xsl:param name="term"/>
		<xsl:param name="searchTerm"/>
		<xsl:param name="classes"/>
		<xsl:choose>
			<xsl:when test="$classes//class[@name = $term][superclass=$searchTerm]">
				<xsl:variable name="strClassname">
					<xsl:choose>
						<xsl:when test="$strIncludeNamespaceInOutput != 'true' and contains($class,'#')">
							<xsl:value-of select="substring-after($class,'#')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$class"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsd:enumeration value="{$strClassname}"></xsd:enumeration>
			</xsl:when>
			<xsl:when test="$classes//class[@name = $term][superclass!=$searchTerm] and $classes//class[@name = $term][superclass]">
				<xsl:call-template name="search">
					<xsl:with-param name="class"><xsl:value-of select="$class"/></xsl:with-param>
					<xsl:with-param name="term"><xsl:value-of select="$classes//class[@name = $term]/superclass"/></xsl:with-param>
					<xsl:with-param name="searchTerm"><xsl:value-of select="$searchTerm"/></xsl:with-param>
					<xsl:with-param name="classes" select="$classes"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
<xsl:function name="tso:ontologyName">
	<xsl:param name="file"/>
	<xsl:choose>
		<xsl:when test="contains($file,'.owl')">
			<xsl:value-of select="substring-before($file,'.owl')"/>
		</xsl:when>
		<xsl:when test="contains($file,'ontology_v2.0_Lite')">
			<xsl:value-of select="'geoNames'"/>
		</xsl:when>
		<xsl:when test="contains($file,'.rdf')">
			<xsl:value-of select="substring-before($file,'.rdf')"/>
		</xsl:when>
		<xsl:otherwise>
		
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
	
</xsl:stylesheet>
 
