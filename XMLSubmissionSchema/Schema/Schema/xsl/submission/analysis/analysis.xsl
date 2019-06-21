<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->
   <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="#all">

  <xsl:output method="xml" encoding="UTF-8"/>

  <xsl:template match="/">
    <validationReport>
      <xsl:choose>
        <xsl:when test="*:html">
          <xsl:apply-templates select="*:html"/>
        </xsl:when>
        <xsl:otherwise>
         <invalid>
           <entry>          
             <error severity="fail">No HTML tag detected - aborting</error>
           </entry>  
         </invalid> 
        </xsl:otherwise>
      </xsl:choose>
    </validationReport>
  </xsl:template>

  <xsl:template match="*:html">
    <invalid>
      <xsl:if test="not(*:head)">
        <item about="head">
          <entry>
            <msg>head tag not detected</msg>
          </entry>
        </item>
      </xsl:if>
      <xsl:if test="not(*:body)">
        <item about="body">
          <entry>
            <msg>body tag not detected</msg>
          </entry>
        </item>
      </xsl:if>
      <xsl:if test="not(*:body/*:article)">
        <item about="body/article">
          <entry>
            <msg>article tag not detected as immediate child of body tag</msg>
            <xpath>
              <xsl:text>not(*:body/*:article)</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>
      <xsl:if test="not(*:body/*:article/*:div[@class='rdfa-data'])">
        <item about="body/article/div">
          <entry>
            <msg>article must have a child div with the class 'rdfa-data'</msg>
            <xpath>
              <xsl:text>not(*:body/*:article/*:div[@class='rdfa-data'])</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>
      <xsl:if test="not(*:body/*:article/*:dl[@class='metadata'])">
        <item about="body/article/dl">
          <entry>
            <msg>article must have a child dl with the class 'metadata'</msg>
            <xpath>
              <xsl:text>not(*:body/*:article/*:dl[@class='metadata'])</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>
      <xsl:if test="*:body/*:article/*:dl[not(@class='metadata')]">
        <item about="body/article/dl">
          <entry>
            <msg>the dl that is a child of the article tag must have a class of 'metadata'</msg>
            <xpath>
              <xsl:text>*:body/*:article/*:dl[not(@class='metadata')]</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>
      <xsl:if test="not(*:body/*:article/*:div[@class='content'])">
        <item about="body/article/div">
          <entry>
            <msg>article must have a child div with the class 'content'</msg>
            <xpath>
              <xsl:text>not(*:body/*:article/*:div[@class='content'])</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>
      <xsl:if test="*:body/*:article/*[not(local-name() = 'div') and not(local-name() = 'dl')]">
        <item about="body/article/div">
          <entry>
            <msg>only div and dl elements are allowed as children of an article</msg>
            <xpath>
              <xsl:text>body/article/*[not(local-name() = 'div') and not(local-name() = 'dl')]</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>
      <xsl:if test="*:body/*:article/*:div[not(@class=('rdfa-data','content'))]">
        <item about="body/article/div">
          <entry>
            <msg>divs that are children of the article tag must have either class 'rdfa-data' or class 'content'</msg>
            <xpath>
              <xsl:text>body/article/div[not(@class=('rdfa-data','content'))]</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>
      <xsl:if test=".//*:script">
        <item about="script">
          <entry>
            <msg>script tags are not allowed</msg>
            <xpath>
              <xsl:text>.//*:script</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>
      <xsl:if test=".//*:noscript">
        <item about="noscript">
          <entry>
            <msg>noscript tags are not allowed</msg>
            <xpath>
              <xsl:text>.//*:noscript</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>
      <xsl:if test=".//*:noscript">
        <item about="noscript">
          <entry>
            <msg>noscript tags are not allowed</msg>
            <xpath>
              <xsl:text>.//*:noscript</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>
      <xsl:if test=".//*/@style">
        <item about="style">
          <entry>
            <msg>style attributes are not allowed on any element</msg>
            <xpath>
              <xsl:text>.//*/@style</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>

      <!-- limiting contents -->
      <xsl:if test="*:body/*:article/*:div[@class='rdfa-data']/*[not(local-name() = 'span')]">
        <item about="body/article/div">
          <entry>
            <msg>only spans are allowed as children of the div with class rdfa-data</msg>
            <xpath>
              <xsl:text>body/article/div[@class='rdfa-data']/*[not(local-name() = 'span')]</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>

      <xsl:if test="*:body/*:article/*:div[@class='rdfa-data']/*:span/text() != ''">
        <item about="body/article/div">
          <entry>
            <msg>spans inside the div with class of 'rdfa-data' should not contain any text content</msg>
            <xpath>
              <xsl:text>body/article/div[@class='rdfa-data']/span/text() != ''</xsl:text>
            </xpath>
          </entry>
        </item>        
      </xsl:if>

      <!-- counting things -->

      <xsl:if test="count(*:body/*:article/*:div[@class='content']) &gt; 1">
        <item about="body/article/div">
          <entry>
            <msg>there can be only one div with class of content</msg>
            <xpath>
              <xsl:text>count(body/article/div[@class='content']) &gt; 1</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>

      <xsl:if test="count(*:body/*:article/*:div[@class='rdfa-data']) &gt; 1">
        <item about="body/article/div">
          <entry>
            <msg>there can be only one div with class of rdfa-data</msg>
            <xpath>
              <xsl:text>count(body/article/div[@class='rdfa-data']) &gt; 1</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>

      <xsl:if test="count(*:body/*:article/*:dl[@class='metadata']) &gt; 1">
        <item about="body/article/dl">
          <entry>
            <msg>there can be only one dl with class of metadata</msg>
            <xpath>
              <xsl:text>count(body/article/dl[@class='metadata']) &gt; 1</xsl:text>
            </xpath>
          </entry>
        </item>
      </xsl:if>

    </invalid>
  </xsl:template>

</xsl:stylesheet>