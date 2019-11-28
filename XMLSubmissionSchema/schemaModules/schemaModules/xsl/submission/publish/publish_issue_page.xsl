<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:gzm="http://www.gazettes.co.uk/metadata"
  xmlns:x="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  version="2.0" exclude-result-prefixes="#all">
  
  <xsl:param name="issueNumber" as="xs:string" required="yes" />
  <xsl:param name="issue-isbn" as="xs:string" required="yes"/>
  <xsl:param name="print-publication-date" as="xs:dateTime" required="yes" />
  <xsl:param name="pageNumber" as="xs:string" required="yes"/>
  
  
  <xsl:output exclude-result-prefixes="#all" indent="no"/>
  <xsl:variable name="gaz">https://www.thegazette.co.uk/</xsl:variable>
  <xsl:variable name="edition" select="//gzm:edition"/>
  <xsl:variable name="noticeNo">
    <xsl:choose>
      <xsl:when test="//gzm:legacy-notice-number">
        <xsl:apply-templates select="//gzm:legacy-notice-number"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="noticeId" select="//gzm:notice-id"/>
  <xsl:variable name="oldNoticeURI" select="concat($gaz,'id/','edition/',$edition,'/issue/',$issueNumber,'/notice/', $noticeNo)"/>
  <xsl:variable name="issueURI" select="concat($gaz,'id/','edition/',$edition,'/issue/',$issueNumber)"/>
  <xsl:variable name="editionURI" select="concat($gaz,'id/','edition/',$edition)"/>
  <xsl:variable name="noticeURI" select="concat($gaz,'id','/notice/', $noticeId)"/>
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="x:html">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="x:head">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="x:meta | x:title">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match = "gzm:gazette-metadata">
    <gazette-metadata xmlns="http://www.gazettes.co.uk/metadata">
    <xsl:apply-templates/>
     <xsl:if test="not(.//gzm:issue)">
      <issue><xsl:value-of select="$issueNumber"/></issue>
    </xsl:if>
    <xsl:if test="not(.//gzm:page-number)">
      <page-number><xsl:value-of select="$pageNumber"/></page-number>
    </xsl:if>
    <xsl:if test="not(gzm:issue-isbn)">
      <issue-isbn>
        <xsl:value-of select="$issue-isbn" />
      </issue-isbn>
    </xsl:if>
    <xsl:if test="not(gzm:print-publication-date)">
      <print-publication-date>
        <xsl:value-of select="$print-publication-date" />
      </print-publication-date>
    </xsl:if>
    </gazette-metadata>
  </xsl:template>
  
  <xsl:template match="gzm:*[not(name()= ('issue','page-number','issue-isbn','print-publication-date','gazette-metadata'))]">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="gzm:issue">
    <xsl:copy><xsl:value-of select="$issueNumber"/></xsl:copy>
    </xsl:template>
     
  <xsl:template match="gzm:page-number">
    <xsl:copy><xsl:value-of select="$pageNumber"/></xsl:copy>
  </xsl:template>
  
  <xsl:template match="gzm:issue-isbn">
    <xsl:copy><xsl:value-of select="$issue-isbn"/></xsl:copy>
  </xsl:template>
  
  <xsl:template match="gzm:print-publication-date">
    <xsl:copy><xsl:value-of select="$print-publication-date"/></xsl:copy>
  </xsl:template>
  
  <xsl:template match="x:body">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="x:article">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
   
  <xsl:template match="x:img">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="x:section">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="x:div[@class='rdfa-data']">
   <div class="rdfa-data">
     <xsl:copy-of select="(@* | *) except 
       (*[@property = ('gaz:hasEdition','gaz:hasIssueNumber','owl:sameAs','prov:alternateOf','gaz:isInIssue')] , *[@typeof = ('gaz:Edition','gaz:Issue')])"/>
    <span resource="{$issueURI}" typeof="gaz:Issue"/>
    <span about="{$issueURI}" property="gaz:hasEdition" resource="{$editionURI}"/>
    <span about="{$issueURI}" content="{$issueNumber}" datatype="xsd:string" property="gaz:hasIssueNumber"/>
    <span resource="{$editionURI}" typeof="gaz:Edition"/>
    <span about="{$noticeURI}" property="gaz:isInIssue" resource="{$issueURI}"/>
    <span about="https://www.thegazette.co.uk/id/notice/{$noticeId}" property="owl:sameAs" 
      resource="https://www.thegazette.co.uk/id/edition/{$edition}/issue/{$issueNumber}/notice/{if ($noticeNo != '') then $noticeNo else $noticeId }" 
      typeof="gaz:Notice"/>
    <span about="https://www.thegazette.co.uk/id/notice/{$noticeId}" property="prov:alternateOf" 
      resource="http://www.{lower-case($edition)}-gazette.co.uk/id/issues/{$issueNumber}/notices/{if ($noticeNo != '') then $noticeNo else $noticeId }" 
      typeof="gaz:Notice"/>
   </div>
  </xsl:template>
  
  <xsl:template match="x:div">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="x:dl[@class='metadata']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="* except 
        (x:dt[. = ('Issue number:','Page number:')],
        x:dd[preceding-sibling::*[1][self::x:dt] = ('Issue number:','Page number:')]) "/>
      <dt>Issue number:</dt>
      <dd about="{$issueURI}" property="gaz:hasIssueNumber" datatype="xsd:string"><xsl:value-of select="$issueNumber"/></dd>
      <dt>Page number:</dt>
      <dd about="{$noticeURI}" property="gaz:hasPageNumber" datatype="xsd:string"><xsl:value-of select="$pageNumber"/></dd>
    </xsl:copy>
  </xsl:template>
  

  
  <xsl:template match="x:dt">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="x:dd">
    <xsl:copy-of select="."/>
  </xsl:template>
  
</xsl:stylesheet>