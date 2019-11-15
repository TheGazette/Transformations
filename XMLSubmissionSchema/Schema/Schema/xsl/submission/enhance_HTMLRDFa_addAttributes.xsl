<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <!-- Version 1.00 --><!-- Created by Yashashri Rane--><!-- Last changed on 01/04/2013  by Yashashri Rane --><!--
	Change history	
	1.01	01/04/2013  (Yashashri Rane)updated to change span info
	1.01	01/02/2013  (Yashashri Rane)added default namespace
	1.00	28/01/2013	Created
	--><!-- This transformation is used for adding extra index attribures to HTML RDFa--><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gz="http://www.tso.co.uk/assets/namespace/gazette" xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata" xmlns:wgs84="http://www.w3.org/2003/01/geo/wgs84_pos" xmlns:person-legal="http://www.gazettes-online.co.uk/ontology/personal-legal" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:personal-legal="http://www.gazettes-online.co.uk/ontology/personal-legal" xmlns:foaf="http://www.gazettes-online.co.uk/ontology/foaf" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:gzc="http://www.tso.co.uk/assets/namespace/gazette/LGconfiguration" exclude-result-prefixes="xs" version="2.0" xpath-default-namespace="http://www.w3.org/1999/xhtml">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 28, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b>Raney001</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>       
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="article/span">
        <xsl:copy> 
            <xsl:choose>
                <xsl:when test="@property ='gaz:hasPublicationDate'">
                    <xsl:attribute name="gz:hasPublicationDate" select="@content"/>
                </xsl:when>
                <xsl:when test="@property ='gaz:hasNoticeCode'">
                    <xsl:attribute name="gz:hasNoticeCode" select="@content"/>
                </xsl:when>
                <xsl:when test="@property ='gaz:hasEdition'">
                    <xsl:attribute name="gz:hasEdition" select="@content"/>
                </xsl:when>
                <xsl:when test="@property ='gaz:hasIssueNumber'">
                    <xsl:attribute name="gz:hasIssueNumber" select="@content"/>
                </xsl:when>
                <xsl:when test="@property ='gaz:hasNoticeNumber'">
                    <xsl:attribute name="gz:hasNoticeNumber" select="@content"/>
                </xsl:when>
                <xsl:when test="@property ='personal-legal:bornOn'">
                    <xsl:attribute name="personal-legal:bornOn" select="@content"/>
                </xsl:when>
                <xsl:when test="@property ='personal-legal:diedOn'">
                    <xsl:attribute name="personal-legal:diedOn" select="@content"/>
                </xsl:when>
                <xsl:when test="@property ='gaz:hasClaimDeadline'">
                    <xsl:attribute name="gz:hasClaimDeadline" select="@content"/>
                </xsl:when>
            </xsl:choose>    
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()" priority="1">
        <xsl:value-of select="replace(.,'\s+',' ')" disable-output-escaping="no"/>    
    </xsl:template>
</xsl:stylesheet>