<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns="http://www.gazettes.co.uk/assets/taxonomy" xmlns:tax="http://www.gazettes.co.uk/assets/taxonomy" xmlns:cc="http://www.tso.co.uk/assets/namespace/gazette/config" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="#all">
  <xsl:param name="privileges" as="node()" select="doc('privileges.xml')"/>
  <xsl:param name="categoriesOnly" as="xs:boolean"/>
  
  <xsl:output encoding="UTF-8" indent="yes"/>
  
  <xsl:strip-space elements="*"/>
  
  <xsl:template match="/">
     
   <notice-taxonomy>
	
      <xsl:apply-templates/>
		  <xsl:if test="not(exists(/*[local-name() = 'notice-taxonomy']/*[local-name() = 'notice-type'][@level='category']))">
	  		<xsl:apply-templates select="*[local-name() = 'notice-type'][@level='section']" mode="copy"/>
	  	  </xsl:if>
	  </notice-taxonomy>
    
  </xsl:template>
  
  <xsl:template match="*[local-name() = 'notice-type'][@level='category']">
  	  <xsl:variable name="tree" select="."/>
	  <xsl:variable name="codeps" select="$privileges//privilege[matches(.,  ':[0-9]+$')]/substring-after(., ':')"/> 
      <xsl:if test="$codeps != ''">
          <xsl:if test="$tree//*[@code = $codeps]">
            <xsl:element name="notice-type">
              <xsl:copy-of select="$tree/@*"/>
			  <xsl:apply-templates select="$tree" mode="copy"/>
			 </xsl:element>
          </xsl:if>
			  
      </xsl:if>
	  
  </xsl:template>
  
  <xsl:template match="*[local-name() = 'notice-type'][@level='section']" mode="copy">
    <xsl:variable name="this" select="."/>
	<xsl:variable name="codeps" select="$privileges//privilege[matches(.,  ':[0-9]+$')]/substring-after(., ':')"/> 
    <xsl:if test="$this//*[local-name() = 'notice-type'][@code = $codeps] and not($categoriesOnly)">
        <xsl:element name="notice-type">
          <xsl:copy-of select="$this/@*"/>
          <xsl:apply-templates select="$this/*" mode="copy"/>
        </xsl:element>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[local-name() = 'notice-type'][@level='notice']" mode="copy">
    <xsl:variable name="this" select="."/>
    <xsl:variable name="localcode" select="@code"/>
	<xsl:variable name="codeps" select="$privileges//privilege[matches(.,  ':[0-9]+$')]/substring-after(., ':')"/> 
      <xsl:if test="$localcode = $codeps and not($categoriesOnly)">
        <xsl:element name="notice-type">
          <xsl:copy-of select="$this/@*"/>
        </xsl:element>
      </xsl:if>
  </xsl:template>
  
  
</xsl:stylesheet>