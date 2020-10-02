<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <!--
    Takes in pre/post 2005 2093 notices and enriches them for Marklogic. 
    
    Enriches the gazette metadata for extra elements that ML needs from the RDFa
    
    Due to the random nature of the RDF on a notice to notice basis we have to do lots
    of jumping about to navigate the data and emit some structure
    
    Graph (RDF) -> Tree (XML)
    
    --><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:personal-legal="http://data.gazettes.co.uk/def/personal-legal" xmlns:wgs84="http://www.w3.org/2003/01/geo/wgs84_pos" xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata" xmlns:gz="http://www.tso.co.uk/assets/namespace/gazette" xmlns:local="local" xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="dl" select="/html/body/article/dl"/>
    <xsl:variable name="rdfa" select="/html/body/article/div[@class='rdfa-data']/span"/>
    
    <!--
        Various util functions for easy access to the RDF
        
        -->    
    <xsl:function name="local:content">
        <xsl:param name="str" as="xs:string*"/>
        <xsl:variable name="flattened" select="normalize-space(string-join($str,''))"/>
        <xsl:value-of select="if (contains($flattened,'^^')) then substring-before($flattened,'^^') else $flattened"/>
    </xsl:function>

    <xsl:function name="local:find">
        <xsl:param name="about"/>
        <xsl:param name="prop"/>
        <xsl:value-of select="local:content($rdfa[@about=$about][@property=$prop]/(text()|@content|@resource))"/>        
    </xsl:function>
    
    <xsl:function name="local:typeof">
        <xsl:param name="typeof"/>        
        <xsl:value-of select="local:content($rdfa[@typeof=$typeof]/(@content|@resource))"/>        
    </xsl:function>
    
    <xsl:function name="local:property">
        <xsl:param name="property"/>        
        <xsl:value-of select="local:content($rdfa[@property=$property]/(@about))"/>        
    </xsl:function>
    
    <!--
        Useful for turning RDF camelcase to dash separated words
        Currently used to the address template to create specific 
        element block names
        -->
    <xsl:function name="local:camel-case-to-words" as="xs:string">
        <xsl:param name="a" as="xs:string?"/>                 
        <xsl:value-of select="if (matches($a,'[a-z]')) then lower-case(replace($a,'[A-Z]','-$0')) else lower-case($a)"/>        
    </xsl:function>

   <!-- 
    Copy through XML by default unless we have more specific templates
    -->
    <xsl:template match="@* | node()">                
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!--
        Address handling, called from the main gazette-metadata template                 
        -->
    <xsl:template xmlns="http://www.gazettes.co.uk/metadata" name="address">
        <xsl:param name="about" select="."/>
        <xsl:if test="$dl//*[@about=$about]">
            <xsl:element name="{replace(local:camel-case-to-words(substring-after($about,':')),'-\d+$','')}">
                <xsl:variable name="geo" as="node()">
                 <geo-spatial>
                    <longitude><xsl:value-of select="local:find($about,'http://www.w3.org/2003/01/geo/wgs84_pos#long')"/></longitude>
                    <latitude><xsl:value-of select="local:find($about,'http://www.w3.org/2003/01/geo/wgs84_pos#lat')"/></latitude>                                                               
                 </geo-spatial>                    
                </xsl:variable>
                <xsl:if test="$geo!=''">
                    <xsl:copy-of select="$geo"/>
                </xsl:if>
                <xsl:variable name="district" select="local:find($about,'http://data.ordnancesurvey.co.uk/ontology/postcode/district')"/>
                <xsl:if test="$district!=''">
                 <district><xsl:value-of select="local:find($district,'http://www.w3.org/2000/01/rdf-schema#label')"/></district>
                </xsl:if>
                <address><xsl:value-of select="$dl//*[@about=$about][@property='vcard:address']"/></address>                
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="gazette-metadata" xpath-default-namespace="http://www.gazettes.co.uk/metadata">
        <xsl:copy xmlns="http://www.gazettes.co.uk/metadata">           
            <xsl:apply-templates select="@* | node()"/>             
            <claim-deadline-date><xsl:value-of select="$dl//*[@property='personal-legal:hasClaimDeadline']/@content"/></claim-deadline-date>
            <death-date><xsl:value-of select="$dl//*[@property='personal-legal:dateOfDeath']/@content"/></death-date>
            <posted-date><xsl:value-of select="$dl//*[@property='gaz:hasPublicationDate dc:issued']/@content"/></posted-date>
            <xsl:variable name="address-of-deceased-name" select="local:find('this:deceasedPerson','person:hasAddress')"/>        
            <xsl:for-each select="('this:addressOfAdministrator',$address-of-deceased-name)">
                <xsl:call-template name="address"/>                    
            </xsl:for-each>             
            <full-name><xsl:value-of select="$rdfa[@property='foaf:name']/@content"/></full-name>            
            <surname><xsl:value-of select="$dl//*[@property='foaf:familyName']"/></surname>
            <first-name><xsl:value-of select="$dl//*[@property='foaf:firstName']"/></first-name>
            <xsl:if test="$dl//*[@property='foaf:givenName']">
             <given-name><xsl:value-of select="$dl//*[@property='foaf:givenName']"/></given-name>
            </xsl:if>
            <notice>
                <publisher><xsl:value-of select="$rdfa[@property='dc11:publisher']/@content"/></publisher>
                <is-required-by-legislation><xsl:value-of select="local:find('this:notifiableThing','gaz:isRequiredByLegislation')"/></is-required-by-legislation>
            </notice>
            <executor>
                <xsl:for-each select="('this:addressOfExecutor')">
                    <xsl:call-template name="address"/>                    
                </xsl:for-each>
                <name><xsl:value-of select="$dl//*[@about='this:estateExecutor'][@property='foaf:name']"/></name>
            </executor>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>