<?xml version="1.0" encoding="UTF-8"?>
  <!--©  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/-->

<!--Version 1.0-->
<!--Created by Williams Lea XML Team-->
<!--
	  Purpose of transform: transform legacy post-2005 format XML format to HTML-RDFa
	  
      Change history
      1.0 Initial Release: 20th January 2014
-->

  <!-- ############################################ -->
  <!-- ##### FROM POST-2005 XML TO XHTML5RDFa ##### -->
  <!-- ############################################ -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gz="http://www.tso.co.uk/assets/namespace/gazette" xmlns:ukm="http://www.tso.co.uk/assets/namespace/metadata" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:gzc="http://www.tso.co.uk/assets/namespace/gazette/LGconfiguration" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:wlf="http://www.williamslea.com/xsl/functions" xmlns:t="urn:templates" xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="owlClasses.xsl"/>
    <xsl:output method="xml" omit-xml-declaration="no" indent="no" exclude-result-prefixes="#all" encoding="utf-8"/>

    <!-- xsl:strip-space elements="*"/ -->
    <xsl:param name="issueNumber" required="no"/>
    <xsl:param name="pageNumber" as="xs:string">0</xsl:param>
    <xsl:param name="edition" as="xs:string"/>
    <xsl:param name="bundleId" required="no">0</xsl:param>
    <xsl:param name="noticeId" as="xs:string" required="no">0</xsl:param>
    <xsl:param name="status" as="xs:string" required="no">0</xsl:param>
    <xsl:param name="version-count" as="xs:string" required="no">0</xsl:param>
    <xsl:param name="user-submitted" as="xs:string" required="no">0</xsl:param>
    <xsl:param name="submitted-date" as="xs:dateTime" required="no">
        <xsl:value-of select="current-dateTime()"/>
    </xsl:param>
    <xsl:param name="issue-isbn" as="xs:string" required="no">0</xsl:param>
    <xsl:param name="organisationId" as="xs:string" required="no">0</xsl:param>
    <xsl:param name="isCompanyLawNotice" as="xs:boolean" select="false()"/>
    <xsl:param name="debug">false</xsl:param>
    <xsl:param name="mapping" as="node()" select="doc('')"/>
    <xsl:param name="legislationMapping" as="node()" select="doc('')"/>
    <xsl:variable name="noticeCode" select="//gz:Notice/@Type"/>
    <xsl:variable name="vHTMLcompatible" select="false()" as="xs:boolean"/>
    <!--Birthday Honours-->
    <xsl:variable name="crownDependancy" select="gz:Notice//gz:CrownDependency"/>
    <xsl:variable name="workplace" select="//gz:Notice//gz:Workplace"/>
    <xsl:variable name="OccupationPosition" select="//gz:Notice//gz:OccupationPosition"/>
    <xsl:variable name="Occupation" select="//gz:Notice//gz:Occupation"/>
    <xsl:variable name="department" select="gz:Notice//gz:Department"/>
    <xsl:variable name="rank" select="gz:Notice//gz:Rank"/>
    <xsl:variable name="companyNumber" select="gz:Notice//gz:CompanyNumber"/>
    <xsl:variable name="honour">
        <xsl:choose>
            <xsl:when test="$noticeCode='1122'">KnightBatchelor</xsl:when>
            <xsl:when test="$noticeCode='1123'">
                <xsl:choose>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='G.C.B.'">KnightGrandCrossOrderOfBath</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='D.C.B.'">DameCommmanderOrderOfBath</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='K.C.B.'">KnightCommmanderOrderOfBath</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='C.B.'">CompanionOrderOfBath</xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$noticeCode='1124'">
                <xsl:choose>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='G.C.M.G.'">DameGrandCrossOrderOfStMichaelAndStGeorge</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='D.C.M.G.'">DameCommanderOrderOfStMichaelAndStGeorge</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='K.C.M.G.'">KnightCommanderOrderOfStMichaelAndStGeorge</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='C.M.G.'">CompanionOrderOfStMichaelAndStGeorge</xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$noticeCode='1125'">
                <xsl:choose>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='G.C.V.O.'">DameGrandCrossVictorianOrder</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='D.C.V.O.'">DameCommanderVictorianOrder</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='K.C.V.O.'">KnightCommanderVictorianOrder</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='C.V.O.'">CommanderVictorianOrder</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='L.V.O.'">LieutenantVictorianOrder</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='M.V.O.'">MemberVictorianOrder</xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$noticeCode='1128'">CompanionOrderOfTheCompanionsOfHonour</xsl:when>
            <xsl:when test="$noticeCode='1129'">
                <xsl:choose>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='G.B.E.'">KnightGrandCrossOrderOfTheBritishEmpire</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='D.B.E.'">DameCommanderOrderOfTheBritishEmpire</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='K.B.E.'">KnightCommanderOrderOfTheBritishEmpire</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='C.B.E.'">CommanderOrderOfTheBritishEmpire</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='O.B.E.'">OfficerOrderOfTheBritishEmpire</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='M.B.E.'">MemberOrderOfTheBritishEmpire</xsl:when>
                </xsl:choose>
            </xsl:when>
            <!--<xsl:when test="$noticeCode='1130'">
      <xsl:choose>
       <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='G.B.E.'">DameGrandCrossOrderOfTheBritishEmpir</xsl:when>     
       <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='D.B.E.'">DameCommanderOrderOfTheBritishEmpire</xsl:when>
       <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='K.B.E.'">KnightCommanderOrderOfTheBritishEmpire</xsl:when>
       <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='C.B.E.'">CommanderOrderOfTheBritishEmpire</xsl:when>
       <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='O.B.E.'">OfficerOrderOfTheBritishEmpire</xsl:when>
       <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='M.B.E.'">MemberOrderOfTheBritishEmpire</xsl:when>
      </xsl:choose>
    </xsl:when>-->
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="honourShortName">
        <xsl:choose>
            <xsl:when test="$noticeCode='1122'">Kt</xsl:when>
            <xsl:when test="$noticeCode='1123'">
                <xsl:choose>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='G.C.B.'">GCB</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='D.C.B.'">DCB</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='K.C.B.'">KCB</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='C.B.'">CB</xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$noticeCode='1124'">
                <xsl:choose>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='G.C.M.G.'">GCMG</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='D.C.M.G.'">DCMG</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='K.C.M.G.'">KCMG</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='C.M.G.'">CMG</xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$noticeCode='1125'">
                <xsl:choose>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='G.C.V.O.'">GCVO</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='D.C.V.O.'">DCVO</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='K.C.V.O.'">KCVO</xsl:when>
                    <!--this value is not provided into the documentation. needs to be updated later-->
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='C.V.O.'">CVO</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='L.V.O.'">LVO</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='M.V.O.'">MVO</xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$noticeCode='1128'">CH</xsl:when>
            <xsl:when test="$noticeCode='1129'">
                <xsl:choose>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='G.B.E.'">GBE</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='D.B.E.'">DBE</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='K.B.E.'">KBE</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='C.B.E.'">CBE</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='O.B.E.'">OBE</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='M.B.E.'">MBE</xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$noticeCode='1127'">RVM</xsl:when>
            <xsl:when test="$noticeCode='1130'">BEM</xsl:when>
            <xsl:when test="$noticeCode='1131'">
                <xsl:choose>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='R.R.C.'">RRC</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='A.R.R.C.'">ARRC</xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$noticeCode='1132'">QPM</xsl:when>
            <xsl:when test="$noticeCode='1133'">QFSM</xsl:when>
            <xsl:when test="$noticeCode='1134'">QAM</xsl:when>
            <xsl:when test="$noticeCode='1135'">QVRM</xsl:when>
            <xsl:when test="$noticeCode='1136'">OTPFM</xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="order">
        <xsl:choose>
            <xsl:when test="$noticeCode='1123'">TheMostHonourableOrderOfTheBath</xsl:when>
            <xsl:when test="$noticeCode='1124'">TheOrderOfStMichaelAndStGeorge</xsl:when>
            <xsl:when test="$noticeCode='1125'">TheRoyalVictorianOrder</xsl:when>
            <xsl:when test="$noticeCode='1126'">TheRoyalVictorianOrder</xsl:when>
            <xsl:when test="$noticeCode='1127'">TheRoyalVictorianOrder</xsl:when>
            <xsl:when test="$noticeCode='1128'">TheOrderOfTheCompanionsOfHonour</xsl:when>
            <xsl:when test="$noticeCode='1129'">TheOrderOfTheBritishEmpire</xsl:when>
            <xsl:when test="$noticeCode='1130'">TheOrderOfTheBritishEmpire</xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="medal">
        <xsl:choose>
            <xsl:when test="$noticeCode='1127'">
                <xsl:choose>
                    <xsl:when test="contains(gz:Notice//gz:P/gz:AwardType,'Gold')">RoyalVictorianMedalGold</xsl:when>
                    <xsl:when test="contains(gz:Notice//gz:P/gz:AwardType,'Bronze')">RoyalVictorianMedalBronze</xsl:when>
                    <xsl:when test="contains(gz:Notice//gz:P/gz:AwardType,'Silver')">RoyalVictorianMedalSilver</xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$noticeCode='1130'">BritishEmpireMedal</xsl:when>
            <xsl:when test="$noticeCode='1131'">
                <xsl:choose>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='R.R.C.'">MemberRoyalRedCross</xsl:when>
                    <xsl:when test="normalize-space(//gz:Notice/gz:Honour)='A.R.R.C.'">AssociateRoyalRedCross</xsl:when>
                    <xsl:otherwise>RoyalRedCross</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$noticeCode='1132'">QueensPoliceMedal</xsl:when>
            <xsl:when test="$noticeCode='1133'">QueensFireServiceMedal</xsl:when>
            <xsl:when test="$noticeCode='1134'">QueensAmbulanceServiceMedal</xsl:when>
            <xsl:when test="$noticeCode='1135'">QueensVolunteerReservesMedal</xsl:when>
            <xsl:when test="$noticeCode='1136'">OverseasTerritoriesPoliceFireServiceMedal</xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bar">
        <xsl:choose>
            <xsl:when test="$noticeCode='1126'">
                <xsl:choose>
                    <xsl:when test="contains(gz:Notice//gz:P/gz:AwardType,'Gold')">RoyalVictorianMedalGold</xsl:when>
                    <xsl:when test="contains(gz:Notice//gz:P/gz:AwardType,'Bronze')">RoyalVictorianMedalBronze</xsl:when>
                    <xsl:when test="contains(gz:Notice//gz:P/gz:AwardType,'Silver')">RoyalVictorianMedalSilver</xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="awardType">
        <xsl:choose>
            <xsl:when test="$noticeCode= ('1126','1127')">
                <xsl:choose>
                    <xsl:when test="contains(gz:Notice//gz:P/gz:AwardType,'Gold')">Gold</xsl:when>
                    <xsl:when test="contains(gz:Notice//gz:P/gz:AwardType,'Bronze')">Bronze</xsl:when>
                    <xsl:when test="contains(gz:Notice//gz:P/gz:AwardType,'Silver')">Silver</xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:function name="wlf:generateXPath" as="xs:string">
        <xsl:param name="pNode" as="node()"/>
        <xsl:for-each select="$pNode/ancestor::*">
            <xsl:value-of select="name()"/>
        </xsl:for-each>
        <xsl:value-of select="name($pNode)"/>
    </xsl:function>

    <!-- Functions used to manipulate RDFa content data. -->
    <xsl:function name="wlf:name">
        <xsl:param name="source"/>
        <xsl:variable name="prefix">this:</xsl:variable>
        <xsl:variable name="content" select="$source/text()" as="xs:string"/>
        <xsl:variable name="clean" select="replace(replace(replace(replace(replace($content,' ',''),'\.',''),'’',''),'‘',''),',','')"/>
        <xsl:value-of select="concat($prefix,$clean)"/>
    </xsl:function>

    <xsl:function name="wlf:clean">
        <xsl:param name="source"/>
        <xsl:variable name="prefix">this:</xsl:variable>
        <!-- xsl:variable name="clean" select="replace(replace(replace(replace(replace($source,' ',''),'\.',''),'’',''),'‘',''),',','')"/ -->
        <xsl:variable name="clean" select="replace($source,'[^A-Za-z0-9_-]','')"/>
        <xsl:value-of select="concat($prefix,$clean)"/>
    </xsl:function>

    <xsl:function name="wlf:name-sibling">
        <xsl:param name="source"/>
        <xsl:variable name="namespace">this:</xsl:variable>
        <xsl:variable name="prefix">
            <xsl:value-of select="$source/name()"/>
        </xsl:variable>
        <xsl:variable name="thiscount">
            <xsl:value-of select="concat('-',count($source/preceding-sibling::*[name()=$source/name()]) + 1)"/>
        </xsl:variable>
        <xsl:variable name="name" select="concat($prefix,$thiscount)"/>
        <xsl:variable name="firstletter" select="lower-case(substring($name,1,1))"/>
        <xsl:variable name="remainder" select="substring($name,2)"/>
        <xsl:value-of select="concat($namespace,concat($firstletter,$remainder))"/>
    </xsl:function>

    <xsl:function name="wlf:compound-name">
        <xsl:param name="first"/>
        <xsl:param name="second"/>
        <xsl:variable name="compound" select="concat(wlf:name-sibling($first),concat('-',wlf:name-sibling-no-namespace($second)))"/>
        <xsl:value-of select="$compound"/>
    </xsl:function>

    <xsl:function name="wlf:triple-compound-name">
        <xsl:param name="first"/>
        <xsl:param name="second"/>
        <xsl:param name="third"/>
        <xsl:variable name="compound" select="concat(wlf:name-sibling($first),concat('-',concat(wlf:name-sibling-no-namespace($second),concat('-',wlf:name-sibling-no-namespace($third)))))"/>
        <xsl:value-of select="$compound"/>
    </xsl:function>

    <xsl:function name="wlf:name-sibling-no-namespace">
        <xsl:param name="source"/>
        <xsl:variable name="prefix">
            <xsl:value-of select="$source/name()"/>
        </xsl:variable>
        <xsl:variable name="thiscount">
            <xsl:value-of select="concat('-',count($source/preceding-sibling::*[name()=$source/name()]) + 1)"/>
        </xsl:variable>
        <xsl:value-of select="concat($prefix,$thiscount)"/>
    </xsl:function>

    <xsl:function name="wlf:serialize">
        <xsl:param name="node-set" as="node()"/>
        <xsl:variable name="result-string">
            <xsl:value-of select="$node-set"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($result-string)"/>
    </xsl:function>

    <xsl:function name="wlf:serialize-name">
        <xsl:param name="node-set" as="node()*"/>
        <xsl:variable name="result-string">
            <xsl:for-each select="$node-set">
                <xsl:apply-templates/>
                <xsl:text> </xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="normalize-space($result-string)"/>
    </xsl:function>

    <!-- a custom 'contains' implementation -->
    <xsl:function name="wlf:contains" as="xs:boolean">
        <xsl:param name="str" as="xs:string"/>
        <xsl:param name="list" as="xs:string+"/>

        <xsl:variable name="temp" as="xs:boolean*">
            <xsl:for-each select="$list">
                <xsl:if test="contains(translate($str, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), .)">
                    <xsl:sequence select="xs:boolean('true')"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:sequence select="if ($temp[1] = xs:boolean('true')) then
      xs:boolean('true') else xs:boolean('false')"/>

    </xsl:function>


    <!-- a custom 'ends-with' implementation -->
    <xsl:function name="wlf:ends-with" as="xs:boolean">
        <xsl:param name="str" as="xs:string"/>
        <xsl:param name="list" as="xs:string+"/>

        <xsl:variable name="temp" as="xs:boolean*">
            <xsl:for-each select="$list">
                <xsl:if test="ends-with($str, .)">
                    <xsl:sequence select="xs:boolean('true')"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="if ($temp[1] = xs:boolean('true')) then
      xs:boolean('true') else xs:boolean('false')"/>
    </xsl:function>

    <!-- a custom 'starts-with' implementation -->
    <xsl:function name="wlf:starts-with" as="xs:boolean">
        <xsl:param name="str" as="xs:string"/>
        <xsl:param name="list" as="xs:string+"/>

        <xsl:variable name="temp" as="xs:boolean*">
            <xsl:for-each select="$list">
                <xsl:if test="starts-with(translate($str, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), .)">
                    <xsl:sequence select="xs:boolean('true')"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="if ($temp[1] = xs:boolean('true')) then
      xs:boolean('true') else xs:boolean('false')"/>
    </xsl:function>

    <!-- a custom 'contains' implementation -->
    <xsl:function name="wlf:containsKeyword" as="xs:string">
        <xsl:param name="str" as="xs:string"/>
        <xsl:param name="list" as="xs:string+"/>

        <xsl:variable name="temp" as="xs:string*">
            <xsl:for-each select="$list">
                <xsl:if test="contains(translate($str, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), .)">
                    <xsl:sequence select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:sequence select="if ($temp[1] != '') then
      $temp[1] else $temp[1]"/>

    </xsl:function>

    <xsl:function name="wlf:capitalize-first" as="xs:string?">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:sequence select="
      concat(upper-case(substring($arg,1,1)),
      substring($arg,2))
      "/>
    </xsl:function>

    <xsl:function name="wlf:before-last-delimeter">
        <xsl:param name="s"/>
        <xsl:param name="d"/>
        <xsl:choose>
            <xsl:when test="$d='.'">
                <xsl:variable name="delimiter" select="'\.'"/>
                <xsl:variable name="s-tokenized" select="tokenize($s, $delimiter)"/>

                <xsl:value-of select="string-join(remove($s-tokenized, count($s-tokenized)),$d)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="delimiter" select="$d"/>
                <xsl:variable name="s-tokenized" select="tokenize($s, $delimiter)"/>

                <xsl:value-of select="string-join(remove($s-tokenized, count($s-tokenized)),$d)"/>
            </xsl:otherwise>
        </xsl:choose>



    </xsl:function>

    <xsl:function name="wlf:if-absent" as="item()*" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="item()*"/>
        <xsl:param name="value" as="item()*"/>

        <xsl:sequence select="
      if (exists($arg))
      then $arg
      else $value
      "/>

    </xsl:function>

    <xsl:function name="wlf:replace-multi" as="xs:string?" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="changeFrom" as="xs:string*"/>
        <xsl:param name="changeTo" as="xs:string*"/>
        <xsl:sequence select="
      if (count($changeFrom) > 0) 
      then (
        if(contains($arg,$changeFrom[1])) then(
        wlf:replace-multi(
        concat(substring-before($arg,$changeFrom[1]),$changeTo[1],substring-after($arg,$changeFrom[1])),
  
        $changeFrom[position() > 1],
        $changeTo[position() > 1]))
        else wlf:replace-multi(
        $arg,
        $changeFrom[position() > 1],
        $changeTo[position() > 1]))
      else $arg
      "/>
        <!--replace($arg, $changeFrom[1],wlf:if-absent($changeTo[1],'')),-->
    </xsl:function>

    <xsl:template match="*" mode="serialize">
        <xsl:value-of select="wlf:serialize(.)"/>
    </xsl:template>

    <!-- Global variable declarations. -->

    <xsl:variable name="paramConfigXml" select="if (doc-available('LGconfiguration.xml')) then doc('LGconfiguration.xml') else ()"/>
    <xsl:variable name="gaz">https://www.thegazette.co.uk/</xsl:variable>
    <xsl:variable name="osPostcode" as="xs:string*">http://data.ordnancesurvey.co.uk/ontology/postcode/</xsl:variable>
    <xsl:variable name="osPostcodeUnit" as="xs:string*">http://data.ordnancesurvey.co.uk/id/postcodeunit/</xsl:variable>
    <xsl:variable name="noticeType" select="//gz:Notice/@Type"/>
    <xsl:variable name="noticeNo">
        <xsl:choose>
            <xsl:when test="//gz:Notice/@Reference and (starts-with($noticeId,'L') or starts-with($noticeId,'B') or starts-with($noticeId,'E'))">
                <xsl:value-of select="//gz:Notice/@Reference"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$noticeId"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="idURI" select="concat($gaz,'id','/notice/', $noticeId)"/>
    <xsl:variable name="documentURI" select="concat($gaz,'notice/', $noticeId)"/>

    <xsl:variable name="publishDate">
        <xsl:variable name="test" select="concat(.//ukm:PublishDate,'T',(if (//ukm:TimeStamp != '') then wlf:getTimeStamp(//ukm:TimeStamp) else '01:00:00'))"/>
        <xsl:value-of select="$test"/>
        <xsl:if test="not($test castable as xs:dateTime)">
            <xsl:text>:00</xsl:text>
        </xsl:if>
    </xsl:variable>
    <xsl:variable name="category">
        <xsl:sequence select="$mapping//*:Map[@Code = $noticeType]/*"/>
    </xsl:variable>
    <xsl:variable name="issueURI" select="concat($gaz,'id/','edition/',$edition,'/issue/',$issueNumber)"/>
    <xsl:variable name="editionURI" select="concat($gaz,'id/','edition/',$edition)"/>

    <!-- Import the required OWL classes. -->


    <!-- #######################  -->
    <!-- ##### "RESOURCES" ##### -->
    <!-- ####################### -->
    <xsl:variable name="noticeURI" select="concat($gaz,'id','/notice/', $noticeId)"/>
    <xsl:variable name="long-notice-uri">http://www.<xsl:value-of select="lower-case($edition)"/>-gazette.co.uk/id/issues/<xsl:value-of select="$issueNumber"/>/notices/<xsl:value-of select="$noticeNo"/>
    </xsl:variable>
    <xsl:variable name="notifiable-thing">this:notifiableThing</xsl:variable>
    <xsl:variable name="publication-Occasion">this:publicationOccasion</xsl:variable>
    <xsl:variable name="address-of-administrator">this:addressOfAdministrator</xsl:variable>
    <xsl:variable name="notice-provenance">https://www.thegazette.co.uk/id/notice/<xsl:value-of select="$noticeId"/>/provenance</xsl:variable>
    <xsl:variable name="trustee-act-1925-part-2-section-27-uri">http://www.legislation.gov.uk/ukpga/Geo5/15-16/19/section/27</xsl:variable>

    <!-- ######################## -->
    <!-- ##### ASSOCIATIONS ##### -->
    <!-- ######################## -->
    <xsl:variable name="applies-bankruptcy-restrictions">gzw:appliesBankruptcyRestrictions</xsl:variable>
    <xsl:variable name="has-administrator">insolvency:hasAdministrator</xsl:variable>
    <xsl:variable name="has-additional-contact">gzw:hasAdditionalContact</xsl:variable>
    <xsl:variable name="has-appointer">insolvency:hasAppointer</xsl:variable>
    <xsl:variable name="has-authorising-person">gaz:hasAuthorisingPerson</xsl:variable>
    <xsl:variable name="has-birth-details">gzw:hasBirthDetails</xsl:variable>
    <xsl:variable name="has-company">gaz:hasCompany</xsl:variable>
    <xsl:variable name="has-company-group">gzw:companyGroup</xsl:variable>
    <xsl:variable name="has-company-name">gazorg:name</xsl:variable>
    <xsl:variable name="has-company-number">gazorg:companyNumber</xsl:variable>
    <xsl:variable name="has-company-status">gzw:companyStatus</xsl:variable>
    <xsl:variable name="has-court">court:hasCourt</xsl:variable>
    <xsl:variable name="has-court-case">insolvency:hasCourtCase</xsl:variable>
    <xsl:variable name="has-court-district">court:courtDistrict</xsl:variable>
    <xsl:variable name="has-court-name">court:courtName</xsl:variable>
    <xsl:variable name="has-court-number">court:caseNumber</xsl:variable>
    <xsl:variable name="has-court-year">court:caseYear</xsl:variable>
    <xsl:variable name="has-court-code">court:caseCode</xsl:variable>
    <xsl:variable name="has-court-previous">gzw:courtPrevious</xsl:variable>
    <xsl:variable name="has-date-of-appointment">insolvency:dateOfAppointment</xsl:variable>
    <xsl:variable name="has-date-of-document-receipt">companylaw:dateDocumentsReceived</xsl:variable>
    <xsl:variable name="has-death-details">gzw:hasDeathDetails</xsl:variable>
    <xsl:variable name="has-edition">gaz:hasEdition</xsl:variable>
    <xsl:variable name="has-issue-number">gaz:hasIssueNumber</xsl:variable>
    <xsl:variable name="has-liquidation-type">insolvency:typeOfLiquidation</xsl:variable>
    <xsl:variable name="has-name">foaf:name</xsl:variable>
    <xsl:variable name="has-nature-of-business">gazorg:natureOfBusiness</xsl:variable>
    <xsl:variable name="has-notice-code">gaz:hasNoticeCode</xsl:variable>
    <xsl:variable name="has-notice-id">gaz:hasNoticeID</xsl:variable>
    <xsl:variable name="has-notice-number">gaz:hasNoticeNumber</xsl:variable>
    <xsl:variable name="has-notice-type">gaz:hasNoticeType</xsl:variable>
    <xsl:variable name="has-occupation">gzw:hasOccupation</xsl:variable>
    <xsl:variable name="has-office-holder-capacity">gzw:hasOfficeHolderCapacity</xsl:variable>
    <xsl:variable name="has-office-holder-number">gzw:hasOfficeHolderNumber</xsl:variable>
    <xsl:variable name="has-office-holder-numbers">gzw:hasOfficeHolderNumbers</xsl:variable>
    <xsl:variable name="has-official-receiver">insolvency:hasOfficialReceiver</xsl:variable>
    <xsl:variable name="has-other-company-names">gzw:companyOtherNames</xsl:variable>
    <xsl:variable name="has-partnership-address">gzw:partnershipAddress</xsl:variable>
    <xsl:variable name="has-partnership-details">gzw:partnershipDetails</xsl:variable>
    <xsl:variable name="has-partnership-name">gzw:partnershipName</xsl:variable>
    <xsl:variable name="has-partnership-number">gzw:partnershipNumber</xsl:variable>
    <xsl:variable name="has-person-details">gzw:hasPersonDetails</xsl:variable>
    <xsl:variable name="has-previous-partnership">gzw:partnershipPrevious</xsl:variable>
    <xsl:variable name="has-principal-trading-address">gazorg:hasPrincipalTradingAddress</xsl:variable>
    <xsl:variable name="has-private-address">gzw:hasPrivateAddress</xsl:variable>
    <xsl:variable name="has-provenance">prov:has_provenance</xsl:variable>
    <xsl:variable name="has-publication-date">gaz:earliestPublicationDate</xsl:variable>
    <!--xsl:variable name="has-publication-date">gaz:hasPublicationDate</xsl:variable-->
    <xsl:variable name="has-publisher">dc11:publisher</xsl:variable>
    <xsl:variable name="has-registered-office">gazorg:hasRegisteredOffice</xsl:variable>
    <xsl:variable name="has-resolutionLiquidator">insolvency:resolutionLiquidator</xsl:variable>
    <xsl:variable name="has-liquidator">insolvency:hasLiquidator</xsl:variable>
    <xsl:variable name="has-convenor">insolvency:hasConvener</xsl:variable>
    <xsl:variable name="has-society-name">societies:societyName</xsl:variable>
    <xsl:variable name="has-society-number">societies:societyNumber</xsl:variable>
    <xsl:variable name="has-status">gzw:hasStatus</xsl:variable>
    <xsl:variable name="has-trade-classification">gazorg:sitcTradeClassification</xsl:variable>
    <xsl:variable name="is-about">gaz:isAbout</xsl:variable>
    <xsl:variable name="is-an-alternate-of">prov:alternateOf</xsl:variable>
    <xsl:variable name="is-enabled-by-legislation">gaz:isEnabledByLegislation</xsl:variable>
    <xsl:variable name="is-registered-in">gzw:isRegisteredIn</xsl:variable>
    <xsl:variable name="is-the-same-as">owl:sameAs</xsl:variable>
    <xsl:variable name="recognizes-bankruptcy-order-time">gzw:bankruptcyOrderTime</xsl:variable>
    <xsl:variable name="recognizes-petition-bankruptcy-order-date">gzw:petitionBankruptcyOrderDate</xsl:variable>
    <xsl:variable name="recognizes-petition-filing-date">insolvency:datePetitionFiled</xsl:variable>
    <xsl:variable name="recognizes-vol-winding-up-resolution-date">insolvency:dateResolvedVoluntaryWindingUp</xsl:variable>
    <xsl:variable name="recognizes-winding-up-order-date">insolvency:dateWoundUp</xsl:variable>
    <xsl:variable name="signed-on-date">gaz:dateAuthorisationSigned</xsl:variable>
    <xsl:variable name="dateOfResolution">insolvency:dateOfResolution</xsl:variable>
    <xsl:variable name="has-receiver">insolvency:hasReceiver</xsl:variable>
    <xsl:variable name="has-personal-representative">personal-legal:hasPersonalRepresentative</xsl:variable>
    <xsl:variable name="has-estate-of">personal-legal:hasEstateOf</xsl:variable>
    <xsl:variable name="publicationOccasion">gaz:publicationOccasion</xsl:variable>
    <!-- ################# -->
    <!-- ##### TYPES ##### -->
    <!-- ################# -->
    <xsl:variable name="edition-type">gaz:Edition</xsl:variable>
    <xsl:variable name="issue-type">gaz:Issue</xsl:variable>
    <xsl:variable name="notice-type">gaz:Notice</xsl:variable>

    <!-- ################ -->
    <!-- ##### ROOT ##### -->
    <!-- ################ -->
    <xsl:template match="/">
        <!-- Uncomment the line below to enforce the HTML5 doctype -->
        <!-- xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text -->
        <html prefix="gaz: https://www.thegazette.co.uk/def/publication#
      gzw: https://www.thegazette.co.uk/def/working#
      person: https://www.thegazette.co.uk/def/person#
      personal-legal: https://www.thegazette.co.uk/def/personal-legal#
      court: https://www.thegazette.co.uk/def/court#
      insolvency: https://www.thegazette.co.uk/def/insolvency#
      org: http://www.w3.org/ns/org#
      gazorg: https://www.thegazette.co.uk/def/organisation#
      leg: https://www.thegazette.co.uk/def/legislation#
      societies: https://www.thegazette.co.uk/def/societies#
      loc: https://www.thegazette.co.uk/def/location#
      dc11: http://purl.org/dc/elements/1.1/
      this: https://www.thegazette.co.uk/id/notice/{$noticeId}#      
      prov: http://www.w3.org/ns/prov# {if($noticeCode = ('1122','1123','1124','1125','1126','1127','1128','1129','1130','1131','1132','1133','1134','1135','1136')) then 'honours: https://www.thegazette.co.uk/def/honours# military: https://www.thegazette.co.uk/def/military#' else ''}
      {if($isCompanyLawNotice) then 'companylaw: https://www.thegazette.co.uk/def/companylaw#' else ''}">
            <xsl:if test="not($vHTMLcompatible)">
                <xsl:attribute name="IdURI" select="concat('https://www.thegazette.co.uk/id/notice/', $noticeId)"/>
            </xsl:if>
            <head>
                <xsl:if test="$noticeCode= ('1122','1123','1124','1125','1126','1127','1128','1129','1130','1131','1132','1133','1134','1135','1136')">
                    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                </xsl:if>
                <title>
                    <xsl:if test="$isCompanyLawNotice">
                        <xsl:value-of select="//gz:CompanyName"/>
                    </xsl:if>
                    <xsl:if test="not($isCompanyLawNotice)">
                        <xsl:value-of select="normalize-space(string-join($paramConfigXml/gzc:Configuration//gzc:Notice[@Code = $noticeCode]/gzc:Name/text(), ' '))"/>
                    </xsl:if>
                </title>
                <xsl:if test="not($vHTMLcompatible)">
                    <xsl:call-template name="gazettes-metadata"/>
                </xsl:if>
            </head>
            <body>
                <xsl:if test="$debug='true'">
                    <!-- Check that the transform is correctly receiving its configuration. -->
                    <h1>DEBUG START</h1>paramconfigxml: |<xsl:copy-of select="$paramConfigXml/gzc:Configuration//gzc:Notice[@Code = $noticeCode]"/>|<h1>DEBUG END</h1>
                </xsl:if>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="gz:Notice">
        <!-- A notice in the source data effectively becomes an article in the XHTML. -->
        <!-- The article is constructed in three sequential parts: the additional RDFa data, the metadata and finally the content. -->
        <!-- Each is formed by a call to its own template. -->
        <article class="full-notice full-notice-{$noticeCode}">
            <xsl:call-template name="rdfa-data"/>
            <xsl:call-template name="metadata"/>
            <xsl:call-template name="content"/>
        </article>
        <xsl:if test="$isCompanyLawNotice">
            <xsl:call-template name="summary"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="content">
        <!-- Constructs the main content of the article -->
        <div class="content" about="{$notifiable-thing}" data-gazettes="Notice" data-gazettes-type="{$noticeCode}">
            <!-- handles processing instructions of the form <?Gazette force2col?> -->
            <xsl:if test=".//processing-instruction('Gazette') = 'force2col'">
                <xsl:attribute name="data-gazettes-colspan">2</xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$noticeCode = '2903'">
                    <!-- Notices of type 2903 are treated as a special case. They have a more fielded structure than other notice types. -->
                    <xsl:call-template name="type2903"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- For all non-Deceased estates notices. -->
                    <xsl:variable name="notice">
                        <xsl:call-template name="notice-content"/>
                    </xsl:variable>
                    <!--<xsl:copy-of select="$notice"/>-->
                    <xsl:apply-templates select="$notice" mode="finesse"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
        <!-- Legislation now added in v1-2 transform, so text is available within ML -->
        <!-- Previously, for XML submission, this was added only at time of viewing in webview -->
        <xsl:if test="$noticeCode = '2903'">
            <xsl:call-template name="Legislation"/>
        </xsl:if>
    </xsl:template>
    <!-- Make <ul><li/></ul><ul><li/></ul> into <ul><li/><li/></ul> mode=finesse & mode=finesse2-->
    <xsl:template match="@*|node()" mode="finesse">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="finesse"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="*:ul[@data-created-bullet='true']" mode="finesse">
        <xsl:if test="not(local-name(preceding-sibling::*[1]) = 'ul' and  preceding-sibling::*[1][@data-created-bullet='true'])">
            <xsl:copy>
                <xsl:for-each select="@*">
                    <xsl:if test="name(.) != 'data-created-bullet'">
                        <xsl:copy-of select="."/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:apply-templates select="node()" mode="finesse"/>
                <xsl:if test="local-name(following-sibling::*[1]) = 'ul' and following-sibling::*[1][@data-created-bullet='true']">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="finesse2"/>
                </xsl:if>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:ul[@data-created-bullet='true']" mode="finesse2">
        <xsl:apply-templates select="node()" mode="finesse"/>
        <xsl:if test="local-name(following-sibling::*[1]) = 'ul' and following-sibling::*:ul[@data-created-bullet='true']">
            <xsl:apply-templates select="following-sibling::*[1]" mode="finesse2"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="notice-content">
        <!-- Handle non-2903 notice types. -->
        <xsl:variable name="items" as="item()*" select="*"/>
        <xsl:variable name="p1s" as="xs:integer*" select="wlf:findP1s($items)"/>
        <xsl:for-each select="$items">
            <xsl:choose>
                <xsl:when test="name(.) = ('P1','P2','P3')">
                    <xsl:if test="position() = $p1s">
                        <xsl:copy-of select="wlf:apply-subsequence(position(), $p1s, $items)"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="rdfa-data">
        <!-- Construct the RDFa div that contains much of the non-inline linkage information. -->

        <div class="rdfa-data">
            <span about="{$noticeURI}" property="{$has-publisher}" content="TSO (The Stationery Office), St Crispins, Duke Street, Norwich, NR3 1PD, 01603 622211, customer.services@tso.co.uk"/>
            <span about="{$noticeURI}" property="{$is-about}" resource="{$notifiable-thing}"/>
            <xsl:if test="$noticeCode=('1122','1123','1124','1125','1126','1127','1128','1129','1130','1131','1132','1133','1134','1135','1136')">
                <span about="{$noticeURI}" property="{$publicationOccasion}" resource="{$publication-Occasion}"/>
            </xsl:if>
            <span about="{$noticeURI}" property="{$has-provenance}" resource="{$notice-provenance}"/>
            <span about="{$noticeURI}" property="prov:has_anchor" resource="{$noticeURI}"/>
            <span resource="{$editionURI}" typeof="{$edition-type}"/>
            <span about="{$noticeURI}" property="{$has-notice-number}" datatype="xsd:integer" content="{$noticeNo}"/>
            <xsl:if test="$issueNumber">
                <span about="{$noticeURI}" property="gaz:isInIssue" resource="{$issueURI}"/>
                <span resource="{$issueURI}" typeof="{$issue-type}"/>
                <span about="{$issueURI}" property="{$has-edition}" resource="{$editionURI}"/>
                <span about="{$issueURI}" property="{$has-issue-number}" datatype="xsd:string" content="{$issueNumber}"/>
                <span about="{$noticeURI}" property="{$is-the-same-as}" resource="https://www.thegazette.co.uk/id/edition/{$edition}/issue/{$issueNumber}/notice/{$noticeNo}" typeof="{$notice-type}"/>
                <span about="{$noticeURI}" property="{$is-an-alternate-of}" resource="{$long-notice-uri}" typeof="{$notice-type}"/>
            </xsl:if>
            <xsl:comment>Notice Classes</xsl:comment>
            <xsl:if test="not($noticeCode =('1122','1123','1124','1125','1126','1127','1128','1129','1130','1131','1132','1133','1134','1135','1136'))">
                <span resource="{$noticeURI}" typeof="https://www.thegazette.co.uk/def/publication#Notice"/>
            </xsl:if>
            <xsl:for-each select="$class/*/*[@noticecode = $noticeType and @type='notice']">
                <span resource="{$noticeURI}" typeof="{.}"/>
            </xsl:for-each>
            <xsl:comment>Notifiable Thing</xsl:comment>
            <xsl:if test="not($noticeCode =('1122','1123','1124','1125','1126','1127','1128','1129','1130','1131','1132','1133','1134','1135','1136'))">
                <span resource="this:notifiableThing" typeof="https://www.thegazette.co.uk/def/publication#NotifiableThing"/>
            </xsl:if>
            <xsl:for-each select="$class/*/*[@noticecode = $noticeType and @type='notifiablething']">
                <span resource="this:notifiableThing" typeof="{.}"/>
            </xsl:for-each>
            <xsl:if test="$isCompanyLawNotice">
                <xsl:variable name="editionCode">
                    <xsl:value-of select="substring($edition,1,1)"/>
                </xsl:variable>
                <xsl:for-each select="$legislationMapping//notice[@code=$noticeCode and contains(@edition,$editionCode)]/item">
                    <span about="this:notifiableThing" property="gaz:relatedLegislation">
                        <xsl:attribute name="resource">
                            <xsl:value-of select="@uri"/>
                        </xsl:attribute>
                    </span>
                    <span property="rdfs:label" typeof="leg:Legislation">
                        <xsl:attribute name="content">
                            <xsl:value-of select="@label"/>
                        </xsl:attribute>
                        <xsl:attribute name="about">
                            <xsl:value-of select="@uri"/>
                        </xsl:attribute>
                    </span>
                </xsl:for-each>
            </xsl:if>

            <!--honour-->
            <xsl:if test="$noticeCode='1122' or $noticeCode='1123' or $noticeCode='1124' or $noticeCode='1125' or $noticeCode='1128' or $noticeCode='1129'">
                <xsl:comment>helper</xsl:comment>
                <span about="this:notifiableThing" property="honours:isAppointedAs" resource="https://www.thegazette.co.uk/id/honour/{$honourShortName}"/>
                <xsl:if test="$noticeCode='1122'">
                    <span about="https://www.thegazette.co.uk/id/honour/{$honourShortName}" typeof="honours:{wlf:stripSpecialChars($honour)}" property="rdfs:label" content="{$honourShortName}{if ($noticeCode='1122') then '.' else ''}"/>
                </xsl:if>
                <!--<span about="this:honour-1" property="rdf:type" resource="honours:{wlf:stripSpecialChars($honour)}"></span>-->
                <xsl:choose>
                    <xsl:when test="$noticeCode =('1123','1124','1125','1128','1129')">
                        <span about="https://www.thegazette.co.uk/id/honour/{$honourShortName}" property="honours:isMemberOfOrder" resource="honours:{$order}"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="$noticeCode='1128'">
                    <span about="https://www.thegazette.co.uk/id/honour/{$honourShortName}" typeof="honours:CompanionOrderOfTheCompanionsOfHonour" property="rdfs:label" content="Member of the Order of the Companions of Honour"/>
                </xsl:if>
            </xsl:if>
            <!---Medal-->
            <xsl:if test="$noticeCode='1127' or $noticeCode='1130' or $noticeCode='1131' or $noticeCode='1132' or $noticeCode='1133' or $noticeCode='1134' or $noticeCode='1135' or  $noticeCode='1136'">
                <xsl:comment>helper</xsl:comment>
                <span about="this:notifiableThing" property="honours:isAwarded" resource="https://www.thegazette.co.uk/id/honour/{$honourShortName}"/>
                <xsl:if test="$noticeCode='1127'">
                    <span about="https://www.thegazette.co.uk/id/honour/RVM" typeof="honours:{$medal}" property="rdfs:label" content="Royal Victorian Medal {$awardType}"/>
                </xsl:if>
                <xsl:if test="$noticeCode =('1127','1130')">
                    <span about="https://www.thegazette.co.uk/id/honour/{$honourShortName}" property="honours:isMemberOfOrder" resource="honours:{$order}"/>
                </xsl:if>
            </xsl:if>
            <!--bar-->
            <xsl:if test="$noticeCode='1126'">
                <xsl:comment>helper</xsl:comment>
                <span about="this:notifiableThing" property="honours:isAwarded" resource="https://www.thegazette.co.uk/id/honour/BRVM"/>
                <span about="https://www.thegazette.co.uk/id/honour/BRVM" property="honours:isAssociatedWithAward" resource="https://www.thegazette.co.uk/id/honour/RVM"/>
                <span about="https://www.thegazette.co.uk/id/honour/BRVM" typeof="honours:Bar" property="rdfs:label" content="Bar to Royal Victorian Medal {$awardType}"/>
                <span about="https://www.thegazette.co.uk/id/honour/RVM" typeof="honours:{$bar}" property="rdfs:label" content="Royal Victorian Medal {$awardType}"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$noticeCode = '2903'">
                    <!-- Deceased estates notices only. -->
                    <xsl:variable name="fullName">
                        <xsl:value-of select="//gz:Person/gz:PersonName/gz:Forename"/>
                        <!-- &#160; -->
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="//gz:Person/gz:PersonName/gz:MiddleNames"/>
                        <!-- &#160; -->
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="//gz:Person/gz:PersonName/gz:Surname"/>
                    </xsl:variable>
                    <xsl:variable name="personURI" select="string-join(('this:','deceasedPerson'),'')"/>
                    <xsl:variable name="personFullName" select="replace($fullName,'\s+',' ')"/>
                    <span about="this:notifiableThing" property="personal-legal:hasPersonalRepresentative" resource="this:estateExecutor"/>
                    <span resource="this:deceased-address-1" typeof="vcard:Address"/>
                    <span resource="this:addressOfExecutor" typeof="vcard:Address"/>
                    <span resource="this:estateExecutor" typeof="foaf:Agent"/>
                    <span about="this:estateExecutor" property="vcard:adr" resource="this:addressOfExecutor"/>
                    <!-- Needed for all 2903 notices -->
                    <span resource="{$noticeURI}" typeof="personal-legal:DeceasedEstatesNotice personal-legal:WillsAndProbateNotice gaz:Notice"/>
                    <span about="this:notifiableThing" property="personal-legal:hasEstateOf" resource="{$personURI}"/>
                    <span about="{$personURI}" typeof="gaz:Person"/>
                    <span about="{$personURI}" property="person:hasAddress" resource="this:deceased-address-1"/>
                    <span about="{$personURI}" content="{$personFullName}" property="foaf:name"/>
                </xsl:when>
            </xsl:choose>

            <xsl:if test="$crownDependancy[. !='']">
                <span about="this:notifiableThing" property="honours:hasCrownDependency" resource="this:crownDependency"/>
            </xsl:if>
            <xsl:if test="$rank[. != '']">
                <span about="this:person-1" property="military:hasRank" resource="this:rank-1"/>
            </xsl:if>
            <xsl:if test="$workplace[. !=''] or $OccupationPosition[. !='']">
                <span about="this:occupation-1" property="gazorg:isMemberOfOrganisation" resource="this:organisation-1"/>
            </xsl:if>
            <xsl:if test="$department[. !='']">
                <span about="this:occupation-1" property="gazorg:isMemberOfDepartment" resource="this:department-1"/>
            </xsl:if>
            <!-- Support for jobTitle rdf in below noticecodes -->
            <xsl:if test="$noticeCode='1132' or $noticeCode='1133' or $noticeCode='1134' or $noticeCode='1136'">
                <xsl:if test="$Occupation[. !='']">
                    <span about="this:occupation-1" property="gazorg:isMemberOfOrganisation" resource="this:organisation-1"/>
                </xsl:if>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template name="metadata">
        <!-- Construct the metadata name-value pair list associated with the notice. -->
        <xsl:variable name="issueURI" select="concat($gaz,'id/','edition/',$edition,'/issue/',$issueNumber)"/>
        <dl class="metadata">
            <dt>Notice category:</dt>
            <dd data-ui-class="category">
                <xsl:value-of select="$paramConfigXml/gzc:Configuration//gzc:Category[@Code = substring($noticeType,1,2)]/@Name"/>
            </dd>
            <dt>Notice type:</dt>
            <dd data-ui-class="notice-type">
                <xsl:value-of select="$paramConfigXml/gzc:Configuration//gzc:Notice[@Code = $noticeType]/gzc:Name"/>
            </dd>
            <dt>Publication date:</dt>
            <dd about="{$noticeURI}" property="{$has-publication-date}" content="{$publishDate}" datatype="xsd:dateTime">
                <time datetime="{$publishDate}">
                    <xsl:value-of select="$publishDate"/>
                </time>
            </dd>
            <xsl:if test="$noticeCode = '2903' and gz:Person/gz:DeathDetails/gz:NoticeOfClaimsDate">
                <dt>Claim expires:</dt>
                <dd about="this:notifiableThing" property="personal-legal:hasClaimDeadline" content="{gz:Person/gz:DeathDetails/gz:NoticeOfClaimsDate/@Date}" datatype="xsd:date">
                    <time datetime="{gz:Person/gz:DeathDetails/gz:NoticeOfClaimsDate/@Date}">
                        <xsl:value-of select="gz:Person/gz:DeathDetails/gz:NoticeOfClaimsDate"/>
                    </time>
                </dd>
            </xsl:if>
            <dt>Edition:</dt>
            <dd>
                <xsl:text>The </xsl:text>
                <span about="{$editionURI}" property="gaz:editionName" datatype="xsd:string">
                    <xsl:value-of select="$edition"/>
                </span>
                <xsl:text> Gazette</xsl:text>
            </dd>
            <xsl:if test="$issueNumber ">
                <dt>Issue number:</dt>
                <dd about="{$issueURI}" property="{$has-issue-number}" datatype="xsd:string">
                    <xsl:value-of select="$issueNumber"/>
                </dd>

                <xsl:if test="not($pageNumber='0')">
                    <dt>Page number:</dt>
                    <dd data-gazettes="page-number">
                        <xsl:value-of select="$pageNumber"/>
                    </dd>
                </xsl:if>
            </xsl:if>
            <dt>Notice ID:</dt>
            <dd about="{$noticeURI}" property="{$has-notice-id}">
                <xsl:value-of select="$noticeId"/>
            </dd>
            <dt>Notice code:</dt>
            <dd about="{$noticeURI}" property="{$has-notice-code}" datatype="xsd:integer">
                <xsl:value-of select="$noticeType"/>
            </dd>
        </dl>
    </xsl:template>

    <xsl:template match="@*|node()" mode="nameSecondPass">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="nameSecondPass"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="*:dt[@data-copy-title='true']" mode="nameSecondPass">
        <dt>
            <xsl:copy-of select="@*[not(local-name()='data-copy-title')]"/>
            <xsl:value-of select=".//preceding-sibling::*:dt[@data-gazettes='custom-title'][1]"/>
        </dt>
    </xsl:template>
    <xsl:template match="@*|node()" mode="dlSecondPass">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="dlSecondPass"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="*[@data-gazettes=('prefix','suffix')]" mode="dlSecondPass"/>
    <xsl:template match="*:dd[following-sibling::*[1][@data-gazettes='suffix']]" mode="dlSecondPass">
        <dd>
            <xsl:apply-templates select="@*|node()" mode="nameSecondPass"/>
            <xsl:variable name="suffix_text" select=".//following-sibling::*[1][@data-gazettes='suffix']"/>
            <xsl:if test="normalize-space($suffix_text)!=''">
                <xsl:text> </xsl:text>
                <span>
                    <xsl:value-of select="$suffix_text"/>
                </span>
            </xsl:if>
        </dd>
    </xsl:template>
    <xsl:template match="*:dd[preceding-sibling::*[2][@data-gazettes='prefix']]" mode="dlSecondPass">
        <dd>
            <xsl:apply-templates select="@*" mode="nameSecondPass"/>
            <xsl:variable name="prefix_text" select=".//preceding-sibling::*[2][@data-gazettes='prefix']"/>
            <xsl:if test="normalize-space($prefix_text)!=''">
                <span>
                    <xsl:value-of select="$prefix_text"/>
                    <xsl:text> </xsl:text>
                </span>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="nameSecondPass"/>
        </dd>
    </xsl:template>
    <xsl:template name="string-replace-all">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="by"/>
        <xsl:choose>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text,$replace)"/>
                <xsl:value-of select="$by"/>
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="substring-after($text,$replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="by" select="$by"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="node()" mode="person2903">
        <xsl:param name="personURI"/>
        <xsl:choose>
            <xsl:when test="self::text()">
                <xsl:variable name="firstPass">
                    <xsl:apply-templates select="." mode="init">
                        <xsl:with-param name="personURI" select="$personURI"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:apply-templates select="$firstPass" mode="nameSecondPass"/>
            </xsl:when>
            <xsl:otherwise>
                <dt>
                    <xsl:value-of select="name(.)"/>
                </dt>
                <dd>
                    <xsl:value-of select="."/>
                </dd>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- suffix prefix templates-->
    <xsl:template match="node()" mode="prefix2903">
        <xsl:param name="personURI"/>
        <xsl:choose>
            <xsl:when test="self::text()">
                <!-- check where is the comma-->
                <xsl:variable name="initial" select="substring(normalize-space(.),1,1)"/>
                <xsl:variable name="final" select="substring(normalize-space(.),1,string-length(.))"/>
                <xsl:choose>
                    <xsl:when test="$initial=','">
                        <xsl:variable name="content" select="replace(.,',','')"/>
                        <xsl:apply-templates select="." mode="prefixSecondPass">
                            <xsl:with-param name="personURI" select="$personURI"/>
                            <xsl:with-param name="content" select="$content"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:when test="$final=','">
                        <xsl:variable name="content" select="replace(.,',','')"/>
                        <xsl:apply-templates select="." mode="sufixSecondPass">
                            <xsl:with-param name="personURI" select="$personURI"/>
                            <xsl:with-param name="content" select="$content"/>
                        </xsl:apply-templates>
                    </xsl:when>
                </xsl:choose>
                <xsl:variable name="nameFirstPass">
                    <xsl:apply-templates select="." mode="init">
                        <xsl:with-param name="personURI" select="$personURI"/>
                    </xsl:apply-templates>
                </xsl:variable>

            </xsl:when>
            <xsl:otherwise>
                <dt>
                    <xsl:value-of select="name(.)"/>
                </dt>
                <dd>
                    <xsl:value-of select="."/>
                </dd>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Surname" mode="person2903">
        <xsl:param name="personURI"/>
        <dt>Surname:</dt>
        <dd typeof="gaz:Person" about="{$personURI}" property="foaf:familyName" data-gazettes="Surname">
            <xsl:value-of select="."/>
        </dd>
    </xsl:template>
    <xsl:template match="gz:Forename" mode="person2903">
        <xsl:param name="personURI"/>
        <dt>First name:</dt>
        <dd typeof="gaz:Person" about="{$personURI}" property="foaf:firstName" data-gazettes="Forename">
            <xsl:value-of select="."/>
        </dd>
    </xsl:template>
    <xsl:template match="gz:MiddleNames" mode="person2903">
        <xsl:param name="personURI"/>
        <dt>Middle name(s):</dt>
        <dd typeof="gaz:Person" about="{$personURI}" property="foaf:givenName" data-gazettes="Forename">
            <xsl:value-of select="."/>
        </dd>
    </xsl:template>

    <xsl:template match="gz:MaidenName" mode="person2903">
        <xsl:param name="personURI"/>
        <dt>Maiden name:</dt>
        <dd about="{$personURI}" property="person:hasMaidenName" data-gazettes="Maiden" datatype="xsd:string">
            <xsl:value-of select="."/>
        </dd>
    </xsl:template>

    <xsl:template match="gz:AlsoKnownAs" mode="person2903">
        <xsl:param name="personURI"/>
        <dt>Alternative name:</dt>
        <dd typeof="gaz:Person" about="{$personURI}" property="person:alsoKnownAs" data-gazettes="Forename">
            <xsl:value-of select="."/>
        </dd>
    </xsl:template>

    <xsl:template match="gz:Initials" mode="person2903">
        <xsl:param name="personURI"/>
        <dt>Initials:</dt>
        <dd typeof="gaz:Person" about="{$personURI}" property="person:initials" data-gazettes="Initials">
            <xsl:value-of select="."/>
        </dd>
    </xsl:template>

    <xsl:template match="gz:Title" mode="person2903">
        <xsl:param name="personURI"/>
        <dt>Title:</dt>
        <dd typeof="gaz:Person" about="{$personURI}" property="foaf:title" data-gazettes="Title">
            <xsl:value-of select="."/>
        </dd>
    </xsl:template>

    <xsl:template match="gz:Rank" mode="person2903">
        <xsl:param name="personURI"/>
        <dt>Rank:</dt>
        <dd typeof="gaz:Person" about="{$personURI}" property="person:rank" data-gazettes="Title">
            <xsl:value-of select="."/>
        </dd>
    </xsl:template>

    <xsl:template match="gz:PostNominal" mode="person2903">
        <xsl:param name="personURI"/>
        <dt>Post Nominal Award:</dt>
        <dd typeof="gaz:Person" about="{$personURI}" property="person:postNominal" data-gazettes="PostNominal">
            <xsl:value-of select="."/>
        </dd>
    </xsl:template>

    <xsl:template match="gz:Email" mode="person2903">
        <xsl:param name="personURI"/>
        <dt>Email address:</dt>
        <dd about="{$personURI}" property="gaz:email" data-gazettes="email" datatype="xsd:string">
            <xsl:value-of select="."/>
        </dd>
    </xsl:template>

    <xsl:template match="gz:Telephone[@Class='Administrator']" mode="person2903">
        <xsl:param name="personURI"/>
        <dt>Telephone:</dt>
        <dd about="{$personURI}" property="gaz:telephone" data-gazettes="telephone" datatype="xsd:string">
            <xsl:value-of select="."/>
        </dd>
    </xsl:template>

    <xsl:template match="gz:Telephone[@Class='Fax']" mode="person2903">
        <xsl:param name="personURI"/>
        <dt>Fax:</dt>
        <dd about="{$personURI}" property="gaz:fax" data-gazettes="fax" datatype="xsd:string">
            <xsl:value-of select="."/>
        </dd>
    </xsl:template>

    <!-- Modified to support structured admin/executor address -->
    <xsl:template match="gz:NoticeOfClaims/gz:AddressLineGroup" mode="person2903">
        <xsl:param name="personURI"/>
        <xsl:if test="gz:AddressLine[@Class='street-address']">
            <dt>Address 1:</dt>
            <dd about="this:addressOfExecutor-1" property="vcard:street-address" typeof="vcard:Address">
                <xsl:value-of select="gz:AddressLine[@Class='street-address']"/>
            </dd>
        </xsl:if>
        <xsl:if test="gz:AddressLine[@Class='extended-address']">
            <dt>Address 2:</dt>
            <dd about="this:addressOfExecutor-1" property="vcard:extended-address">
                <xsl:value-of select="gz:AddressLine[@Class='extended-address']"/>
            </dd>
        </xsl:if>
        <xsl:if test="gz:AddressLine[@Class='locality']">
            <dt>Town:</dt>
            <dd about="this:addressOfExecutor-1" property="vcard:locality">
                <xsl:value-of select="gz:AddressLine[@Class='locality']"/>
            </dd>
        </xsl:if>
        <xsl:if test="gz:AddressLine[@Class='country-name']">
            <dt>Country:</dt>
            <dd about="this:addressOfExecutor-1" property="vcard:country-name">
                <xsl:value-of select="gz:AddressLine[@Class='country-name']"/>
            </dd>
        </xsl:if>
        <xsl:if test="gz:Postcode">
            <dt>Postcode:</dt>
            <dd about="this:addressOfExecutor-1" property="vcard:postal-code">
                <xsl:value-of select="gz:Postcode"/>
            </dd>
        </xsl:if>
    </xsl:template>

    <xsl:template name="type2903">
        <!-- Specific rules for handling Deceased Estates notices. -->
        <xsl:variable name="personURI" select="string-join(('this:','deceasedPerson'),'')"/>
        <xsl:apply-templates select="gz:Substitution | gz:Retraction"/>

        <xsl:variable name="firstPass">
            <dl>
                <xsl:for-each select="gz:Person/gz:PersonName/node()">
                    <xsl:apply-templates select="." mode="person2903">
                        <xsl:with-param name="personURI" select="$personURI"/>
                    </xsl:apply-templates>
                </xsl:for-each>
            </dl>
        </xsl:variable>
        <xsl:apply-templates select="$firstPass" mode="dlSecondPass"/>

        <dl>

            <xsl:if test="gz:Person/gz:DeathDetails/gz:Date">
                <dt>Date of death:</dt>
                <dd property="personal-legal:dateOfDeath" typeof="gaz:Person" datatype="xsd:date" about="{$personURI}" content="{gz:Person/gz:DeathDetails/gz:Date/@Date}">
                    <time datetime="{gz:Person/gz:DeathDetails/gz:Date/@Date}">
                        <xsl:value-of select="gz:Person/gz:DeathDetails/gz:Date"/>
                    </time>
                </dd>
            </xsl:if>
            <xsl:if test="gz:Person/gz:DeathDetails/gz:DateStart">
                <dt>Date of Death: Between dates of</dt>
                <dd>
                    <span property="personal-legal:startDateOfDeath" datatype="xsd:date" about="{$personURI}">
                        <xsl:value-of select="gz:Person/gz:DeathDetails/gz:DateStart/@Date"/>
                    </span>
                    <xsl:text> and </xsl:text>
                    <span property="personal-legal:endDateOfDeath" datatype="xsd:date" about="{$personURI}">
                        <xsl:value-of select="gz:Person/gz:DeathDetails/gz:DateEnd/@Date"/>
                    </span>
                </dd>
            </xsl:if>

            <xsl:if test="gz:Person/gz:PersonDetails">
                <xsl:variable name="list_before" select="('St')"/>
                <xsl:variable name="list_occupation" select="('previously of')"/>

                <xsl:variable name="personDetails_serialize" select="wlf:serialize(gz:Person/gz:PersonDetails)"/>
                <xsl:variable name="chunk" select="tokenize($personDetails_serialize,'\.')[last()]"/>
                <xsl:variable name="chunk_before" select="tokenize($personDetails_serialize,'\.')[last()-1]"/>
                <xsl:choose>
                    <xsl:when test="$chunk_before and not(wlf:ends-with($chunk_before, $list_before)) and not(wlf:starts-with(normalize-space(lower-case($chunk)), $list_occupation))">
                        <dt data-gazettes="custom-title">Deceased Occupation:</dt>
                        <dd about="this:occupationOfDeceased" datatype="xsd:string" property="person:jobTitle">
                            <xsl:value-of select="normalize-space($chunk)"/>
                        </dd>
                        <dt>Person Address Details</dt>
                        <dd about="this:deceased-address-1" typeof="vcard:Address" property="vcard:adr">
                            <xsl:value-of select="wlf:before-last-delimeter(gz:Person/gz:PersonDetails,'.')"/>
                        </dd>
                    </xsl:when>
                    <xsl:otherwise>
                        <dt>Person Address Details</dt>
                        <dd about="this:deceased-address-1" typeof="vcard:Address" property="vcard:adr">
                            <xsl:value-of select="gz:Person/gz:PersonDetails"/>
                        </dd>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>

            <!-- Support for structured person address -->
            <xsl:if test="gz:Person/gz:PersonAddress">
                <xsl:if test="gz:Person/gz:PersonAddress/gz:AddressLineGroup/gz:AddressLine[@Class='street-address']">
                    <dt>Address Line 1:</dt>
                    <dd about="this:deceased-address-1" data-required="true" data-ui-class="addressLine1" property="vcard:street-address" typeof="vcard:Address">
                        <xsl:value-of select="gz:Person/gz:PersonAddress/gz:AddressLineGroup/gz:AddressLine[@Class='street-address']"/>
                    </dd>
                </xsl:if>
                <xsl:if test="gz:Person/gz:PersonAddress/gz:AddressLineGroup/gz:AddressLine[@Class='extended-address']">
                    <dt>Address Line 2:</dt>
                    <dd about="this:deceased-address-1" data-ui-class="addressLine2" property="vcard:extended-address">
                        <xsl:value-of select="gz:Person/gz:PersonAddress/gz:AddressLineGroup/gz:AddressLine[@Class='extended-address']"/>
                    </dd>
                </xsl:if>
                <xsl:if test="gz:Person/gz:PersonAddress/gz:AddressLineGroup/gz:AddressLine[@Class='locality']">
                    <dt>Town:</dt>
                    <dd about="this:deceased-address-1" data-ui-class="locality" property="vcard:locality">
                        <xsl:value-of select="gz:Person/gz:PersonAddress/gz:AddressLineGroup/gz:AddressLine[@Class='locality']"/>
                    </dd>
                </xsl:if>
                <xsl:if test="gz:Person/gz:PersonAddress/gz:AddressLineGroup/gz:AddressLine[@Class='country-name']">
                    <dt>Country:</dt>
                    <dd about="this:deceased-address-1" data-ui-class="country" property="vcard:country-name">
                        <xsl:value-of select="gz:Person/gz:PersonAddress/gz:AddressLineGroup/gz:AddressLine[@Class='country-name']"/>
                    </dd>
                </xsl:if>
                <xsl:if test="gz:Person/gz:PersonAddress/gz:AddressLineGroup/gz:AddressLine[@Class='street-address']">
                    <dt>Postcode:</dt>
                    <dd about="this:deceased-address-1" data-required="true" data-ui-class="postcode" property="vcard:postal-code">
                        <xsl:value-of select="gz:Person/gz:PersonAddress/gz:AddressLineGroup/gz:Postcode"/>
                    </dd>
                </xsl:if>
            </xsl:if>

            <xsl:if test="gz:Person/gz:DeathDetails/gz:NoticeOfClaims">
                <dt>Executor/Administrator:</dt>
                <xsl:if test="gz:Person/gz:DeathDetails/gz:NoticeOfClaims/gz:CompanyName">
                    <dt>Company Name: </dt>
                    <dd about="this:estateExecutor" data-gazettes="company" datatype="xsd:string" property="foaf:name">
                        <xsl:value-of select="gz:Person/gz:DeathDetails/gz:NoticeOfClaims/gz:CompanyName"/>
                    </dd>
                </xsl:if>
                <xsl:if test="gz:Person/gz:DeathDetails/gz:NoticeOfClaims[not(gz:PersonName)]">
                    <dd about="this:estateExecutor" property="foaf:name" typeof="foaf:Agent">
                        <xsl:value-of select="gz:Person/gz:DeathDetails/gz:NoticeOfClaims"/>
                    </dd>
                </xsl:if>
                <xsl:if test="gz:Person/gz:DeathDetails/gz:NoticeOfClaims/gz:PersonName">
                    <xsl:variable name="personURI" select="string-join(('this:','estateExecutor'),'')"/>
                    <xsl:for-each select="gz:Person/gz:DeathDetails/gz:NoticeOfClaims/gz:PersonName/node()">
                        <xsl:apply-templates select="." mode="person2903">
                            <xsl:with-param name="personURI" select="$personURI"/>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:if>
                <xsl:if test="gz:Person/gz:DeathDetails/gz:NoticeOfClaims/gz:AddressLineGroup">
                    <xsl:apply-templates select="gz:Person/gz:DeathDetails/gz:NoticeOfClaims/gz:AddressLineGroup" mode="person2903">
                        <xsl:with-param name="personURI" select="$personURI"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:if>
            <xsl:if test="gz:Person/gz:AlsoKnownAs">
                <dt>Previous name/any other name/also known as name:</dt>
                <dd about="this:deceasedPerson" data-button="true" data-class-inner="add-names more" data-class-outer="add-names-link" data-name="add-more-names" data-title="Add more names" datatype="xsd:string" property="person:alsoKnownAs">
                    <xsl:value-of select="gz:Person/gz:AlsoKnownAs"/>
                </dd>
            </xsl:if>
            <xsl:if test="gz:Person/gz:Occupation">
                <dt>Deceased Occupation:</dt>
                <dd about="this:occupationOfDeceased" data-required="true" datatype="xsd:string" property="person:jobTitle">
                    <xsl:value-of select="gz:Person/gz:Occupation"/>
                </dd>
            </xsl:if>
            <xsl:if test="gz:Person/gz:DeathDetails/gz:NoticeOfClaimsRefNumber">
                <dt>Reference Number:</dt>
                <dd about="this:notifiableThing" datatype="xsd:string" property="gaz:claimNumber">
                    <xsl:value-of select="gz:Person/gz:DeathDetails/gz:NoticeOfClaimsRefNumber"/>
                </dd>
            </xsl:if>
        </dl>
        <xsl:if test="gz:Person/gz:DeathDetails/gz:NoticeOfClaimsDate">
            <dl>
                <dt>Claims Date:</dt>
                <dd about="this:notifiableThing" datatype="xsd:date" property="personal-legal:hasClaimDeadline">
                    <xsl:value-of select="gz:Person/gz:DeathDetails/gz:NoticeOfClaimsDate/@Date"/>
                </dd>
            </dl>
        </xsl:if>
    </xsl:template>

    <xsl:template match="@*|node()" mode="init">
        <xsl:param name="personURI"/>
        <xsl:variable name="rawname" select="if(.[1]=',') then substring(.,2) else (.)"/>
        <xsl:variable name="common_characters" select="('(',')','\(','\)',':')"/>
        <xsl:variable name="empty" select="('')"/>
        <xsl:variable name="list_formerly" select="('formerly known as','Formerly known as','formerly','Formerly')"/>
        <xsl:variable name="list_otherwise" select="('otherwise known as','Otherwise known as','otherwise','Otherwise')"/>
        <xsl:variable name="list_also" select="('also known as','Also known as','known as','Known as','aka ','also','previously known as','trading as','t/a')"/>
        <xsl:variable name="list_maiden" select="('maiden Name','maiden name','Maiden name','Maiden Surname','maiden surname','nee ','Nee ','née','Née','neé','Neé')"/>
        <xsl:for-each select="$rawname">
            <xsl:choose>
                <!-- Handling formerly text -->
                <xsl:when test="wlf:contains(.,$list_formerly)">
                    <xsl:variable name="formerly_text" select="wlf:replace-multi(.,$list_formerly,$empty)"/>
                    <xsl:variable name="clean_formerly_text" select="normalize-space(wlf:replace-multi(.,$common_characters,$empty))"/>
                    <!-- calling split function-->
                    <xsl:for-each select="tokenize($clean_formerly_text,',')">
                        <xsl:variable name="chunck" select="."/>
                        <xsl:for-each select="tokenize($chunck,' and ')">
                            <xsl:variable name="chunck_and" select="."/>
                            <xsl:for-each select="tokenize($chunck_and,';')">
                                <xsl:variable name="chunck_tmp" select="."/>
                                <!--call corresponding template-->
                                <xsl:call-template name="formerly">
                                    <xsl:with-param name="text" select="$chunck_tmp"/>
                                    <xsl:with-param name="personURI" select="$personURI"/>
                                    <xsl:with-param name="custom-title" select="false()"/>
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:when>
                <!-- Handling otherwise text -->
                <xsl:when test="wlf:contains(.,$list_otherwise)">
                    <xsl:variable name="otherwise_text" select="wlf:replace-multi(.,$list_otherwise,$empty)"/>
                    <xsl:variable name="clean_otherwise_text" select="normalize-space(wlf:replace-multi(.,$common_characters,$empty))"/>
                    <!-- calling split function-->
                    <xsl:for-each select="tokenize($clean_otherwise_text,',')">
                        <xsl:variable name="chunck" select="."/>
                        <xsl:for-each select="tokenize($chunck,' and ')">
                            <xsl:variable name="chunck_and" select="."/>
                            <xsl:for-each select="tokenize($chunck_and,';')">
                                <xsl:variable name="chunck_tmp" select="."/>
                                <!--call corresponding template-->
                                <xsl:call-template name="otherwise">
                                    <xsl:with-param name="text" select="$chunck_tmp"/>
                                    <xsl:with-param name="personURI" select="$personURI"/>
                                    <xsl:with-param name="custom-title" select="false()"/>
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:when>
                <!-- Handling also text -->
                <xsl:when test="wlf:contains(.,$list_also)">
                    <xsl:variable name="also_text" select="wlf:replace-multi(.,$list_also,$empty)"/>
                    <xsl:variable name="clean_also_text" select="normalize-space(wlf:replace-multi(.,$common_characters,$empty))"/>
                    <!-- calling split function-->
                    <xsl:value-of select="$clean_also_text"/>
                    <xsl:for-each select="tokenize($clean_also_text,',')">
                        <xsl:variable name="chunck" select="."/>
                        <xsl:for-each select="tokenize($chunck,' and ')">
                            <xsl:variable name="chunck_and" select="."/>
                            <xsl:for-each select="tokenize($chunck_and,';')">
                                <xsl:variable name="chunck_tmp" select="."/>
                                <!--call corresponding template-->
                                <xsl:call-template name="also">
                                    <xsl:with-param name="text" select="$chunck_tmp"/>
                                    <xsl:with-param name="personURI" select="$personURI"/>
                                    <xsl:with-param name="custom-title" select="false()"/>
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:when>
                <!-- Handling nee text -->
                <xsl:when test="wlf:contains(.,$list_maiden)">
                    <xsl:variable name="maiden_text" select="wlf:replace-multi(.,$list_maiden,$empty)"/>
                    <xsl:variable name="clean_maiden_text" select="normalize-space(wlf:replace-multi(.,$common_characters,$empty))"/>
                    <!-- calling split function-->
                    <xsl:for-each select="tokenize($clean_maiden_text,',')">
                        <xsl:variable name="chunck" select="."/>
                        <xsl:for-each select="tokenize($chunck,' and ')">
                            <xsl:variable name="chunck_and" select="."/>
                            <xsl:for-each select="tokenize($chunck_and,';')">
                                <xsl:variable name="chunck_tmp" select="."/>
                                <!--call corresponding template-->
                                <xsl:call-template name="maiden">
                                    <xsl:with-param name="text" select="$chunck_tmp"/>
                                    <xsl:with-param name="personURI" select="$personURI"/>
                                    <xsl:with-param name="custom-title" select="false()"/>
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:when>
                <!-- Handling text with brackets -->
                <xsl:when test="wlf:contains(.,'(')">
                    <xsl:variable name="text" select="normalize-space(replace(.,',',''))"/>
                    <xsl:if test="$text!=''">
                        <dt>Alternative name(s):</dt>
                        <dd typeof="gaz:Person" about="{$personURI}" property="person:alsoKnownAs">
                            <xsl:value-of select="normalize-space(wlf:replace-multi($text,$common_characters,$empty))"/>
                        </dd>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test=".!=''">
                        <span>
                            <xsl:variable name="thing" select="normalize-space(wlf:replace-multi(.,$common_characters,$empty))"/>
                            <xsl:choose>
                                <xsl:when test="starts-with($thing,',')">
                                    <xsl:attribute name="data-gazettes">prefix</xsl:attribute>
                                </xsl:when>
                                <xsl:when test="ends-with($thing,',')">
                                    <xsl:attribute name="data-gazettes">suffix</xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="data-gazettes">prefix</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:value-of select="normalize-space(replace($thing,',',''))"/>
                        </span>
                        <!--
              </dd>s
              XXX
             <xsl:apply-templates select="." mode="prefix2903">
                <xsl:with-param name="personURI" select="$personURI"/>
              </xsl:apply-templates>
            XXX-->
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="otherwise">
        <xsl:param name="text"/>
        <xsl:param name="personURI"/>
        <xsl:param name="custom-title"/>
        <xsl:param name="keyword"/>
        <xsl:variable name="common_characters" select="('(',')','\(','\)',':')"/>
        <xsl:variable name="empty" select="('')"/>
        <xsl:variable name="list_formerly" select="('formerly known as','Formerly known as','formerly','Formerly')"/>
        <xsl:variable name="list_otherwise" select="('otherwise known as','Otherwise known as','otherwise','Otherwise')"/>
        <xsl:variable name="list_also" select="('also known as','Also known as','known as','Known as','aka ','also','previously known as','trading as','t/a')"/>
        <xsl:variable name="list_maiden" select="('maiden Name','maiden name','Maiden name','Maiden Surname','maiden surname','nee ','Nee ','née','Née','neé','Neé')"/>
        <xsl:for-each select="$text">
            <xsl:choose>
                <!-- Handling formerly text -->
                <xsl:when test="wlf:contains(.,$list_formerly)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_formerly)"/>
                    <xsl:variable name="formerly_text" select="wlf:replace-multi(.,$list_formerly,$empty)"/>
                    <xsl:variable name="clean_formerly_text" select="normalize-space(wlf:replace-multi($formerly_text,$common_characters,$empty))"/>
                    <xsl:call-template name="formerly">
                        <xsl:with-param name="text" select="$clean_formerly_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling otherwise text -->
                <xsl:when test="wlf:contains(.,$list_otherwise)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_otherwise)"/>
                    <xsl:variable name="otherwise_text" select="wlf:replace-multi(.,$list_otherwise,$empty)"/>
                    <xsl:variable name="clean_otherwise_text" select="normalize-space(wlf:replace-multi($otherwise_text,$common_characters,$empty))"/>
                    <xsl:call-template name="otherwise">
                        <xsl:with-param name="text" select="$clean_otherwise_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling also text -->
                <xsl:when test="wlf:contains(.,$list_also)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_also)"/>
                    <xsl:variable name="also_text" select="wlf:replace-multi(.,$list_also,$empty)"/>
                    <xsl:variable name="clean_also_text" select="normalize-space(wlf:replace-multi($also_text,$common_characters,$empty))"/>
                    <xsl:call-template name="also">
                        <xsl:with-param name="text" select="$clean_also_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling nee text -->
                <xsl:when test="wlf:contains(.,$list_maiden)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_maiden)"/>
                    <xsl:variable name="maiden_text" select="wlf:replace-multi(.,$list_maiden,$empty)"/>
                    <xsl:variable name="clean_maiden_text" select="normalize-space(wlf:replace-multi($maiden_text,$common_characters,$empty))"/>
                    <xsl:call-template name="maiden">
                        <xsl:with-param name="text" select="$clean_maiden_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling text with brackets -->
                <xsl:when test="wlf:contains(.,'(')">
                    <dt>Alternative name(s):</dt>
                    <dd typeof="gaz:Person" about="{$personURI}" property="person:alsoKnownAs">
                        <xsl:value-of select="normalize-space(wlf:replace-multi(.,$common_characters,$empty))"/>
                    </dd>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$custom-title">
                            <dt data-gazettes="custom-title"><xsl:value-of select="wlf:capitalize-first($keyword)"/>:</dt>
                        </xsl:when>
                        <xsl:otherwise>
                            <dt data-copy-title="true"><xsl:value-of select="$keyword"/>:</dt>
                        </xsl:otherwise>
                    </xsl:choose>
                    <dd typeof="gaz:Person" about="{$personURI}" property="person:alsoKnownAs">
                        <xsl:variable name="otherwise_text" select="wlf:replace-multi(.,$list_otherwise,$empty)"/>
                        <xsl:variable name="clean_otherwise_text" select="normalize-space(wlf:replace-multi($otherwise_text,$common_characters,$empty))"/>
                        <xsl:value-of select="$clean_otherwise_text"/>
                    </dd>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="formerly">
        <xsl:param name="text"/>
        <xsl:param name="personURI"/>
        <xsl:param name="custom-title"/>
        <xsl:param name="keyword"/>
        <xsl:variable name="common_characters" select="('(',')','\(','\)',':')"/>
        <xsl:variable name="empty" select="('')"/>
        <xsl:variable name="list_formerly" select="('formerly known as','Formerly known as','formerly','Formerly')"/>
        <xsl:variable name="list_otherwise" select="('otherwise known as','Otherwise known as','otherwise','Otherwise')"/>
        <xsl:variable name="list_also" select="('also known as','Also known as','known as','Known as','aka ','also','previously known as','trading as','t/a')"/>
        <xsl:variable name="list_maiden" select="('maiden Name','maiden name','Maiden name','Maiden Surname','maiden surname','nee ','Nee ','née','Née','neé','Neé')"/>
        <xsl:for-each select="$text">
            <xsl:choose>
                <!-- Handling formerly text -->
                <xsl:when test="wlf:contains(.,$list_formerly)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_formerly)"/>
                    <xsl:variable name="formerly_text" select="wlf:replace-multi(.,$list_formerly,$empty)"/>
                    <xsl:variable name="clean_formerly_text" select="normalize-space(wlf:replace-multi($formerly_text,$common_characters,$empty))"/>
                    <xsl:call-template name="formerly">
                        <xsl:with-param name="text" select="$clean_formerly_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling otherwise text -->
                <xsl:when test="wlf:contains(.,$list_otherwise)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_otherwise)"/>
                    <xsl:variable name="otherwise_text" select="wlf:replace-multi(.,$list_otherwise,$empty)"/>
                    <xsl:variable name="clean_otherwise_text" select="normalize-space(wlf:replace-multi($otherwise_text,$common_characters,$empty))"/>
                    <xsl:call-template name="otherwise">
                        <xsl:with-param name="text" select="$clean_otherwise_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling also text -->
                <xsl:when test="wlf:contains(.,$list_also)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_also)"/>
                    <xsl:variable name="also_text" select="wlf:replace-multi(.,$list_also,$empty)"/>
                    <xsl:variable name="clean_also_text" select="normalize-space(wlf:replace-multi($also_text,$common_characters,$empty))"/>
                    <xsl:call-template name="also">
                        <xsl:with-param name="text" select="$clean_also_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling nee text -->
                <xsl:when test="wlf:contains(.,$list_maiden)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_maiden)"/>
                    <xsl:variable name="maiden_text" select="wlf:replace-multi(.,$list_maiden,$empty)"/>
                    <xsl:variable name="clean_maiden_text" select="normalize-space(wlf:replace-multi($maiden_text,$common_characters,$empty))"/>
                    <xsl:call-template name="maiden">
                        <xsl:with-param name="text" select="$clean_maiden_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling text with brackets -->
                <xsl:when test="wlf:contains(.,'(')">
                    <dt>Alternative name(s):</dt>
                    <dd typeof="gaz:Person" about="{$personURI}" property="person:alsoKnownAs">
                        <xsl:value-of select="normalize-space(wlf:replace-multi(.,$common_characters,$empty))"/>
                    </dd>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$custom-title">
                            <dt data-gazettes="custom-title"><xsl:value-of select="wlf:capitalize-first($keyword)"/>:</dt>
                        </xsl:when>
                        <xsl:otherwise>
                            <dt data-copy-title="true"><xsl:value-of select="$keyword"/>:</dt>
                        </xsl:otherwise>
                    </xsl:choose>
                    <dd typeof="gaz:Person" about="{$personURI}" property="person:alsoKnownAs">
                        <xsl:variable name="formerly_text" select="wlf:replace-multi(.,$list_formerly,$empty)"/>
                        <xsl:variable name="clean_formerly_text" select="normalize-space(wlf:replace-multi($formerly_text,$common_characters,$empty))"/>
                        <xsl:value-of select="$clean_formerly_text"/>
                    </dd>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="also">
        <xsl:param name="text"/>
        <xsl:param name="personURI"/>
        <xsl:param name="custom-title"/>
        <xsl:param name="keyword"/>
        <xsl:variable name="common_characters" select="('(',')','\(','\)',':')"/>
        <xsl:variable name="empty" select="('')"/>
        <xsl:variable name="list_formerly" select="('formerly known as','Formerly known as','formerly','Formerly')"/>
        <xsl:variable name="list_otherwise" select="('otherwise known as','Otherwise known as','otherwise','Otherwise')"/>
        <xsl:variable name="list_also" select="('also known as','Also known as','known as','Known as','aka ','also','previously known as','trading as','t/a')"/>
        <xsl:variable name="list_maiden" select="('maiden Name','maiden name','Maiden name','Maiden Surname','maiden surname','nee ','Nee ','née','Née','neé','Neé')"/>
        <xsl:for-each select="$text">
            <xsl:choose>
                <!-- Handling formerly text -->
                <xsl:when test="wlf:contains(.,$list_formerly)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_formerly)"/>
                    <xsl:variable name="formerly_text" select="wlf:replace-multi(.,$list_formerly,$empty)"/>
                    <xsl:variable name="clean_formerly_text" select="normalize-space(wlf:replace-multi($formerly_text,$common_characters,$empty))"/>
                    <xsl:call-template name="formerly">
                        <xsl:with-param name="text" select="$clean_formerly_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling otherwise text -->
                <xsl:when test="wlf:contains(.,$list_otherwise)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_otherwise)"/>
                    <xsl:variable name="otherwise_text" select="wlf:replace-multi(.,$list_otherwise,$empty)"/>
                    <xsl:variable name="clean_otherwise_text" select="normalize-space(wlf:replace-multi($otherwise_text,$common_characters,$empty))"/>
                    <xsl:call-template name="otherwise">
                        <xsl:with-param name="text" select="$clean_otherwise_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling also text -->
                <xsl:when test="wlf:contains(.,$list_also)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_also)"/>
                    <xsl:variable name="also_text" select="wlf:replace-multi(.,$list_also,$empty)"/>
                    <xsl:variable name="clean_also_text" select="normalize-space(wlf:replace-multi($also_text,$common_characters,$empty))"/>
                    <xsl:call-template name="also">
                        <xsl:with-param name="text" select="$clean_also_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling nee text -->
                <xsl:when test="wlf:contains(.,$list_maiden)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_maiden)"/>
                    <xsl:variable name="maiden_text" select="wlf:replace-multi(.,$list_maiden,$empty)"/>
                    <xsl:variable name="clean_maiden_text" select="normalize-space(wlf:replace-multi($maiden_text,$common_characters,$empty))"/>
                    <xsl:call-template name="maiden">
                        <xsl:with-param name="text" select="$clean_maiden_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling text with brackets -->
                <xsl:when test="wlf:contains(.,'(')">
                    <dt>Alternative name(s):</dt>
                    <dd typeof="gaz:Person" about="{$personURI}" property="person:alsoKnownAs">
                        <xsl:value-of select="normalize-space(wlf:replace-multi(.,$common_characters,$empty))"/>
                    </dd>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$custom-title">
                            <dt data-gazettes="custom-title"><xsl:value-of select="wlf:capitalize-first($keyword)"/>:</dt>
                        </xsl:when>
                        <xsl:otherwise>
                            <dt data-copy-title="true"><xsl:value-of select="$keyword"/>:</dt>
                        </xsl:otherwise>
                    </xsl:choose>
                    <dd typeof="gaz:Person" about="{$personURI}" property="person:alsoKnownAs">
                        <xsl:variable name="also_text" select="wlf:replace-multi(.,$list_also,$empty)"/>
                        <xsl:variable name="clean_also_text" select="normalize-space(wlf:replace-multi($also_text,$common_characters,$empty))"/>
                        <xsl:value-of select="$clean_also_text"/>
                    </dd>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="maiden">
        <xsl:param name="text"/>
        <xsl:param name="personURI"/>
        <xsl:param name="custom-title"/>
        <xsl:param name="keyword"/>
        <xsl:variable name="common_characters" select="('(',')','\(','\)',':')"/>
        <xsl:variable name="empty" select="('')"/>
        <xsl:variable name="list_formerly" select="('formerly known as','Formerly known as','formerly','Formerly')"/>
        <xsl:variable name="list_otherwise" select="('otherwise known as','Otherwise known as','otherwise','Otherwise')"/>
        <xsl:variable name="list_also" select="('also known as','Also known as','known as','Known as','aka ','also','previously known as','trading as','t/a')"/>
        <xsl:variable name="list_maiden" select="('maiden Name','maiden name','Maiden name','Maiden Surname','maiden surname','nee ','Nee ','née','Née','neé','Neé')"/>
        <xsl:for-each select="$text">
            <xsl:choose>
                <!-- Handling formerly text -->
                <xsl:when test="wlf:contains(.,$list_formerly)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_formerly)"/>
                    <xsl:variable name="formerly_text" select="wlf:replace-multi(.,$list_formerly,$empty)"/>
                    <xsl:variable name="clean_formerly_text" select="normalize-space(wlf:replace-multi($formerly_text,$common_characters,$empty))"/>
                    <xsl:call-template name="formerly">
                        <xsl:with-param name="text" select="$clean_formerly_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling otherwise text -->
                <xsl:when test="wlf:contains(.,$list_otherwise)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_otherwise)"/>
                    <xsl:variable name="otherwise_text" select="wlf:replace-multi(.,$list_otherwise,$empty)"/>
                    <xsl:variable name="clean_otherwise_text" select="normalize-space(wlf:replace-multi($otherwise_text,$common_characters,$empty))"/>
                    <xsl:call-template name="otherwise">
                        <xsl:with-param name="text" select="$clean_otherwise_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling also text -->
                <xsl:when test="wlf:contains(.,$list_also)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_also)"/>
                    <xsl:variable name="also_text" select="wlf:replace-multi(.,$list_also,$empty)"/>
                    <xsl:variable name="clean_also_text" select="normalize-space(wlf:replace-multi($also_text,$common_characters,$empty))"/>
                    <xsl:call-template name="also">
                        <xsl:with-param name="text" select="$clean_also_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling nee text -->
                <xsl:when test="wlf:contains(.,$list_maiden)">
                    <xsl:variable name="keyword" select="wlf:containsKeyword(.,$list_maiden)"/>
                    <xsl:variable name="maiden_text" select="wlf:replace-multi(.,$list_maiden,$empty)"/>
                    <xsl:variable name="clean_maiden_text" select="normalize-space(wlf:replace-multi($maiden_text,$common_characters,$empty))"/>
                    <xsl:call-template name="maiden">
                        <xsl:with-param name="text" select="$clean_maiden_text"/>
                        <xsl:with-param name="personURI" select="$personURI"/>
                        <xsl:with-param name="custom-title" select="true()"/>
                        <xsl:with-param name="keyword" select="$keyword"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- Handling text with brackets -->
                <xsl:when test="wlf:contains(.,'(')">
                    <dt>Alternative name(s):</dt>
                    <dd typeof="gaz:Person" about="{$personURI}" property="person:alsoKnownAs">
                        <xsl:value-of select="normalize-space(wlf:replace-multi(.,$common_characters,$empty))"/>
                    </dd>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$custom-title">
                            <dt data-gazettes="custom-title"><xsl:value-of select="wlf:capitalize-first($keyword)"/>:</dt>
                        </xsl:when>
                        <xsl:otherwise>
                            <dt data-copy-title="true"><xsl:value-of select="$keyword"/>:</dt>
                        </xsl:otherwise>
                    </xsl:choose>
                    <dd typeof="gaz:Person" about="{$personURI}" property="person:hasMaidenName">
                        <xsl:variable name="maiden_text" select="wlf:replace-multi(.,$list_maiden,$empty)"/>
                        <xsl:variable name="clean_maiden_text" select="normalize-space(wlf:replace-multi($maiden_text,$common_characters,$empty))"/>
                        <xsl:value-of select="$clean_maiden_text"/>
                    </dd>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>


    <!-- ######################## -->
    <!-- ##### ukm:Metadata ##### -->
    <!-- ######################## -->
    <xsl:template match="ukm:Metadata"/>
    <!-- Suppress this -->

    <!-- ############################ -->
    <!-- ##### NOTICE TOP LEVEL ##### -->
    <!-- ############################ -->
    <xsl:template match="gz:Notice/gz:Title">
        <xsl:choose>
            <xsl:when test="$noticeCode = '1101'">
                <xsl:if test="count(preceding-sibling::gz:Title) &lt; 1">
                    <h3>
                        <span data-gazettes="Title" property="gaz:has{name()}">
                            <!--concat all the titles in one-->
                            <xsl:call-template name="join">
                                <xsl:with-param name="valueList" select="..//gz:Title"/>
                                <xsl:with-param name="separator" select="' '"/>
                            </xsl:call-template>
                        </span>
                    </h3>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <h3>
                    <span data-gazettes="Title" property="gaz:has{name()}">
                        <xsl:value-of select="upper-case(wlf:serialize(.))"/>
                    </span>
                </h3>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Utility template 'join' accepts valueList and separator. -->
    <xsl:template name="join">
        <xsl:param name="valueList" select="''"/>
        <xsl:param name="separator" select="','"/>
        <xsl:for-each select="$valueList">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($separator, .) "/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!-- Handle individual element types in the source data. -->
    <xsl:template match="gz:Notice/gz:Legislation">
        <h3 data-gazettes="Legislation">
            <span about="this:notifiableThing" property="gaz:isEnabledByLegislation" resource="{wlf:clean(wlf:serialize(.))}" typeof="leg:Legislation" data-gazettes="Legislation">
                <span about="{wlf:clean(wlf:serialize(.))}" property="rdfs:label" content="{wlf:serialize(.)}">
                    <xsl:value-of select="upper-case(wlf:serialize(.))"/>
                </span>
            </span>
        </h3>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Note">
        <div data-gazettes="Note">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Note/gz:P">
        <!-- Note that paragraphs can be nested in the source data, but this is not permitted in the XHTML output. -->
        <p data-gazettes="Text">
            <xsl:text>Note: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Note/gz:P/gz:Text">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:P">
        <!-- Note that paragraphs can be nested in the source data, but this is not permitted in the XHTML output. -->
        <xsl:choose>
            <!-- Grab pieces of text starting with a • and consider them to be a list as well -->
            <xsl:when test="count(gz:Text/text()) = 1 and starts-with(gz:Text/text(),'•')">
                <ul data-created-bullet="true" class="bullet-list">
                    <xsl:if test="@SpaceBefore">
                        <xsl:attribute name="data-gazettes-space-before" select="@SpaceBefore"/>
                    </xsl:if>
                    <li>
                        <xsl:value-of select="normalize-space(replace(replace(replace(gz:Text/text(),'•',''),'&#x2002;',' '),'&#x2003;',' '))"/>
                    </li>
                </ul>
            </xsl:when>
            <xsl:when test="child::gz:AwardName">
                <xsl:choose>
                    <xsl:when test="$noticeCode='1126'">
                        <div data-gazettes="Award">
                            <xsl:next-match/>
                        </div>
                    </xsl:when>
                    <xsl:when test="$noticeCode=('1127','1130','1131','1132','1133','1134','1135','1136')">
                        <div data-gazettes="Award">
                            <xsl:next-match/>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div data-gazettes="Award" property="honours:isAwarded" resource="this:award" typeof="honours:{$honour}">
                            <xsl:next-match/>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="gz:AwardDivision and $noticeCode='1131'">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <div data-gazettes="P">
                    <xsl:next-match/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:P">
        <!-- Note that paragraphs can be nested in the source data, but this is not permitted in the XHTML output. -->
        <xsl:apply-templates select="gz:Text"/>
        <xsl:choose>
            <xsl:when test="gz:P1">
                <ul class="numbered">
                    <xsl:apply-templates select="gz:P1"/>
                </ul>
            </xsl:when>
            <xsl:when test="gz:P2">
                <ul class="numbered">
                    <xsl:apply-templates select="gz:P2"/>
                </ul>
            </xsl:when>
            <xsl:when test="gz:P3">
                <ul class="numbered">
                    <xsl:apply-templates select="gz:P3"/>
                </ul>
            </xsl:when>
            <xsl:when test="gz:P4">
                <ul class="numbered">
                    <xsl:apply-templates select="gz:P4"/>
                </ul>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="* except gz:Text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="gz:Notice/gz:P/gz:Text">
        <!-- Note that paragraphs can be nested in the source data, but this is not permitted in the XHTML output. -->
        <p data-gazettes="Text">
            <xsl:if test="gz:Authority">
                <xsl:attribute name="about">
                    <xsl:text>this:authoriser</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- #################################### -->
    <!-- ##### COMPANY RELATED ELEMENTS ##### -->
    <!-- #################################### -->
    <xsl:template match="gz:Notice/gz:Company">
        <xsl:variable name="prop">
            <xsl:choose>
                <xsl:when test="substring($noticeType,1,2)='25'">insolvency:hasCompany</xsl:when>
                <xsl:when test="substring($noticeType,1,2)='24'">insolvency:hasCompany</xsl:when>
                <xsl:otherwise>gaz:hasCompany</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="companyType">
            <xsl:choose>
                <xsl:when test="$noticeType=('2450','2411','2421','2410','2432','2423','2459','2404','2452', 
          '2462','2464','2407','2406','2445','2435','2412','2444','2442',
          '2434','2422','2401','2402','2408','2460','2446','2433','2413',
          '2441','2431','2451','2453','2458','2443','2454','2455','2403','2461' )">
                    <xsl:choose>
                        <xsl:when test="lower-case(./gz:CompanyType)= 'unregistered'">
                            <xsl:text>gazorg:UnregisteredCompany</xsl:text>
                        </xsl:when>
                        <xsl:when test="lower-case(./gz:CompanyType) = 'limitedcompany'">
                            <xsl:text>gazorg:LimitedCompany</xsl:text>
                        </xsl:when>
                        <xsl:when test="lower-case(./gz:CompanyType) = 'societyclub'">
                            <xsl:text>gazorg:SocietyClub</xsl:text>
                        </xsl:when>
                        <xsl:when test="lower-case(./gz:CompanyType) = 'overseascompany'">
                            <xsl:text>gazorg:OverseasCompany</xsl:text>
                        </xsl:when>
                        <xsl:when test="lower-case(./gz:CompanyType) = 'partnership'">
                            <xsl:text>gazorg:Partnership</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>gazorg:LimitedCompany</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>gazorg:LimitedCompany</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div data-gazettes="Company" property="{$prop}" resource="{wlf:name-sibling(.)}" typeof="{$companyType}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="gz:CorporateBody/gz:Company">
        <div rel="gaz:hasCompany">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="gz:Notice//gz:Company/gz:CompanyName">
        <xsl:choose>
            <xsl:when test="$isCompanyLawNotice">
                <p>
                    <xsl:text>Name: </xsl:text>
                    <strong data-gazettes="CompanyName" about="http://business.data.gov.uk/id/company/{$companyNumber}" typeof="gazorg:Company" datatype="xsd:string" property="{$has-company-name}">
                        <xsl:value-of select="upper-case(.)"/>
                    </strong>
                </p>
            </xsl:when>
            <xsl:when test="$noticeCode = (2432, 2443)">
                <p>
                    <xsl:text>Name of Company: </xsl:text>
                    <strong property="{$has-company-name}" datatype="xsd:string" data-gazettes="CompanyName" data-gazettes-class="{@Class}">
                        <xsl:value-of select="upper-case(.)"/>
                    </strong>
                </p>
            </xsl:when>
            <xsl:when test="$noticeCode = 2603">
                <p>
                    <xsl:text>Company Name: </xsl:text>
                    <strong property="{$has-company-name}" datatype="xsd:string" data-gazettes="CompanyName" data-gazettes-class="{@Class}">
                        <xsl:value-of select="upper-case(.)"/>
                    </strong>
                </p>
            </xsl:when>
            <xsl:when test="$noticeCode = 2450 and $edition = 'Edinburgh'">
                <p>
                    <strong property="{$has-company-name}" datatype="xsd:string" data-gazettes="CompanyName" data-gazettes-class="{@Class}">
                        <xsl:value-of select="upper-case(.)"/>
                    </strong>
                </p>
            </xsl:when>
            <xsl:when test="$noticeCode = (2450, 2459, 2461, 2462, 2608, 2610, 2613, 2614)">
                <p>
                    <xsl:text>In the Matter of </xsl:text>
                    <strong property="{$has-company-name}" datatype="xsd:string" data-gazettes="CompanyName" data-gazettes-class="{@Class}">
                        <xsl:value-of select="upper-case(.)"/>
                    </strong>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <h3>
                    <span property="{$has-company-name}" datatype="xsd:string" data-gazettes="CompanyName" data-gazettes-class="{@Class}">
                        <xsl:value-of select="upper-case(.)"/>
                    </span>
                </h3>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="gz:Notice/gz:Company/gz:CompanyType"> </xsl:template>

    <xsl:template match="gz:Notice/gz:CorporateBody/gz:DocumentType">
        <p>
            <xsl:text>Document Type: </xsl:text>
            <strong datatype="xsd:string" data-gazettes="DocumentType">
                <xsl:value-of select="(.)"/>
            </strong>
        </p>
    </xsl:template>

    <!--<xsl:template match="gz:Notice/gz:CorporateBody/gz:Company/gz:CompanyName">
		<xsl:choose>
			<xsl:when test="$noticeCode = (3501)">
				<p>
					<xsl:text>Name of Company: </xsl:text>
					<strong property="{$has-company-name}" datatype="xsd:string"
						data-gazettes="CompanyName" data-gazettes-class="{@Class}">
						<xsl:value-of select="upper-case(.)" />
					</strong>
				</p>
			</xsl:when>
		</xsl:choose>
	</xsl:template>-->

    <xsl:template match="gz:Company/gz:CompanyNumber">
        <xsl:choose>
            <xsl:when test="$edition = 'London' or $edition = 'Belfast'">
                <xsl:choose>
                    <xsl:when test="$noticeCode = (2301, 2410, 2411, 2412, 2413, 2421, 2422, 2423, 2431, 2433, 2434, 2435, 2441, 2442, 2444, 2445, 2446, 2450, 2452, 2454, 2455, 2456, 2457, 2458, 2459, 2460, 2461, 2462, 2601, 2602, 2608, 2609, 2610, 2613, 2614)">
                        <p>
                            <xsl:text>(Company Number </xsl:text>
                            <span property="{$has-company-number}" datatype="xsd:string" data-gazettes="CompanyNumber">
                                <xsl:apply-templates/>
                            </span>
                            <xsl:text>)</xsl:text>
                        </p>
                    </xsl:when>
                    <xsl:when test="$noticeCode = (2401, 2402, 2432, 2443, 2603)">
                        <p>
                            <xsl:text>Company Number: </xsl:text>
                            <span property="{$has-company-number}" datatype="xsd:string" data-gazettes="CompanyNumber">
                                <xsl:apply-templates/>
                            </span>
                        </p>
                    </xsl:when>
                    <xsl:when test="$noticeCode = (2447, 2414, 2520, 2465, 2424, 2409, 2528)">
                        <p>
                            <xsl:text>Company Number: (</xsl:text>
                            <span property="{$has-company-number}" datatype="xsd:string" data-gazettes="CompanyNumber">
                                <xsl:apply-templates/>
                            </span>
                            <xsl:text>)</xsl:text>
                        </p>
                    </xsl:when>
                    <xsl:when test="$isCompanyLawNotice">
                        <p>
                            <xsl:if test="substring($noticeCode,1,2)='32'">
                                <xsl:text>Company Number: </xsl:text>
                            </xsl:if>
                            <xsl:if test="substring($noticeCode,1,2)='34'">
                                <xsl:text>LLP Number: </xsl:text>
                            </xsl:if>
                            <xsl:if test="substring($noticeCode,1,2)='35'">
                                <xsl:text>SE Number: </xsl:text>
                            </xsl:if>
                            <strong property="{$has-company-number}" datatype="xsd:string" data-gazettes="CompanyNumber" about="http://business.data.gov.uk/id/company/{$companyNumber}" typeof="gazorg:Company">
                                <xsl:apply-templates/>
                            </strong>
                        </p>
                    </xsl:when>
                    <xsl:otherwise>
                        <span property="{$has-company-number}" datatype="xsd:string" data-gazettes="CompanyNumber">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$edition = 'Edinburgh' and not($isCompanyLawNotice)">
                <p>
                    <xsl:text>Company Number: </xsl:text>
                    <span property="{$has-company-number}" datatype="xsd:string" data-gazettes="CompanyNumber">
                        <xsl:apply-templates/>
                    </span>
                </p>
            </xsl:when>
            <xsl:when test="$edition = 'Edinburgh' and $isCompanyLawNotice">
                <p>
                    <xsl:if test="substring($noticeCode,1,2)='32'">
                        <xsl:text>Company Number: </xsl:text>
                    </xsl:if>
                    <xsl:if test="substring($noticeCode,1,2)='34'">
                        <xsl:text>LLP Number: </xsl:text>
                    </xsl:if>
                    <xsl:if test="substring($noticeCode,1,2)='35'">
                        <xsl:text>SE Number: </xsl:text>
                    </xsl:if>
                    <strong property="{$has-company-number}" datatype="xsd:string" data-gazettes="CompanyNumber" about="http://business.data.gov.uk/id/company/{$companyNumber}" typeof="gazorg:Company">
                        <xsl:apply-templates/>
                    </strong>
                </p>
            </xsl:when>
        </xsl:choose>
    </xsl:template>



    <xsl:template match="gz:Notice/gz:Company/gz:CompanyStatus">
        <p>
            <span property="gazorg:status" datatype="xsd:string" data-gazettes="CompanyStatus">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>


    <xsl:template match="gz:CompanyGroup">
        <p property="{$has-company-group}" datatype="xsd:string" data-gazettes="CompanyGroup">
            <xsl:choose>
                <xsl:when test="$noticeCode = (2450, 2459, 2461, 2462, 2610, 2613, 2614)">
                    <xsl:text>and in the Matter of the </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>And In the Matter of </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:CompanyGroup/gz:Legislation">
        <span about="this:notifiableThing" property="gaz:isEnabledByLegislation" resource="{wlf:clean(wlf:serialize(.))}" typeof="leg:Legislation" data-gazettes="Legislation">
            <span about="{wlf:clean(wlf:serialize(.))}" property="rdfs:label" content="{wlf:serialize(.)}">
                <xsl:apply-templates/>
            </span>
        </span>
    </xsl:template>


    <xsl:template match="gz:Notice/gz:Company/gz:CompanyOtherNames">
        <xsl:choose>
            <xsl:when test="$noticeCode = (2447, 2414, 2520, 2465, 2424, 2409, 2528)">
                <xsl:if test="gz:CompanyPrevious/gz:CompanyName">
                    <p>
                        <xsl:text>previously </xsl:text>
                        <xsl:apply-templates select="gz:CompanyPrevious/gz:CompanyName"/>
                    </p>
                </xsl:if>
                <xsl:if test="gz:TradingAs">
                    <p>
                        <xsl:text>trading as </xsl:text>
                        <span property="gazorg:isTradingAs" data-gazettes="TradingAs">
                            <xsl:apply-templates select="gz:TradingAs"/>
                        </span>
                    </p>
                </xsl:if>
                <xsl:if test="gz:CompanyPrevious/gz:TradingAs">
                    <p>
                        <xsl:text>previously trading as </xsl:text>
                        <span property="gazorg:isTradingAs" data-gazettes="TradingAs">
                            <xsl:apply-templates select="gz:CompanyPrevious/gz:TradingAs"/>
                        </span>
                    </p>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="*">
                    <p>
                        <xsl:choose>
                            <xsl:when test="self::gz:TradingAs">
                                <xsl:choose>
                                    <xsl:when test="@Type">
                                        <xsl:value-of select="@Type"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>Trading Name: </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <span property="gazorg:isTradingAs" data-gazettes="TradingAs">
                                    <xsl:apply-templates/>
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="@Type">
                                        <xsl:value-of select="@Type"/>
                                    </xsl:when>
                                    <xsl:when test="self::gz:CompanyPrevious">
                                        <xsl:text>Previous Name of Company: </xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:apply-templates/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </p>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:NatureOfBusiness">
        <p data-gazettes="NatureOfBusiness">
            <xsl:choose>
                <xsl:when test="$noticeCode = (2401, 2402, 2410, 2411, 2421, 2432, 2443)">
                    <xsl:text>Nature of Business: </xsl:text>
                </xsl:when>
            </xsl:choose>
            <span property="{$has-nature-of-business}" datatype="xsd:string">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>


    <xsl:template match="gz:TradeClassification">
        <xsl:choose>
            <xsl:when test="parent::gz:CompanyGroup">
                <span data-gazettes="TradeClassification">
                    <xsl:text>Trade classification: </xsl:text>
                    <span property="{$has-trade-classification}" datatype="xsd:string">
                        <xsl:value-of select="./@Class"/>
                        <xsl:apply-templates/>
                    </span>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <p data-gazettes="TradeClassification">
                    <xsl:text>Trade classification: </xsl:text>
                    <span property="{$has-trade-classification}" datatype="xsd:string">
                        <xsl:value-of select="./@Class"/>
                        <xsl:apply-templates/>
                    </span>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Company/gz:TypeOfLiquidation">
        <p data-gazettes="TypeOfLiquidation">
            <xsl:if test="$noticeCode = (2432, 2443)">
                <xsl:text>Type of Liquidation: </xsl:text>
            </xsl:if>
            <span property="{$has-liquidation-type}" datatype="xsd:string">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Company/gz:CompanyRegisteredOffice">
        <p property="{$has-registered-office}" resource="{wlf:compound-name(..,.)}" typeof="vcard:Address" data-gazettes="CompanyRegisteredOffice">
            <xsl:text>Registered office: </xsl:text>
            <span property="vcard:label">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Company/gz:PrincipalTradingAddress">
        <p property="{$has-principal-trading-address}" resource="{wlf:compound-name(..,.)}" typeof="vcard:Address" data-gazettes="PrincipalTradingAddress">
            <xsl:text>Principal trading address: </xsl:text>
            <span property="vcard:label">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Company/gz:CompanyRegisteredCountries">
        <p property="{$is-registered-in}" data-gazettes="CompanyRegisteredCountries">
            <xsl:text>Countries where registered: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- SNC structural change -->
    <xsl:template match="gz:Notice/gz:Company//gz:AddressLineGroup">
        <span property="vcard:label" content="{wlf:serialize(.)}"/>
        <xsl:apply-templates/>
    </xsl:template>
    <!--xsl:template match="gz:Company//gz:AddressLineGroup/gz:AddressLine[1]"><span property="vcard:street-address" data-gazettes="AddressLine"><xsl:apply-templates/></span></xsl:template>
  
  <xsl:template match="gz:Company//gz:AddressLine[position() &gt; 1]"><span property="vcard:extended-address" data-gazettes="AddressLine"><xsl:apply-templates/></span></xsl:template>
  
  <xsl:template match="gz:Company//gz:Postcode"><span property="vcard:postal-code" data-gazettes="Postcode"><xsl:apply-templates/></span></xsl:template-->

    <xsl:template match="gz:CompanyPrevious/gz:CompanyName">
        <span property="gazorg:previousCompanyName" data-gazettes="CompanyName" data-gazettes-class="{@Class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:CompanyOtherNames/gz:TradingAs">
        <span property="gazorg:isTradingAs" data-gazettes="TradingAs">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- ######################################## -->
    <!-- ##### PARTNERSHIP RELATED ELEMENTS ##### -->
    <!-- ######################################## -->
    <xsl:template match="gz:Notice/gz:Partnership">
        <xsl:variable name="prop">
            <xsl:choose>
                <xsl:when test="substring($noticeType,1,2)='25'">insolvency:hasCompany</xsl:when>
                <xsl:when test="substring($noticeType,1,2)='24'">insolvency:hasCompany</xsl:when>
                <xsl:otherwise>gaz:hasCompany</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div property="{$prop}" resource="{wlf:name-sibling(.)}" typeof="gazorg:Partnership" data-gazettes="Partnership">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Partnership/gz:PartnershipName">
        <h3>
            <span property="gazorg:name" datatype="xsd:string" data-gazettes="PartnershipName">
                <xsl:apply-templates/>
            </span>
        </h3>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Partnership/gz:PartnershipAddress">
        <p property="vcard:adr" resource="{wlf:compound-name(..,.)}" typeof="vcard:Address" data-gazettes="PartnershipAddress">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Partnership/gz:PartnershipNumber">
        <p property="gazorg:partnershipNumber" datatype="xsd:string" data-gazettes="PartnershipNumber">
            <xsl:text>(Registered No. </xsl:text>
            <xsl:apply-templates/>
            <xsl:text>)</xsl:text>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Partnership/gz:PartnershipDetails">
        <p property="{$has-partnership-details}" datatype="xsd:string" data-gazettes="PartnershipDetails">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Partnership/gz:PartnershipPrevious">
        <p property="{$has-previous-partnership}" datatype="xsd:string" data-gazettes="PartnershipPrevious">
            <xsl:text>Previous partnership: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- ################## -->
    <!-- ##### COURTS ##### -->
    <!-- ################## -->
    <xsl:template match="gz:Notice/gz:Court">
        <div property="{$has-court-case}" resource="this:courtCase" typeof="court:CourtCase" data-gazettes="Court">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Court/gz:CourtName">
        <p property="{$has-court}" resource="this:court" typeof="court:Court">
            <xsl:text>In the </xsl:text>
            <span property="{$has-court-name}" datatype="xsd:string" data-gazettes="CourtName">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>
    <xsl:template match="gz:Notice/gz:Court/gz:CourtDistrict">
        <xsl:variable name="fs" select="following-sibling::gz:CourtNumber"/>
        <p>
            <span data-gazettes="CourtDistrict" resource="this:court" property="{$has-court-district}" datatype="xsd:string">
                <xsl:apply-templates/>
            </span>
            <xsl:text> </xsl:text>
            <xsl:if test="$fs[@Number]">
                <span data-gazettes="CourtNumber" data-court-number="{$fs/@Number}" data-year="{$fs/@Year}">
                    <xsl:text>No </xsl:text>
                    <span property="{$has-court-number}" datatype="xsd:string">
                        <xsl:if test="$fs = ''">
                            <xsl:value-of select="$fs/@Number"/>
                        </xsl:if>
                        <xsl:value-of select="$fs"/>
                    </span>
                    <xsl:text> of </xsl:text>
                    <span property="{$has-court-year}" datatype="xsd:gYear" content="{$fs/@Year}">
                        <xsl:value-of select="$fs/@Year"/>
                    </span>
                </span>
            </xsl:if>
            <xsl:if test="$fs[@Code]">
                <span data-gazettes="CourtNumber" data-court-code="{$fs/@Code}">
                    <xsl:text>Court Number: </xsl:text>
                    <span property="{$has-court-code}" datatype="xsd:string">
                        <xsl:value-of select="$fs/@Code"/>
                    </span>
                </span>
            </xsl:if>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Court/gz:CourtNumber">
        <xsl:if test="not(preceding-sibling::gz:CourtDistrict)">
            <xsl:if test="@Number">
                <p data-gazettes="CourtNumber" data-court-number="{@Number}" data-year="{@Year}">
                    <xsl:text>No </xsl:text>
                    <span property="{$has-court-number}" datatype="xsd:string">
                        <xsl:if test=". = ''">
                            <xsl:value-of select="@Number"/>
                        </xsl:if>
                        <xsl:apply-templates/>
                    </span>
                    <xsl:text> of </xsl:text>
                    <span property="{$has-court-year}" datatype="xsd:gYear">
                        <xsl:value-of select="@Year"/>
                    </span>
                </p>
            </xsl:if>
            <xsl:if test="@Code">
                <p data-gazettes="CourtNumber" data-court-code="{@Code}">
                    <span>
                        <xsl:text>Court Number: </xsl:text>
                        <span property="{$has-court-code}" datatype="xsd:string">
                            <xsl:value-of select="@Code"/>
                        </span>
                    </span>
                </p>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Court/gz:CourtPrevious">
        <p property="{$has-court-previous}" datatype="xsd:string" data-gazettes="CourtPrevious">
            <xsl:text>Previous court: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Court/gz:PetitionFilingDate">
        <p resource="this:notifiableThing" property="{$recognizes-petition-filing-date}" datatype="xsd:date" content="{@Date}" data-gazettes="PetitionFilingDate" data-date="{@Date}">
            <xsl:text>Date of Filing Petition: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Court/gz:WindingUpOrderDate">
        <p resource="this:notifiableThing" property="{$recognizes-winding-up-order-date}" datatype="xsd:date" content="{@Date}" data-gazettes="WindingUpOrderDate" data-date="{@Date}">
            <xsl:text>Date of Winding-up Order: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Court/gz:VolWindingUpResolutionDate">
        <p about="this:notifiableThing" property="{$recognizes-vol-winding-up-resolution-date}" datatype="xsd:date" data-gazettes="VolWindingUpResolutionDate" data-date="{@Date}">
            <xsl:text>Date of Resolution for Voluntary Winding-up: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Court/gz:BankruptcyOrderTime">
        <p data-gazettes="BankruptcyOrderTime" data-time="{.}">
            <xsl:text>Time of Bankruptcy Order: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Court/gz:BankruptcyOrderDate">
        <!-- Need to build dateTime value, but time may be missing -->
        <xsl:variable name="time">
            <xsl:choose>
                <xsl:when test="../gz:BankruptcyOrderTime">
                    <xsl:value-of select="../gz:BankruptcyOrderTime"/>
                </xsl:when>
                <xsl:otherwise>00:00</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <p about="this:notifiableThing" property="insolvency:dateOfBankruptcyOrder" content="{concat(@Date,concat('T',concat($time,':00')))}" datatype="xsd:dateTime" data-gazettes="BankruptcyOrderDate" data-date="{@Date}">
            <xsl:text>Bankruptcy order date: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Court/gz:BankruptcyRestrictions">
        <p about="this:notifiableThing" property="{$applies-bankruptcy-restrictions}" datatype="xsd:date" data-gazettes="BankruptcyRestrictions">
            <xsl:text>Bankruptcy restrictions: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Court/gz:TypeOfPetition">
        <p resource="this:notifiableThing" property="insolvency:typeOfPetition" datatype="xsd:string" content="{wlf:serialize(.)}" data-gazettes="TypeOfPetition">
            <xsl:text>Whether Debtor's or Creditor's Petition&#151;</xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- ##################### -->
    <!-- ##### SOCIETIES ##### -->
    <!-- ##################### -->
    <xsl:template match="gz:Notice/gz:Society">
        <div data-gazettes="Society">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Society/gz:SocietyName">
        <p>
            <span about="{wlf:name(.)}" property="{$has-society-name}" datatype="xsd:string" data-gazettes="SocietyName">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Society/gz:SocietyNumber">
        <p>
            <span about="{wlf:name(../gz:SocietyName)}" property="{$has-society-number}" datatype="xsd:string" data-gazettes="SocietyNumber">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>


    <!-- ################## -->
    <!-- ##### PERSON ##### -->
    <!-- ################## -->
    <xsl:template match="gz:Notice/gz:Person">
        <xsl:variable name="prop">
            <xsl:choose>
                <xsl:when test="substring($noticeType,1,2)='25'">gaz:hasPerson</xsl:when>
                <xsl:when test="$noticeType='2901'">personal-legal:changesNameOf</xsl:when>
                <xsl:when test="$noticeType='2902'">personal-legal:isSearchForNextOfKinOf</xsl:when>
                <xsl:when test="$noticeType='2903'">personal-legal:hasEstateOf</xsl:when>
                <xsl:when test="$noticeType='1122'">honours:isAwardedTo</xsl:when>
                <xsl:otherwise>gaz:hasPerson</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$noticeCode=('1122','1123','1124','1125','1126','1127','1128','1129','1130','1131','1132','1133','1134','1135','1136')">
                <div data-gazettes="Person" property="{if ($noticeCode= ('1126','1127','1130','1131','1132','1133','1134','1135','1136')) then 'honours:hasAwardee'  else 'honours:hasAppointee'}" resource="this:person-1" typeof="gaz:Person">
                    <xsl:choose>
                        <xsl:when test="not(gz:Occupation[. !=''] or gz:Workplace[. !='']  or gz:AddressLineGroup[child::*[. !='']]  or gz:Department[. !='']  or gz:Regiment[. !='']  or gz:CrownDependency[. !=''] or gz:OccupationPosition[. !=''])">
                            <xsl:apply-templates/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each-group select="node()" group-adjacent="name()">
                                <xsl:choose>
                                    <xsl:when test="current-group()[self::gz:Occupation]">
                                        <p data-gazettes="Occupation" property="person:hasEmployment" resource="this:occupation-1" typeof="gaz:Employment">
                                            <xsl:apply-templates select="current-group() | parent::*/gz:Workplace | parent::*/gz:AddressLineGroup | parent::*/gz:Department | parent::*/gz:Regiment | parent::*/gz:CrownDependency"/>
                                        </p>
                                    </xsl:when>
                                    <xsl:when test="current-group()[self::gz:Workplace] and (parent::*/gz:Occupation)"/>
                                    <xsl:when test="current-group()[self::gz:Workplace] and not(parent::*/gz:Occupation)">
                                        <p data-gazettes="Occupation" property="person:hasEmployment" resource="this:occupation-1" typeof="gaz:Employment">
                                            <xsl:apply-templates select="current-group() | parent::*/gz:AddressLineGroup | parent::*/gz:Department |  parent::*/gz:Regiment | parent::*/gz:CrownDependency"/>
                                        </p>
                                    </xsl:when>
                                    <xsl:when test="current-group()[self::gz:Department] and (parent::*/gz:Occupation or parent::*/gz:Workplace)"/>

                                    <xsl:when test="current-group()[self::gz:Department] and not(parent::*/gz:Occupation and parent::*/gz:Workplace)">
                                        <p data-gazettes="Occupation" property="person:hasEmployment" resource="this:occupation-1" typeof="gaz:Employment">
                                            <xsl:apply-templates select="current-group() | parent::*/gz:AddressLineGroup | parent::*/gz:Workplace |  parent::*/gz:Regiment | parent::*/gz:CrownDependency"/>
                                        </p>
                                    </xsl:when>
                                    <xsl:when test="current-group()[self::gz:CrownDependency] and (parent::*/gz:Occupation or parent::*/gz:Workplace or parent::*/gz:Department or parent::*/gz:OccupationPosition)"/>
                                    <xsl:when test="current-group()[self::gz:CrownDependency] and not(parent::*/gz:Occupation and parent::*/gz:Workplace and parent::*/gz:Department and parent::*/gz:OccupationPosition)">
                                        <p data-gazettes="Occupation" property="person:hasEmployment" resource="this:occupation-1" typeof="gaz:Employment">
                                            <xsl:apply-templates select="current-group() | parent::*/gz:AddressLineGroup | parent::*/gz:Regiment"/>
                                        </p>
                                    </xsl:when>
                                    <xsl:when test="current-group()[self::gz:OccupationPosition]">
                                        <p data-gazettes="Occupation" property="person:hasEmployment" resource="this:occupation-1" typeof="gaz:Employment">
                                            <xsl:apply-templates select="current-group() | parent::*/gz:AddressLineGroup | parent::*/gz:Regiment | parent::*/gz:CrownDependency"/>
                                        </p>
                                    </xsl:when>
                                    <xsl:when test="current-group()[self::gz:AddressLineGroup] and (parent::*/gz:Occupation or  parent::*/gz:Workplace or parent::*/gz:Department or parent::*/gz:OccupationPosition or parent::*/gz:CrownDependency)"/>
                                    <xsl:when test="current-group()[self::gz:AddressLineGroup] and not(parent::*/gz:Occupation and  parent::*/gz:Workplace and parent::*/gz:Department and parent::*/gz:CrownDependency )">
                                        <p data-gazettes="Occupation" property="person:hasEmployment" resource="this:occupation-1" typeof="gaz:Employment">
                                            <xsl:apply-templates select="current-group()"/>
                                        </p>
                                    </xsl:when>
                                    <xsl:when test="current-group()[self::gz:Regiment] and (parent::*/gz:Occupation or  parent::*/gz:Workplace or parent::*/gz:Department or parent::*/gz:OccupationPosition or parent::*/gz:CrownDependency)"/>
                                    <xsl:when test="current-group()[self::gz:Regiment] and not(parent::*/gz:Occupation and  parent::*/gz:Workplace and parent::*/gz:Department and parent::*/gz:OccupationPosition and parent::*/gz:CrownDependency)">
                                        <p data-gazettes="Occupation" property="person:hasEmployment" resource="this:occupation-1" typeof="gaz:Employment">
                                            <xsl:apply-templates select="current-group()"/>
                                        </p>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="current-group()"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each-group>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="$noticeCode='1122'">
                        <xsl:apply-templates select="following-sibling::gz:Citation" mode="persondiv"/>
                    </xsl:if>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div property="{$prop}" resource="{if ($noticeCode = '2903') then 'this:deceasedPerson' else wlf:name-sibling(.)}" typeof="person:Person" data-gazettes="Person">
                    <!--  <xsl:if test="$noticeCode='1131'"><xsl:attribute name="about">this:person-1</xsl:attribute></xsl:if>-->
                    <xsl:apply-templates/>
                    <!--<xsl:apply-templates select="following-sibling::gz:Citation" mode="persondiv"/>-->
                </div>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- As above, if the XML randomly misses out gz:Person element -->
    <xsl:template match="gz:Notice/gz:PersonName[not(@Class='Administrator')] | gz:Notice/gz:Text/gz:PersonName[not(@Class='Administrator')]">
        <xsl:variable name="prop">
            <xsl:choose>
                <xsl:when test="substring($noticeType,1,2)='25'">insolvency:BankruptPerson</xsl:when>
                <xsl:when test="$noticeType='2901'">personal-legal:changesNameOf</xsl:when>
                <xsl:when test="$noticeType='2902'">personal-legal:isSearchForNextOfKinOf</xsl:when>
                <xsl:otherwise>person:isAbout</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div property="{$prop}" resource="{wlf:name-sibling(.)}" typeof="person:Person" data-gazettes="Person">
            <h2 data-gazettes="PersonName">
                <xsl:choose>
                    <xsl:when test="$noticeType='2901'">
                        <span property="foaf:name personal-legal:assumesName" content="{wlf:serialize-name(if(*) then * else .)}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <span property="foaf:name" content="{wlf:serialize-name(if(*) then * else .)}"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates/>
            </h2>
        </div>
    </xsl:template>

    <xsl:template match=" gz:Notice/gz:P/gz:Text/gz:PersonName[not(@Class='Administrator')]">
        <xsl:variable name="prop">
            <xsl:choose>
                <xsl:when test="substring($noticeType,1,2)='25'">insolvency:BankruptPerson</xsl:when>
                <xsl:when test="$noticeType='2901'">personal-legal:changesNameOf</xsl:when>
                <xsl:when test="$noticeType='2902'">personal-legal:isSearchForNextOfKinOf</xsl:when>
                <xsl:otherwise>person:isAbout</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <span property="{$prop}" resource="{wlf:name-sibling(.)}" typeof="person:Person" data-gazettes="Person">
            <!-- &#160; -->
            <span data-gazettes="PersonName">
                <xsl:choose>
                    <xsl:when test="$noticeType='2901'">
                        <span property="foaf:name personal-legal:assumesName" content="{wlf:serialize-name(if(*) then * else .)}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <span property="foaf:name" content="{wlf:serialize-name(if(*) then * else .)}"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates/>
            </span>
        </span>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Person/gz:PersonName">
        <xsl:choose>
            <xsl:when test="$noticeCode = (2447, 2414, 2465, 2424, 2409)">
                <p data-gazettes="PersonName">
                    <span property="foaf:name" content="{wlf:serialize-name(if(*) then * else .)}"/>
                    <xsl:apply-templates/>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <h2 data-gazettes="PersonName">
                    <xsl:choose>
                        <xsl:when test="$noticeType='2901'">
                            <span property="foaf:name personal-legal:assumesName" content="{wlf:serialize-name(if(*) then * else .)}"/>
                        </xsl:when>
                        <xsl:when test="$noticeType='1122'">
                            <span property="foaf:name">
                                <xsl:attribute name="content">
                                    <xsl:apply-templates select="gz:Title"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:apply-templates select="gz:Forename"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:apply-templates select="gz:MiddleNames"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:apply-templates select="gz:Surname"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:for-each select="gz:PostNominal">
                                        <xsl:apply-templates/>
                                        <xsl:if test="not(position()=last())">
                                            <xsl:text> </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:attribute>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <span property="foaf:name" content="{wlf:serialize-name(if(*) then * else .)}"/>                            
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates/>
                    <xsl:if test="following-sibling::gz:PersonStatus[text()='Deceased']">
                        <xsl:text> (Deceased)</xsl:text>
                    </xsl:if>
                    <!--<xsl:if test="$noticeCode=('1123','1124','1129','1127')">
        <xsl:apply-templates select="following-sibling::gz:MilitaryServiceNumber" mode="persondiv"/>
      </xsl:if>-->
                </h2>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    <xsl:template match="gz:Notice/gz:Person/gz:PersonName/gz:Title">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span data-gazettes="Title" property="foaf:title">
                    <xsl:apply-templates/>
                </span>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Person/gz:PersonName/gz:PostNominal">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span data-gazettes="PostNominal" property="person:honour">
                    <xsl:apply-templates/>
                </span>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="gz:Notice/gz:Person/gz:PersonAddress">
        <p typeof="vcard:Address" property="person:hasAddress" resource="{wlf:compound-name(..,.)}" data-gazettes="PersonAddress">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Person/gz:PersonAddress/gz:AddressLineGroup">
        <span property="vcard:label" content="{wlf:serialize(.)}" data-gazettes="AddressLineGroup" data-gazettes-class="{@Class}"/>
        <xsl:apply-templates/>
    </xsl:template>

   
    <xsl:template match="gz:Notice/gz:Person/gz:PersonStatus">
        <xsl:if test="$noticeCode = (2520, 2528) and text() = 'Deceased'"/>
        <xsl:if test="not($noticeCode = (2520, 2528) and text() = 'Deceased')">
            <p about="{wlf:name-sibling(..)}" property="person:hasStatus" datatype="xsd:string" data-gazettes="PersonStatus">
                <xsl:if test="text() = 'Discharged'">
                    <xsl:text>NOTE: the above-named was discharged from the proceedings and may no longer have a connection with the addresses listed.</xsl:text>
                </xsl:if>
                <xsl:if test="not(text() = 'Discharged')">
                    <xsl:apply-templates/>
                </xsl:if>
            </p>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="gz:TypeOfProcedure">
        <p about="this:notifiableThing" property="insolvency:typeOfQualifyingDecisionProcedure">
            <xsl:text>Type of Qualifying Decision Procedure: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="gz:TypeOfProcess">
        <p about="this:notifiableThing" property="insolvency:typeOfProcess">
            <xsl:text>Type of Process: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Person/gz:Occupation">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:when test="$noticeCode= ('1122','1123','1124','1125','1126','1127','1128','1129','1130','1131','1132','1133','1134','1135','1136')">
                <span property="person:jobTitle" datatype="xsd:string">
                    <xsl:if test="$noticeCode='1134'">
                        <xsl:attribute name="about">occupation-1</xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </span>
                <xsl:if test="following-sibling::gz:Workplace[. !=''] or following-sibling::gz:Department[. !=''] or following-sibling::gz:AddressLineGroup[child::*[. !='']] or following-sibling::gz:CrownDependency[. !=''] or following-sibling::gz:Regiment[. !='']">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <p about="{wlf:name-sibling(..)}" property="person:hasEmployment" resource="{ if  ($noticeCode='1122') then 'this:occupation-1' else  wlf:compound-name(..,.)}" typeof="gaz:Employment" data-gazettes="Occupation">
                    <span property="person:jobTitle" datatype="xsd:string">
                        <!---<xsl:if test="$noticeCode='1132' or  $noticeCode='1133'">
              <xsl:attribute name="about">this:person-1-Occupation-1</xsl:attribute>
            </xsl:if>-->
                        <xsl:apply-templates/>
                    </span>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--1136-->
    <xsl:template match="gz:OccupationPosition">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="contains(.,',')">
                        <span about="this:occupation-1" datatype="xsd:string" property="person:jobTitle">
                            <xsl:value-of select="substring-before(.,',')"/>
                        </span>
                        <xsl:text>, </xsl:text>
                        <span about="this:occupation-1" property="gazorg:isMemberOfOrganisation" resource="this:organisation-1">
                            <xsl:value-of select="substring-after(.,',')"/>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <span about="this:occupation-1" property="gazorg:isMemberOfOrganisation" resource="this:organisation-1">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="following-sibling::gz:Workplace[. !=''] or following-sibling::gz:Department[. !=''] or following-sibling::gz:AddressLineGroup[child::*[. !='']] or following-sibling::gz:CrownDependency[. !='']">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Citation" mode="persondiv">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <p>
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Citation">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:when test="$noticeCode='1122'"/>
            <xsl:when test="$noticeCode=('1124','1129')">
                <p>
                    <xsl:apply-templates/>
                    <!-- <xsl:apply-templates select="preceding-sibling::*/gz:CrownDependency" mode="persondiv"/>-->
                </p>
            </xsl:when>
            <xsl:otherwise>
                <p>
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--<xsl:template match="gz:Citation/gz:CrownDependency | gz:Person/gz:CrownDependency"/>-->

    <xsl:template match="gz:Regiment">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span data-gazettes="Rank" property="military:withDivision">
                    <xsl:apply-templates/>
                </span>
                <xsl:if test="following-sibling::gz:Workplace[. !=''] or following-sibling::gz:AddressLineGroup[child::*[. !='']] or following-sibling::gz:Department[. !='']">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="gz:MilitaryServiceNumber">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <p>
                    <span data-gazettes="MilitaryNumber" property="military:serviceNumber">
                        <xsl:apply-templates/>
                    </span>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:MilitaryServiceNumber" mode="persondiv">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span data-gazettes="MilitaryNumber" property="person:serviceNumber">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Citation/gz:CrownDependency | gz:Person/gz:CrownDependency">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span about="this:crownDependency" typeof="{concat('honours:CrownDependency',wlf:stripSpecialChars(.))}" property="rdfs:label">
                    <xsl:apply-templates/>
                </span>
                <xsl:if test="following-sibling::gz:Workplace[. !=''] or following-sibling::gz:AddressLineGroup[child::*[. !='']] or following-sibling::gz:Department[. !=''] or following-sibling::gz:Regiment[. !='']">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:CrownDependency">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span about="this:crownDependency" typeof="{concat('honours:CrownDependency',wlf:stripSpecialChars(.))}" property="rdfs:label">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:P/gz:Text/gz:Occasion">
        <span about="this:publicationOccasion" typeof="gaz:HerMajestysBirthdayHonours" property="rdfs:label">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Person/gz:Department" mode="notice_1122">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span about="this:department-1" typeof="gazorg:Department" property="gazorg:departmentName">
                    <xsl:apply-templates/>
                </span>
                <xsl:if test="following-sibling::gz:Workplace[. !=''] or following-sibling::gz:AddressLineGroup[child::*[. !='']] or preceding-sibling::gz:AddressLineGroup[. !='']">
                    <xsl:text>,</xsl:text>
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Person/gz:Department">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span about="this:department-1" typeof="gazorg:Department" property="gazorg:departmentName">
                    <xsl:apply-templates/>
                </span>
                <xsl:if test="following-sibling::gz:Workplace[. !=''] or following-sibling::gz:AddressLineGroup[child::*[. !='']] or following-sibling::gz:CrownDependency[. !=''] or following-sibling::gz:Regiment[. !='']">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Person/gz:PersonName/gz:Rank">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:when test="$noticeCode='1135'">
                <span data-gazettes="Rank" property="military:hasRank">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span data-gazettes="Rank" about="this:rank-1" property="military:rankName" typeof="military:Rank">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Person/gz:Workplace">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span about="this:organisation-1" typeof="gazorg:Organisation" property="gazorg:name">
                    <xsl:apply-templates/>
                </span>
                <xsl:if test="following-sibling::gz:AddressLineGroup[child::*[. !='']] or following-sibling::gz:Department[. !=''] or following-sibling::gz:CrownDependency[. !=''] or following-sibling::gz:Regiment[. !='']">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- notice type -1123-->
    <xsl:template match="gz:AwardDivision">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span property="honours:inDivision" resource="honours:{wlf:tokenizeAndCapitalizeFirstWord(.)}">
                    <span about="honours:{wlf:tokenizeAndCapitalizeFirstWord(.)}" property="rdfs:label">
                        <xsl:apply-templates/>
                    </span>
                </span>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="gz:AwardSubdivision">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span property="honours:inSubDivision" resource="honours:{wlf:tokenizeAndCapitalizeFirstWord(following-sibling::gz:ServiceBranch)}">
                    <span about="honours:{wlf:tokenizeAndCapitalizeFirstWord(following-sibling::gz:ServiceBranch)}" property="rdfs:label">
                        <xsl:apply-templates/>
                        <xsl:text> </xsl:text>
                        <xsl:if test="following-sibling::gz:ServiceBranch !=''">(<xsl:value-of select="following-sibling::gz:ServiceBranch"/>)</xsl:if>
                    </span>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 1131-->
    <xsl:template match="gz:P/gz:AwardDivision">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <p>
                    <span property="honours:inDivision" resource="honours:{wlf:tokenizeAndCapitalizeFirstWord(.)}">
                        <xsl:apply-templates/>
                    </span>
                    <xsl:text> </xsl:text>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:ServiceBranch">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:when test="$noticeCode='1135'">
                <span property="honours:inSubDivision" resource="honours:{wlf:tokenizeAndCapitalizeFirstWord(.)}">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Honour">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <p>
                    <xsl:choose>
                        <xsl:when test="$noticeCode =('1123','1124','1125','1128','1129')">
                            <span about="https://www.thegazette.co.uk/id/honour/{$honourShortName}" typeof="honours:{$honour}" property="rdfs:label">
                                <xsl:apply-templates/>
                            </span>
                        </xsl:when>
                        <xsl:when test="$noticeCode =('1127','1130','1131','1132','1133','1134','1135','1136')">
                            <span about="https://www.thegazette.co.uk/id/honour/{$honourShortName}" typeof="honours:{$medal}" property="rdfs:label">
                                <xsl:apply-templates/>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <span about="https://www.thegazette.co.uk/id/honour/{$honourShortName}" typeof="honours:{$honour}" property="rdfs:label">
                                <xsl:apply-templates/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text> </xsl:text>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--1126-->
    <xsl:template match="gz:Notice/gz:AwardType">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span data-gazettes="AwardType">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="gz:P/gz:AwardName">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span data-gazettes="AwardName">
                    <xsl:apply-templates/>
                </span>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="gz:P/gz:AwardType">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:when test="contains(.,'(')">
                <span data-gazettes="AwardType">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span data-gazettes="AwardType">(<xsl:apply-templates/>)</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--1130-->
    <xsl:template match="gz:Notice/gz:Division">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <div data-gazettes="Division" property="honour:inDivision" resource="honours:{wlf:tokenizeAndCapitalizeFirstWord(.)}">
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="gz:Notice/gz:SubDivision">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <div data-gazettes="Category" property="honour:inSubDivision" resource="honours:{wlf:tokenizeAndCapitalizeFirstWord(.)}">
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Region">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span property="honours:inRegion">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="gz:Notice/gz:Person/gz:PersonDetails">
        <p resource="{wlf:name-sibling(..)}" data-gazettes="PersonDetails">
            <span property="person:hasPersonDetails" datatype="xsd:string" content="{wlf:serialize(.)}"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Person/gz:BirthDetails">
        <xsl:variable name="birth-date" select="gz:Date/@Date"/>
        <p about="{wlf:name-sibling(..)}" property="person:dateOfBirth" datatype="xsd:date" content="{gz:Date/@Date}" data-gazettes="BirthDetails">
            <xsl:if test="not($noticeCode = (2520, 2528))">
                <xsl:text>Birth details: </xsl:text>
            </xsl:if>
            <xsl:apply-templates mode="serialize"/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Person/gz:DeathDetails">
        <!-- First serialize the name and death details. -->
        <xsl:variable name="person-name">
            <xsl:apply-templates select="../gz:PersonName" mode="serialize"/>
        </xsl:variable>
        <xsl:variable name="death-details">
            <xsl:apply-templates select="." mode="serialize"/>
        </xsl:variable>
        <p about="{wlf:name($person-name)}" property="{$has-death-details}" datatype="xsd:string" content="{normalize-space($death-details)}" data-gazettes="DeathDetails">
            <xsl:text>Death details: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Person/gz:AlsoKnownAs">
        <p data-gazettes="AlsoKnownAs">
            <xsl:choose>
                <xsl:when test="$edition = 'Edinburgh' and $noticeCode = 2518">
                    <xsl:text>(also known as </xsl:text>
                    <span resource="{wlf:name-sibling(..)}" property="person:alsoKnownAs" datatype="xsd:string">
                        <xsl:apply-templates/>
                    </span>
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Also known as: </xsl:text>
                    <span resource="{wlf:name-sibling(..)}" property="person:alsoKnownAs" datatype="xsd:string">
                        <xsl:apply-templates/>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </p>
    </xsl:template>

    <!-- ########################## -->
    <!-- ##### ADMINISTRATION ##### -->
    <!-- ########################## -->
    <xsl:template match="gz:Notice/gz:Administration">
        <div data-gazettes="Administration">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Administration/gz:Administrator">
        <p data-gazettes="{if (following-sibling::*[1][self::gz:DateSigned]) then 'authoriser' else 'Administrator'}">
            <xsl:if test="$isCompanyLawNotice">
                <xsl:attribute name="about">
                    <xsl:text>this:notifiableThing</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="rel">
                    <xsl:text>gaz:hasAuthoriser</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="resource">
                    <xsl:text>this:authoriser</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="following-sibling::*[1][self::gz:DateSigned]">
                    <span property="gaz:hasAuthoriser" resource="this:authoriser" typeof="gaz:Authoriser">
                        <xsl:apply-templates/>
                    </span>
                </xsl:when>
                <xsl:when test="$isCompanyLawNotice">
                    <em>
                        <span rel="gaz:hasAuthorisingPerson" resource="this:authorising-person" typeof="gaz:Person">
                            <xsl:apply-templates select="//gz:PersonName"/>
                        </span>
                    </em>
                    <span rel="gaz:hasAuthorisingRole" resource="this:authoriser-1-role" typeof="gaz:Role">
                        <span property="rdfs:label">
                            <xsl:apply-templates select="//gz:Occupation"/>
                        </span>
                    </span>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Prefixed text no longer authored in XML, temporarily added here until permanent solution found. 2015-11-13_WA -->
                    <xsl:if test="$noticeCode= 2443">
                        <xsl:text>Liquidator's name and address: </xsl:text>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Administration/gz:Appointer">
        <p data-gazettes="Appointer">
            <xsl:choose>
                <xsl:when test="$noticeCode = 2421">
                    <xsl:for-each select="following-sibling::gz:Administrator">
                        <xsl:choose>
                            <xsl:when test="count(descendant::gz:PersonName) = 1">
                                <xsl:text>Name of Person Appointing the Administrative Receiver: </xsl:text>
                            </xsl:when>
                            <xsl:when test="count(descendant::gz:PersonName) &gt; 1">
                                <xsl:text>Name of Person Appointing the Joint Administrative Receivers: </xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$noticeCode = (2432, 2443)">
                    <xsl:text>By whom Appointed: </xsl:text>
                </xsl:when>
            </xsl:choose>
            <span property="{$has-appointer}" datatype="xsd:string">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Administration/gz:AdditionalContact">
        <p data-gazettes="AdditionalContact">
            <xsl:variable name="previous-IP" select="wlf:name-sibling(preceding-sibling::*[1])"/>
            <span about="{$previous-IP}">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Administration/gz:AdditionalContact/gz:PersonName">
        <span property="person:hasAdditionalContact" datatype="xsd:string" content="{wlf:serialize-name(if(*) then * else .)}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:Administration/gz:OfficeHolderCapacity">
        <xsl:variable name="previous-administrator" select="wlf:name-sibling(preceding::gz:Administrator)"/>
        <p data-gazettes="OfficeHolderCapacity">
            <xsl:choose>
                <xsl:when test="$noticeCode = '2443'"/>
                <xsl:otherwise>Capacity of office holder(s): </xsl:otherwise>
            </xsl:choose>
            <span about="{$previous-administrator}" property="person:hasRole" resource="{concat($previous-administrator,'-role')}">
                <span resource="{concat($previous-administrator,'-role')}" typeof="person:Role" property="person:roleName" datatype="xsd:string">
                    <xsl:apply-templates/>
                </span>
            </span>
        </p>
    </xsl:template>

    <!-- RDFa for these two are now handled within rule for gz:Administration//gz:PersonName -->

    <xsl:template match="gz:OfficeHolderNumbers">
        <p>
            <xsl:choose>
                <xsl:when test="$noticeCode = (2432, 2443)">
                    <xsl:choose>
                        <xsl:when test="count(gz:OfficeHolderNumber) &gt; 1">
                            <xsl:text>Office Holder Numbers: </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>Office Holder Number: </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
            <span data-gazettes="OfficeHolderNumbers">
                <xsl:for-each select="gz:OfficeHolderNumber">
                    <xsl:if test="position() != 1 and position() != last()">, </xsl:if>
                    <xsl:if test="position() != 1 and position() = last()"> and </xsl:if>
                    <xsl:apply-templates/>
                </xsl:for-each>
                <xsl:choose>
                    <xsl:when test="$noticeCode = (2432, 2443)">
                        <xsl:text>.</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </span>
        </p>
    </xsl:template>


    <xsl:template match="gz:OfficeHolderNumber">
        <span data-gazettes="OfficeHolderNumber">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:DateOfAppointment">
        <p>
            <xsl:choose>
                <xsl:when test="$noticeCode = (2410, 2432, 2443)">
                    <xsl:text>Date of Appointment: </xsl:text>
                </xsl:when>
                <xsl:when test="$noticeCode = 2421">
                    <xsl:for-each select="following-sibling::gz:Administrator">
                        <xsl:choose>
                            <xsl:when test="count(descendant::gz:PersonName) = 1">
                                <xsl:text>Date of Appointment of Administrative Receiver: </xsl:text>
                            </xsl:when>
                            <xsl:when test="count(descendant::gz:PersonName) &gt; 1">
                                <xsl:text>Date of Appointment of Joint Administrative Receivers: </xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
            <span property="{$has-date-of-appointment}" datatype="xsd:date" content="{@Date}" data-gazettes="DateOfAppointment" data-date="{@Date}">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>

    <xsl:template match="gz:DateSigned">
        <p data-gazettes="DateSigned">
            <span property="{$signed-on-date}" datatype="xsd:date" content="{@Date}" data-gazettes="DateSigned" data-date="{@Date}">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>


    <xsl:template match="gz:Text/gz:AddressLineGroup[@Class='Administrator'] | gz:Administration/gz:Administrator/gz:AddressLineGroup">
        <xsl:choose>
            <xsl:when test="$noticeCode = 2903">
                <span about="this:addressOfExecutor" typeof="vcard:Address">
                    <span property="vcard:label" content="{wlf:serialize(.)}"/>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="$isCompanyLawNotice">
                <span resource="{wlf:compound-name(..,.)}" typeof="vcard:Address" rel="vcard:adr">
                    <span property="vcard:label" content="{wlf:serialize(.)}"/>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="$noticeCode = (2447, 2414, 2520, 2465, 2424, 2409, 2528)">
                <span about="this:notifiableThing" typeof="vcard:Address" property="insolvency:addressForLodgingProofs" resource="this:address-for-lodging-proofs">
                    <span property="vcard:label" content="{wlf:serialize(.)}"/>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span about="{wlf:compound-name(..,.)}" typeof="vcard:Address">
                    <span property="vcard:label" content="{wlf:serialize(.)}"/>
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Administration/gz:Administrator/gz:PersonName | gz:Text//gz:PersonName[@Class='Administrator']">
        <span property="{if (../following-sibling::*[1][self::gz:DateSigned]) then $has-authorising-person 
        else if(@Class = 'Receiver') then $has-official-receiver
        else if(@Class = 'Administrator' and $noticeCode = ('2446','2431','2432','2460','2454','2435','2406','2408','2403','2443','2455','2433')) then $has-liquidator
        else if(@Class = 'Administrator' and $noticeCode = '2447') then $has-convenor
        else if(@Class = 'Administrator' and $noticeCode = ('2413','2410','2411','2412','2445','2442')) then $has-administrator
        else if(@Class = 'Administrator' and $noticeCode = ('2423','2422')) then $has-receiver
        else if(@Class = 'Administrator' and $noticeCode = ('2903') and parent::*[name() = 'Administrator']) then $has-personal-representative       
        else if(@Class = 'Administrator' and $noticeCode = ('2903')) then $has-estate-of
        else if(@Class = 'Administrator' and $noticeCode = ('2503','2504','2509','2510')) then $has-official-receiver
        else if(@Class = 'Administrator' and $noticeCode = '2441') then $has-resolutionLiquidator else @Class}" resource="{ if ($noticeCode=('2903') and parent::*[name() != 'Administrator']) then 'this:deceasedPerson' else if ($noticeCode=('2903') and parent::*[name() = 'Administrator']) then 'this:estateExecutor' else if (../following-sibling::*[1][self::gz:DateSigned])  then 'this:signatory-1' else wlf:compound-name(..,.)}" typeof="{ if (../following-sibling::*[1][self::gz:DateSigned]) then 'person:Person' else 'foaf:Agent'}" data-gazettes="{@Class}">
            <xsl:if test="not(preceding-sibling::gz:PersonName or $noticeCode = 2903) ">
                <span about="this:notifiableThing" property="insolvency:hasPrimaryIP" resource="this:IP1"/>
            </xsl:if>
            <xsl:if test="../gz:OfficeHolderNumber[1]">
                <xsl:variable name="previous-siblings" select="(count(preceding-sibling::gz:PersonName) + 1)" as="xs:integer"/>
                <span property="person:hasIPnum" datatype="xsd:string" content="{../gz:OfficeHolderNumber[$previous-siblings]/text()}"/>
            </xsl:if>
            <xsl:if test="../gz:OfficeHolderCapacity[1]">
                <span property="person:hasIPCapacity" datatype="xsd:string" content="{../gz:OfficeHolderCapacity/text()}"/>
            </xsl:if>
            <xsl:if test="../gz:AddressLineGroup[1]">
                <span property="vcard:adr" resource="{wlf:compound-name(..,following-sibling::gz:AddressLineGroup[1])}"/>
            </xsl:if>
            <xsl:if test="../gz:FirmName[1]">
                <span property="gazorg:hasOrganisationMember" resource="{wlf:compound-name(..,following-sibling::gz:FirmName[1])}"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$noticeCode = '2903' and parent::*[name() != 'Administrator']">
                    <span property="foaf:name" content="{wlf:serialize-name(*)}"/>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:when test="$noticeCode = '2447'">
                    <span about="this:notifiableThing" property="insolvency:hasConvener" resource="this:convenor-1" content="{wlf:serialize-name(*)}"/>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <em>
                        <span property="foaf:name" content="{wlf:serialize-name(*)}"/>
                        <xsl:apply-templates/>
                    </em>
                </xsl:otherwise>
            </xsl:choose>

        </span>
    </xsl:template>
    
    <xsl:template match="gz:OrganisationName">
        <!-- 
            OrganisationName is present in the Schema, but previous to below corp insolvency update, was unsupported in this transform.
            At some point, all non-corp insolvency OrganisationName should be modelled. E.g. 1504 unit test contains an OrgName.
        -->
        <xsl:if test="$noticeCode = (2447, 2414, 2520, 2465, 2424, 2409, 2528)">
            <span about="org:memberOf" property="this:convener-1-organisation" typeof="gazorg:Organisation org:Organization">
                <xsl:apply-templates/>
            </span>
        </xsl:if>
        <xsl:if test="not($noticeCode = (2447, 2414, 2520, 2465, 2424, 2409, 2528))">
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gz:Administration//gz:Email">
        <span property="gaz:email" data-gazettes="Email" data-gazettes-class="{@Class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- ##### AUTHORITY ##### -->
    <xsl:template match="gz:Notice/gz:Authority">
        <xsl:choose>
            <xsl:when test=". =''"/>
            <xsl:when test="$noticeCode = '1105'">
                <xsl:if test="count(preceding-sibling::gz:Authority) &lt; 1">
                    <h2 property="gaz:hasAuthority" resource="{wlf:name-sibling(.)}" typeof="gaz:Authority">
                        <span property="rdfs:label">
                            <!--concat all the titles in one-->
                            <xsl:call-template name="join">
                                <xsl:with-param name="valueList" select="..//gz:Authority"/>
                                <xsl:with-param name="separator" select="' '"/>
                            </xsl:call-template>
                        </span>
                    </h2>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$noticeCode =('1122','1123','1124','1125','1126','1127','1128','1129','1130','1131','1132','1133','1134','1135','1136')">
                <h2 property="gaz:hasAuthority" resource="https://www.thegazette.co.uk/id/organisation/{translate(lower-case(.),' ','-')}" typeof="gaz:Authority">
                    <span property="rdfs:label">
                        <xsl:apply-templates/>
                    </span>
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h2 property="gaz:hasAuthority" resource="{wlf:name-sibling(.)}" typeof="gaz:Authority">
                    <span property="rdfs:label">
                        <xsl:apply-templates/>
                    </span>
                </h2>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ################ -->
    <!-- ##### TEXT ##### -->
    <!-- ################ -->

    <xsl:template match="gz:Text/gz:AddressLineGroup[@Class='Company']">
        <span about="this:company-1" property="vcard:adr" resource="this:company-1-address-0" data-gazettes="AddressLineGroup" data-gazettes-class="{@Class}">
            <span about="this:company-1-address-0" typeof="vcard:Address" property="vcard:label" content="{wlf:serialize(.)}">
                <xsl:apply-templates/>
            </span>
        </span>
    </xsl:template>

    <xsl:template match="gz:Text/gz:AddressLineGroup[@Class='Meeting']">
        <span about="this:notifiableThing" property="insolvency:meetingLocation" resource="this:meetingAddress-0" data-gazettes="AddressLineGroup" data-gazettes-class="{@Class}">
            <span about="this:meetingAddress-0" typeof="vcard:Address" property="vcard:label" content="{wlf:serialize(.)}">
                <xsl:apply-templates/>
            </span>
        </span>
    </xsl:template>


    <xsl:template match="gz:Text/gz:AddressLineGroup[@Class='Petitioner']">
        <span about="this:petitioner-1" property="vcard:adr" resource="this:petitioner-1-address-0" data-gazettes="AddressLineGroup" data-gazettes-class="{@Class}">
            <span about="this:petitioner-1-address-0" typeof="vcard:Address" property="vcard:label" content="{wlf:serialize(.)}">
                <xsl:apply-templates/>
            </span>
        </span>
    </xsl:template>

    <xsl:template match="gz:Text/gz:AddressLineGroup[@Class='Court']">
        <xsl:choose>
            <xsl:when test="$noticeCode = ('2450','2451','2461')">
                <span about="this:notifiableThing" property="insolvency:placeOfHearing" resource="this:hearingAddress" data-gazettes="AddressLineGroup" data-gazettes-class="{@Class}">
                    <span about="this:hearingAddress" typeof="vcard:Address" property="vcard:label" content="{wlf:serialize(.)}">
                        <xsl:apply-templates/>
                    </span>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span about="this:court" property="vcard:adr" resource="this:court-address-0" data-gazettes="AddressLineGroup" data-gazettes-class="{@Class}">
                    <span about="this:court-address-0" typeof="vcard:Address" property="vcard:label" content="{wlf:serialize(.)}">
                        <xsl:apply-templates/>
                    </span>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template match="gz:Text/gz:AddressLineGroup[@Class='Person']">
        <span property="gaz:hasPerson" resource="person-1" typeof="person:Person" data-gazettes="AddressLineGroup" data-gazettes-class="{@Class}">
            <span property="vcard:adr" resource="{wlf:compound-name(..,.)}" typeof="vcard:Address">
                <span property="vcard:label" content="{wlf:serialize(.)}"/>
                <xsl:apply-templates/>
            </span>
        </span>
    </xsl:template>

    <xsl:template match="gz:Text/gz:AddressLineGroup[@Class='Partnership']">
        <span resource="this:partnership-1">
            <span property="vcard:adr" resource="{wlf:compound-name(..,.)}" typeof="vcard:Address" data-gazettes="AddressLineGroup" data-gazettes-class="{@Class}">
                <span property="vcard:label" content="{wlf:serialize(.)}"/>
                <xsl:apply-templates/>
            </span>
        </span>
    </xsl:template>

    <xsl:template match="gz:Text/gz:AddressLineGroup[(@Class!='Company' and @Class!='Petitioner' and @Class!='Court' and @Class!='Administrator' and @Class!='Meeting' and @Class!='Person' and @Class!='Partnership') or not(@Class)]">
        <span about="{wlf:clean(wlf:serialize(.))}" property="gzw:has{name()}" content="{wlf:serialize(.)}" data-gazettes="AddressLineGroup" data-gazettes-class="{@Class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Text/gz:CompanyName[@Class='Petitioner']">
        <span property="insolvency:hasPetitioner" resource="this:petitioner-1" typeof="gazorg:Organisation" data-gazettes="CompanyName" data-gazettes-class="{@Class}">
            <span property="gazorg:name" datatype="xsd:string">
                <xsl:choose>
                    <xsl:when test="$edition = 'Edinburgh'">
                        <xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="upper-case(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
            <span property="foaf:name" datatype="xsd:string" content="{upper-case(wlf:serialize-name(.))}"> </span>
        </span>
    </xsl:template>

    <!-- ###################################### -->
    <!-- ##### GENERIC ELEMENT PROCESSING ##### -->
    <!-- ###################################### -->
    <xsl:template match="gz:AddressLineGroup">
        <xsl:choose>
            <xsl:when test="not(count(child::*[.!=''])) and not(text())"/>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$noticeCode ='1122' or $noticeCode ='1129' or $noticeCode ='1130' or $noticeCode ='1132' or $noticeCode ='1133' or $noticeCode ='1134' or $noticeCode ='1136'">
                        <span data-gazettes="AddressLineGroup" data-gazettes-class="Awardee" about="this:organisation-1" property="vcard:adr" resource="this:organisationAddress">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <span resource="{wlf:clean(wlf:serialize(.))}" property="gzw:has{name()}" content="{wlf:serialize(.)}" data-gazettes="AddressLineGroup" data-gazettes-class="{@Class}">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="following-sibling::gz:CrownDependency[. !='']">
                    <xsl:text>,</xsl:text>
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="gz:AddressLine[1]">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:when test="$noticeCode= ('1122','1130','1136')">
                <span about="this:organisationAddress" data-gazettes="AddressLine" typeof="vcard:Address">
                    <span property="vcard:locality">
                        <xsl:apply-templates/>
                    </span>
                    <xsl:if test="following-sibling::gz:country[. !=''] or following-sibling::gz:Country[. !='']">
                        <xsl:text>,</xsl:text>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:apply-templates select="following-sibling::gz:country | following-sibling::gz:Country" mode="addressline"/>
                </span>
            </xsl:when>
            <xsl:when test="$noticeCode='1129' or $noticeCode='1132' or $noticeCode='1133' or $noticeCode='1134'">
                <span about="this:organisationAddress" data-gazettes="AddressLine" typeof="vcard:Address">
                    <xsl:choose>
                        <xsl:when test="$noticeCode=('1129','1132','1133')">
                            <span property="vcard:locality">
                                <xsl:apply-templates/>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <span property="vcard:extended-address">
                                <xsl:apply-templates/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:when>
            <xsl:when test="parent::gz:AddressLineGroup[@Class='Petitioner']">
                <span property="vcard:street-address" about="this:petitioner-1-PetitionerAddress-1" data-gazettes="AddressLine">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span property="vcard:street-address" data-gazettes="AddressLine">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:when test="$noticeCode =('1122','1123','1124','1125','1126','1127','1128','1129','1130','1131','1132','1133','1134','1135','1136')">
                <xsl:if test="following-sibling::*[(not(name(.)='country' or name(.)='Country' )) and . !='']">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:if test="following-sibling::*">
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--1130-->
    <xsl:template match="gz:AddressLineGroup/gz:country | gz:AddressLineGroup/gz:Country">
        <xsl:choose>
            <xsl:when test="parent::*/gz:AddressLine[1 and . !='']"/>
            <xsl:otherwise>
                <xsl:apply-templates mode="addressline"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="gz:AddressLineGroup/gz:country | gz:AddressLineGroup/gz:Country" mode="addressline">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span property="vcard:country-name">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:AddressLine[position() &gt; 1]">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:when test="$isCompanyLawNotice">
                <span data-gazettes="AddressLine">
                    <xsl:attribute name="property">
                        <xsl:text>vcard:</xsl:text>
                        <xsl:value-of select="@Class"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="parent::gz:AddressLineGroup[@Class='Petitioner']">
                <span property="vcard:extended-address" about="this:petitioner-1-PetitionerAddress-1" data-gazettes="AddressLine">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span property="vcard:extended-address" data-gazettes="AddressLine">
                    <xsl:apply-templates/>
                </span>
                <xsl:choose>
                    <xsl:when test="$noticeCode =('1122','1123','1124','1125','1126','1127','1128','1129','1130','1131','1132','1133','1134','1135','1136')">
                        <xsl:if test=" following-sibling::*[. !='']">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                        <xsl:text> </xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:AlsoKnownAs">
        <span resource="{wlf:name-sibling(..)}" property="person:alsoKnownAs" data-gazettes="AlsoKnownAs" datatype="xsd:string">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Authority">
        <xsl:if test="not($isCompanyLawNotice)">
            <h2 property="gaz:hasAuthority" resource="{wlf:name-sibling(.)}" typeof="gaz:Authority">
                <span property="rdfs:label">
                    <xsl:apply-templates/>
                </span>
            </h2>
        </xsl:if>
        <xsl:if test="$isCompanyLawNotice">
            <h2 property="gaz:hasAuthorisingOrganisation" resource="this:authorising-organisation" typeof="gazorg:GovernmentDepartment">
                <span property="rdfs:label">
                    <xsl:apply-templates/>
                </span>
            </h2>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gz:AwardSubCategrory | gz:AwardSubCategory">
        <xsl:choose>
            <xsl:when test=". = ''"/>
            <xsl:otherwise>
                <span property="honours:inSubDivision" resource="honours:{wlf:tokenizeAndCapitalizeFirstWord(.)}">
                    <span about="honours:{wlf:tokenizeAndCapitalizeFirstWord(.)}" property="rdfs:label">
                        <xsl:apply-templates/>
                    </span>
                </span>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Character">
        <span data-gazettes="Character">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:CompanyRegisteredCountry">
        <span data-gazettes="CompanyRegisteredCountry">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Date[@Class='Hearing']">
        <span property="insolvency:dateOfHearing" datatype="xsd:dateTime" content="{concat(@Date,'T00:00:00')}" data-gazettes="Date" data-gazettes-class="{@Class}" data-date="{@Date}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Date[@Class='Presentation']">
        <span property="insolvency:dateOfPetitionPresentation" datatype="xsd:date" content="{@Date}" data-gazettes="Date" data-gazettes-class="{@Class}" data-date="{@Date}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Date[@Class='Resolution']">
        <span property="insolvency:dateOfResolution" datatype="xsd:date" content="{@Date}" data-gazettes="Date" data-gazettes-class="{@Class}" data-date="{@Date}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Date[@Class='Appointment']">
        <span property="{$has-date-of-appointment}" datatype="xsd:date" content="{@Date}" data-gazettes="Date" data-gazettes-class="{@Class}" data-date="{@Date}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Date[@Class='Issued']">
        <xsl:if test="not($isCompanyLawNotice)">
            <p>
                <xsl:text>Date Issued: </xsl:text>
                <strong property="{$has-date-of-appointment}" datatype="xsd:date" content="{@Date}" data-gazettes="Date" data-gazettes-class="{@Class}" data-date="{@Date}">
                    <xsl:apply-templates/>
                </strong>
            </p>
        </xsl:if>
        <xsl:if test="$isCompanyLawNotice">
            <p>
                <xsl:text>Date: </xsl:text>
                <strong property="{$has-date-of-document-receipt}" datatype="xsd:date" content="{@Date}" data-gazettes="Date" data-gazettes-class="{@Class}" data-date="{@Date}">
                    <xsl:apply-templates/>
                </strong>
            </p>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="gz:PreviousPersonAddress">
        <p>
            <xsl:text>Formerly of: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="gz:PersonStatus/gz:Date">
        <p>
            <xsl:text>Date of bankruptcy order: </xsl:text>
            <span property="gaz:relatedDate" content="{@Date}" datatype="xsd:date" data-gazettes="Date" data-gazettes-class="{@Class}" data-date="{@Date}">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>
    
    <xsl:template match="gz:Date">
        <span property="gaz:relatedDate" content="{@Date}" datatype="xsd:date" data-gazettes="Date" data-gazettes-class="{@Class}" data-date="{@Date}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="gz:Date[@Class='insolvency:dateOfDecision']">
        <span property="insolvency:dateOfDecision" about="this:notifiableThing" datatype="xsd:dateTime" data-gazettes-class="{@Class}" data-date="{@Date}" content="{concat(@Date,'T23:59')}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="gz:Date[@Class='insolvency:onOrBeforeProvingDebtsDateOnly']">
        <span property="insolvency:onOrBeforeProvingDebtsDateOnly" about="this:notifiableThing" content="{@Date}" datatype="xsd:date" data-gazettes="Date" data-gazettes-class="{@Class}" data-date="{@Date}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:DateOfAnnulment">
        <xsl:text>Date of annulment: </xsl:text>
        <span resource="{wlf:clean(wlf:serialize(../*[1]))}" property="gzw:has{name()}" content="{wlf:serialize(.)}" data-gazettes="DateOfAnnulment" data-date="{@Date}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:DateOfDischarge">
        <xsl:text>Date of discharge: </xsl:text>
        <span resource="{wlf:clean(wlf:serialize(../*[1]))}" property="gzw:has{name()}" content="{wlf:serialize(.)}" data-gazettes="DateOfDischarge" data-date="{@Date}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:DateOfCertificateOfDischarge">
        <xsl:text>Date of certificate of discharge: </xsl:text>
        <span resource="{wlf:clean(wlf:serialize(../*[1]))}" property="gzw:has{name()}" content="{wlf:serialize(.)}" data-gazettes="DateOfCertificateOfDischarge" data-date="{@Date}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Email">
        <xsl:choose>
            <xsl:when test="$noticeCode = (2447, 2414, 2520, 2465, 2424, 2409, 2528)">
                <span property="gaz:email" data-gazettes="Email" data-gazettes-class="{@Class}">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span property="gaz:email" data-gazettes="Email" data-gazettes-class="{@Class}">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>

    <xsl:template match="gz:FirmName">
        <xsl:choose>
            <xsl:when test="ancestor::gz:Administration[1][gz:DateSigned] and $noticeCode != '2903'">
                <span property="gazorg:hasOrganisationMember" resource="{concat('this:authoriser-',wlf:name-sibling-no-namespace(.))}" typeof="gazorg:ForProfitOrganisation" data-gazettes="FirmName">
                    <span property="gazorg:name">
                        <xsl:apply-templates/>
                    </span>
                </span>
            </xsl:when>
            <xsl:when test="ancestor::gz:Text and count(preceding-sibling::gz:PersonName[@Class='Administrator']) &lt; 1 and count(following-sibling::gz:PersonName[@Class='Administrator']) &lt; 1">
                <span property="{if(@Class = 'Receiver') then $has-official-receiver
				else if(@Class = 'Administrator' and $noticeCode = ('2446','2431','2432','2460','2454','2435','2406','2408','2403','2443','2455','2433')) then $has-liquidator
				else if(@Class = 'Administrator' and $noticeCode = ('2413','2410','2411','2412','2445','2442')) then $has-administrator
				else if(@Class = 'Administrator' and $noticeCode = ('2423','2422')) then $has-receiver
				else if(@Class = 'Administrator' and $noticeCode = ('2503','2504','2509','2510')) then $has-official-receiver
				else if(@Class = 'Administrator' and $noticeCode = '2441') then $has-resolutionLiquidator else @Class}" resource="{concat('this:IP-',wlf:name-sibling-no-namespace(.))}" typeof="{'foaf:Agent'}" data-gazettes="{@Class}">
                    <xsl:if test="../gz:OfficeHolderNumber[1]">
                        <xsl:variable name="previous-siblings" select="(count(preceding-sibling::gz:PersonName) + 1)" as="xs:integer"/>
                        <span property="person:hasIPnum" datatype="xsd:string" content="{../gz:OfficeHolderNumber[$previous-siblings]/text()}"/>
                    </xsl:if>
                    <xsl:if test="../gz:OfficeHolderCapacity[1]">
                        <span property="person:hasIPCapacity" datatype="xsd:string" content="{../gz:OfficeHolderCapacity/text()}"/>
                    </xsl:if>
                    <xsl:if test="../gz:AddressLineGroup[1]">
                        <span property="vcard:adr" resource="{wlf:compound-name(..,following-sibling::gz:AddressLineGroup[1])}"/>
                    </xsl:if>
                    <span property="foaf:name" content="{../gz:FirmName/text()}"> </span>
                    <span property="gazorg:hasOrganisationMember" resource="{wlf:compound-name(..,.)}" typeof="gazorg:ForProfitOrganisation" data-gazettes="FirmName">
                        <span property="gazorg:name">
                            <xsl:apply-templates/>
                        </span>
                    </span>
                </span>
            </xsl:when>
            <xsl:when test="$noticeCode='2903'">
                <span typeof="foaf:Agent" about="this:estateExecutor" data-gazettes="FirmName">
                    <em property="gazorg:name">
                        <xsl:apply-templates/>
                    </em>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <!--<span about="{concat('this:text-',wlf:name-sibling-no-namespace(.))}"
          typeof="gazorg:ForProfitOrganisation" data-gazettes="FirmName">-->

                <span about="{wlf:compound-name(..,.)}" typeof="gazorg:ForProfitOrganisation" data-gazettes="FirmName">
                    <span property="gazorg:name">
                        <xsl:apply-templates/>
                    </span>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Forename">
        <span property="foaf:firstName" data-gazettes="Forename">
            <xsl:apply-templates/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="gz:GroundsOfAnnulment">
        <xsl:text>Grounds of annulment: </xsl:text>
        <span resource="{wlf:clean(wlf:serialize(../*[1]))}" property="gzw:has{name()}" content="{wlf:serialize(.)}" data-gazettes="GroundsOfAnnulment">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Initials">
        <span property="person:initials" data-gazettes="Initials">
            <xsl:apply-templates/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="gz:IVAdate">
        <span data-gazettes="IVAdate" data-date="{@Date}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Legislation">
        <span resource="this:notifiableThing"/>
        <span property="{$is-enabled-by-legislation}" resource="{wlf:clean(wlf:serialize(.))}" typeof="leg:Legislation" data-gazettes="Legislation">
            <span property="rdfs:label" datatype="xsd:string">
                <xsl:apply-templates/>
            </span>
        </span>
    </xsl:template>

    <xsl:template match="gz:Partnership/gz:Legislation">
        <span resource="this:notifiableThing"/>
        <span property="{$is-enabled-by-legislation}" resource="{wlf:clean(wlf:serialize(.))}" typeof="leg:Legislation" data-gazettes="Legislation">
            <span property="rdfs:label" datatype="xsd:string">
                <xsl:text>and in the Matter of the </xsl:text>
                <xsl:apply-templates/>
            </span>
        </span>
    </xsl:template>

    <xsl:template match="gz:LegislationSection">
        <xsl:if test="not($isCompanyLawNotice)">
            <!-- <xsl:text>Legislation section: </xsl:text>-->
            <xsl:variable name="legislation">
                <xsl:choose>
                    <xsl:when test="following-sibling::gz:Legislation">
                        <xsl:value-of select="following-sibling::gz:Legislation[1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="wlf:serialize(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <span resource="{wlf:clean($legislation)}" data-gazettes="LegislationSection">
                <span property="leg:legislationSection" resource="{wlf:clean(concat($legislation,'-',wlf:serialize(.)))}" typeof="leg:LegislationSection">
                    <span property="rdfs:label">
                        <xsl:apply-templates/>
                        <xsl:text> </xsl:text>
                    </span>
                </span>
            </span>
        </xsl:if>
        <xsl:if test="$isCompanyLawNotice">
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gz:LegislationType">
        <!--   <xsl:text>Legislation type: </xsl:text>-->
        <span data-gazettes="LegislationType">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:LegislationSubType">
        <!--<xsl:text>Legislation subtype: </xsl:text>-->
        <span data-gazettes="LegislationSubType">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:MiddleNames">
        <span property="foaf:givenName" data-gazettes="MiddleNames">
            <xsl:apply-templates/>
        </span>
        <!-- &#160; -->
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="gz:Note">
        <span data-gazettes="Note">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:NoticeOfClaims">
        <xsl:text>Notice of claims: </xsl:text>
        <span resource="{wlf:clean(wlf:serialize(.))}" property="gzw:has{name()}" content="{wlf:serialize(.)}" data-gazettes="NoticeOfClaims">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:NoticeOfClaimsDate">
        <xsl:text>Notice of claims date: </xsl:text>
        <span data-gazettes="NoticeOfClaimsDate" data-date="{@Date}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:NoticeHeading">
        <span property="gaz:has{name()}" content="{wlf:serialize(.)}" data-gazettes="NoticeHeading">
            <strong>
                <xsl:apply-templates/>
            </strong>
        </span>
    </xsl:template>
    
    <xsl:template match="gz:Attendee">
        <span about="this:notifiableThing" property="insolvency:typeOfAttendees">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:OfficeHolderCapacity">
        <xsl:variable name="previous-administrator" select="wlf:compound-name(..,preceding-sibling::gz:PersonName[last()])"/>
        <xsl:choose>
            <xsl:when test="ancestor::gz:Administration[1][gz:DateSigned]">
                <span property="gaz hasAuthorisingRole" resource="this:role-signatory" typeof="person:Role">
                    <span property="person:roleName" datatype="xsd:string">
                        <xsl:apply-templates/>
                    </span>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span about="{$previous-administrator}" property="person:hasRole" typeof="person:Role" resource="{concat($previous-administrator,'-role')}" data-gazettes="OfficeHolderCapacity">
                    <span property="person:roleName" datatype="xsd:string">
                        <xsl:apply-templates/>
                    </span>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Petitioner">
        <p about="this:notifiableThing" property="insolvency:hasPetitioner" resource="{wlf:name-sibling(.)}" typeof="foaf:Agent" data-gazettes="Petitioner">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:PetitionerAddress">
        <span about="this:petitioner-1" property="vcard:adr" resource="{wlf:compound-name(..,.)}" typeof="vcard:Address" data-gazettes="PetitionerAddress">
            <span about="{wlf:compound-name(..,.)}">
                <span property="vcard:label" content="{wlf:serialize(.)}"/>
                <xsl:apply-templates/>
            </span>
        </span>
    </xsl:template>

    <xsl:template match="gz:PetitionerAddress//gz:AddressLineGroup">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="gz:PetitionerName">
        <xsl:choose>
            <xsl:when test="following-sibling::gz:PetitionerAddress">Name and address of petitioner: </xsl:when>
            <xsl:otherwise>Name of petitioner: </xsl:otherwise>
        </xsl:choose>
        <span property="foaf:name" data-gazettes="PetitionerName" content="{wlf:serialize-name(.)}" about="this:petitioner-1">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Pblock |gz:PsubBlock">
        <xsl:variable name="here" select="."/>
        <xsl:variable name="p1s" as="xs:integer*" select="wlf:findP1s(*)"/>
        <div data-gazettes="{name()}">
            <xsl:for-each select="*">
                <xsl:choose>
                    <xsl:when test="name(.) = 'P1'">
                        <xsl:if test="position()=$p1s">
                            <ul>
                                <xsl:apply-templates select="$here/gz:P1"/>
                            </ul>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="name(.) = 'P2'">
                        <xsl:if test="position()=$p1s">
                            <ul>
                                <xsl:apply-templates select="$here/gz:P2"/>
                            </ul>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="name(.) = 'P3'">
                        <xsl:if test="position()=$p1s">
                            <ul>
                                <xsl:apply-templates select="$here/gz:P3"/>
                            </ul>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template match="gz:Pblock/gz:Title">
        <h4 data-gazettes="Title">
            <xsl:apply-templates/>
        </h4>
    </xsl:template>

    <xsl:template match="gz:PsubBlock/gz:Title">
        <h5 data-gazettes="Title">
            <xsl:apply-templates/>
        </h5>
    </xsl:template>

    <xsl:template match="gz:PsubBlock/gz:P/gz:Text">
        <p data-gazettes="Text">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Pblock/gz:P">
        <p data-gazettes="P">
            <xsl:next-match/>
        </p>
    </xsl:template>

    <xsl:template match="gz:Pnumber">
        <span data-gazettes="{name()}">
            <xsl:apply-templates/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="gz:Postcode">
        <span property="vcard:postal-code" data-gazettes="Postcode">
            <xsl:if test="parent::gz:AddressLineGroup[@Class='Petitioner']">
                <xsl:attribute name="about">
                    <xsl:text>this:petitioner-1-PetitionerAddress-1</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Ref">
        <span data-gazettes="Ref">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:RelatedCase">
        <xsl:text>Related case: </xsl:text>
        <span resource="{wlf:clean(wlf:serialize(../*[1]))}" property="gzw:has{name()}" content="{wlf:serialize(.)}" data-gazettes="RelatedCase">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Retraction">
        <p class="retraction" data-gazettes="Retraction">
            <span resource="{wlf:clean(wlf:serialize(../*[1]))}" property="gzw:has{name()}" content="{wlf:serialize(.)}" data-gazettes="Retraction">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>

    <xsl:template match="gz:Salutation">
        <span resource="{wlf:clean(wlf:serialize(..))}" property="gzw:has{name()}" content="{wlf:serialize(.)}" data-gazettes="Salutation">
            <xsl:apply-templates/>
        </span>
        <!-- &#160; -->
    </xsl:template>

    <xsl:template match="gz:Substitution">
        <p class="substitution" data-gazettes="Substitution">
            <span resource="{wlf:clean(wlf:serialize(../*[1]))}" property="gzw:has{name()}" content="{wlf:serialize(.)}" data-gazettes="Substitution">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>

    <xsl:template match="gz:Surname">
        <span property="foaf:familyName" data-gazettes="Surname">
            <xsl:apply-templates/>
        </span>
        <xsl:if test="not($noticeCode = (2447, 2414, 2465, 2424, 2409))">
            <xsl:text> </xsl:text>
            <!-- &#160; -->
        </xsl:if>        
    </xsl:template>

    <xsl:template match="gz:Telephone">
        <span property="loc:phoneNumber" content="{wlf:serialize(.)}" data-gazettes="Telephone" data-gazettes-class="{@Class}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Text">
        <span data-gazettes="Text">
            <xsl:if test="@SpaceBefore">
                <xsl:attribute name="data-gazettes-space-before" select="@SpaceBefore"/>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Time">
        <xsl:choose>
            <xsl:when test="@Class='Meeting'">
                <xsl:if test="root()//gz:Date[@Class = 'Meeting']">
                    <span about="this:notifiableThing" property="{concat('insolvency:meetingTime',if(count(preceding-sibling::gz:Time) = 0) then '' else count(preceding-sibling::gz:Time) + 1)}" datatype="xsd:dateTime" content="{if (count(parent::*/gz:Date[@Class = 'Meeting']) = 1) then concat(parent::*/gz:Date[@Class = 'Meeting']/@Date,'T',@Time)
          else if(count(root()//gz:P[count(descendant::gz:Date[@Class = 'Meeting']) = 1 ]) = 1) 
          then concat(root()//gz:P//gz:Date[@Class = 'Meeting']/@Date,'T',@Time) 
          else if (preceding-sibling::gz:Date[@Class = 'Meeting']) then concat(preceding-sibling::gz:Date[@Class = 'Meeting'][1]/@Date,'T',@Time)
          else concat(following-sibling::gz:Date[@Class = 'Meeting'][1]/@Date,'T',@Time)}"> </span>
                </xsl:if>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="@Class='insolvency:onOrBeforeProvingDebtsTimeOnly'">
                <span about="this:notifiableThing" property="insolvency:onOrBeforeProvingDebts" datatype="xsd:dateTime" content="{concat(following-sibling::gz:Date[@Class = 'insolvency:onOrBeforeProvingDebtsDateOnly'][1]/@Date,'T',@Time)}">
                    <span data-gazettes="Time" data-gazettes-class="{@Class}" data-time="{@Time}">
                        <xsl:apply-templates/>
                    </span>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span data-gazettes="Time" data-gazettes-class="{@Class}" data-time="{@Time}">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Notice/gz:TradingAs">
        <p resource="{wlf:name-sibling(../*[1])}" property="gazorg:isTradingAs" content="{wlf:serialize(.)}" data-gazettes="TradingAs">
            <xsl:text>(t/a </xsl:text>
            <xsl:apply-templates/>
            <xsl:text>)</xsl:text>
        </p>
    </xsl:template>

    <xsl:template match="gz:TradingAs">
        <xsl:if test="not($noticeCode = (2447, 2414, 2465, 2424, 2409, 2520, 2528))">
            <xsl:text>Trading as: </xsl:text>
        </xsl:if>  
        <xsl:if test="not($noticeCode = (2520, 2528))">
            <span property="gazorg:isTradingAs" data-gazettes="TradingAs" datatype="xsd:string">
                <xsl:apply-templates/>
            </span>
        </xsl:if>
        <xsl:if test="$noticeCode = (2520, 2528)">
            <p>
                <xsl:text>who at the date of the bankruptcy order was trading as: </xsl:text>
                <span property="gazorg:isTradingAs" data-gazettes="TradingAs" datatype="xsd:string">
                    <xsl:apply-templates/>
                </span>
            </p>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gz:TradingDetails">
        <xsl:text>Trading details: </xsl:text>
        <span resource="{wlf:clean(wlf:serialize(../*[1]))}" property="gzw:has{name()}" content="{wlf:serialize(.)}" data-gazettes="TradingDetails">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:TradingPrevious">
        <xsl:text>Previously trading as: </xsl:text>
        <span property="gazorg:previousCompanyName" datatype="xsd:string" data-gazettes="TradingPrevious">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:TradingAddress">
        <xsl:text>Trading address: </xsl:text>
        <span resource="{wlf:clean(wlf:serialize(.))}" property="gzw:has{name()}" content="{wlf:serialize(.)}" data-gazettes="TradingAddress">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:TypeOfPetition">
        <xsl:text>Type of petition: </xsl:text>
        <span resource="this:notifiableThing" property="insolvency:typeOfPetition" datatype="xsd:string" data-gazettes="TypeOfPetition">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- ############################# -->
    <!-- ##### Nested Paragraphs ##### -->
    <!-- ############################# -->

    <!-- Note that nested paragraphs are common in the source data, but not permitted in the output. -->

    <xsl:template match="gz:P1 | gz:P2 | gz:P3 | gz:P4">
        <li data-gazettes="{name()}">
            <xsl:if test="@SpaceBefore">
                <xsl:attribute name="data-gazettes-space-before" select="@SpaceBefore"/>
            </xsl:if>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="gz:P1para">
        <span data-gazettes="{name()}">
            <xsl:if test="@SpaceBefore">
                <xsl:attribute name="data-gazettes-space-before" select="@SpaceBefore"/>
            </xsl:if>
            <xsl:apply-templates select="gz:Text"/>
            <xsl:if test="gz:P2 | gz:P3 | gz:P4 | gz:P2group | gz:P3group">
                <ul>
                    <xsl:apply-templates select="* except gz:Text"/>
                </ul>
            </xsl:if>
        </span>
    </xsl:template>

    <xsl:template match="gz:P2para">
        <span data-gazettes="{name()}">
            <xsl:if test="@SpaceBefore">
                <xsl:attribute name="data-gazettes-space-before" select="@SpaceBefore"/>
            </xsl:if>
            <xsl:apply-templates select="gz:Text"/>
            <xsl:if test="gz:P3 | gz:P4 | gz:P2group | gz:P3group">
                <ul>
                    <xsl:apply-templates select="* except gz:Text"/>
                </ul>
            </xsl:if>
        </span>
    </xsl:template>

    <xsl:template match="gz:P3para">
        <span data-gazettes="{name()}">
            <xsl:if test="@SpaceBefore">
                <xsl:attribute name="data-gazettes-space-before" select="@SpaceBefore"/>
            </xsl:if>
            <xsl:apply-templates select="gz:Text"/>
            <xsl:if test="gz:P4">
                <ul>
                    <xsl:apply-templates select="* except gz:Text"/>
                </ul>
            </xsl:if>
        </span>
    </xsl:template>

    <xsl:template match="gz:P4para | gz:ForceP">
        <span data-gazettes="{name()}">
            <xsl:if test="@SpaceBefore">
                <xsl:attribute name="data-gazettes-space-before" select="@SpaceBefore"/>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- ######################## -->
    <!-- ##### Very General ##### -->
    <!-- ######################## -->

    <xsl:template match=" gz:P1group | gz:P2group | gz:P3group | gz:P4group ">
        <xsl:choose>
            <xsl:when test="../name() = 'P'">
                <p data-gazettes="{name()}">
                    <xsl:if test="@SpaceBefore">
                        <xsl:attribute name="data-gazettes-space-before" select="@SpaceBefore"/>
                    </xsl:if>
                    <xsl:apply-templates/>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <span data-gazettes="{name()}">
                    <xsl:if test="@SpaceBefore">
                        <xsl:attribute name="data-gazettes-space-before" select="@SpaceBefore"/>
                    </xsl:if>
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="gz:SmallCaps">
        <em class="small-caps">
            <xsl:apply-templates/>
        </em>
    </xsl:template>
    <xsl:template match="gz:ExternalLink">
        <a target="_blank" href="{@URI}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <xsl:template match="gz:Span">
        <span data-gazettes="Span" data-gazettes-parent="{name(parent::node())}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gz:Emphasis">
        <xsl:choose>
            <xsl:when test="$edition = 'Edinburgh'">
                <strong>
                    <xsl:apply-templates/>
                </strong>
            </xsl:when>
            <xsl:otherwise>
                <em>
                    <xsl:apply-templates/>
                </em>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gz:Strong">
        <strong>
            <xsl:apply-templates/>
        </strong>
    </xsl:template>

    <xsl:template match="gz:Superior">
        <sup>
            <xsl:apply-templates/>
        </sup>
    </xsl:template>

    <xsl:template match="gz:Inferior">
        <sub>
            <xsl:apply-templates/>
        </sub>
    </xsl:template>

    <xsl:template match="gz:Image">
        <xsl:param name="logo" select="true()"/>
        <img>
            <xsl:call-template name="gzImgAttrs">
                <xsl:with-param name="pWidthAttribute" select="@Width"/>
                <xsl:with-param name="pHeightAttribute" select="@Height"/>
            </xsl:call-template>
            <xsl:attribute name="alt" select="replace(@Description,'&#10;http://www.&#10;','')"/>
            <!-- Embedded data should be encoded as follows src="data:image/png;base64,ENCODEDATA
		        Note : for testing validation we just put out a filename as validator at http://validator.w3.org/nu
		        incorrectly fails validation of embedded image data (only checks if valid URL)
		      -->
            <xsl:attribute name="src">
                <xsl:choose>
                    <xsl:when test="$vHTMLcompatible">test.png</xsl:when>
                    <xsl:when test="$logo">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(substring-before(normalize-space(.),'.'),'-orig.',substring-after(normalize-space(.),'.'))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>


        </img>
    </xsl:template>


    <xsl:template name="gzImgAttrs">
        <xsl:param name="pWidthAttribute" as="attribute()?"/>
        <xsl:param name="pHeightAttribute" as="attribute()?"/>
        <xsl:variable name="vWidthAttributeVal" select="normalize-space($pWidthAttribute)" as="xs:string?"/>
        <xsl:variable name="vHeightAttributeVal" select="normalize-space($pHeightAttribute)" as="xs:string?"/>

        <xsl:variable name="vWidth" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$vWidthAttributeVal = ''"/>
                <!-- At some point we may wish to set these values to particular pixel sizes
       for now we will  smuggle them through as class attribute -->
                <xsl:when test="$vWidthAttributeVal = ('auto', 'scale-to-fit', 'fit-page-to-image', 'spread')">
                    <xsl:value-of select="$vWidthAttributeVal"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="wlf:gzSize2pixels($vWidthAttributeVal, 'width')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="vHeight" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$vHeightAttributeVal = ''"/>
                <!-- At some point we may wish to set these values to particular pixel sizes -->
                <xsl:when test="$vHeightAttributeVal = ('auto', 'scale-to-fit', 'fit-page-to-image', 'spread')">
                    <xsl:value-of select="$vHeightAttributeVal"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="wlf:gzSize2pixels($vHeightAttributeVal, 'height')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- At some point we may wish to set these values to particular pixel sizes
       for now we will  smuggle them through as class attribute -->
        <xsl:if test="(string(number($vWidth)) = 'NaN') or (string(number($vHeight)) = 'NaN')">
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="(string(number($vWidth)) = 'NaN') and (string(number($vHeight)) = 'NaN')">
                        <xsl:value-of select="concat('width-', $vWidth, ' height-', $vHeight)"/>
                    </xsl:when>
                    <xsl:when test="string(number($vWidth)) = 'NaN'">
                        <xsl:value-of select="concat('width-', $vWidth)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('height-', $vHeight)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:if>

        <xsl:if test="(string(number($vWidth)) != 'NaN') and number($vWidth) gt 0">
            <xsl:attribute name="width" select="$vWidth"/>
        </xsl:if>
        <xsl:if test="(string(number($vHeight)) != 'NaN') and number($vHeight) gt 0">
            <xsl:attribute name="height" select="$vHeight"/>
        </xsl:if>
    </xsl:template>

    <!-- so we may get pt or em or % but I can only find examples of pt so I will focus on that first -->
    <xsl:function name="wlf:gzSize2pixels">
        <xsl:param name="vVal" as="xs:string"/>
        <xsl:param name="vDimension" as="xs:string"/>

        <xsl:analyze-string select="$vVal" regex="(\d+\.?\d*)(pt|em|%)">
            <xsl:matching-substring>
                <xsl:variable name="vValNum" select="number(regex-group(1))" as="xs:double"/>
                <xsl:variable name="vValUnits" select="regex-group(2)" as="xs:string?"/>
                <xsl:choose>
                    <xsl:when test="$vValUnits = 'pt'">
                        <!-- usign screen val of 1pt = 1.333 px
            May need to adjust this id resoultion was paper based (e.g. 300) not screen based (e.g. 72) -->
                        <xsl:value-of select="string(round($vValNum + ($vValNum div 3)))"/>
                    </xsl:when>
                    <xsl:when test="$vValUnits = 'em'">
                        <!-- well this all depends on font size used for th Em and we dont have that so we will multiply by 10 -->
                        <xsl:value-of select="string(round($vValNum * 10))"/>
                    </xsl:when>
                    <!-- it is % so we will base it on an A4 page at 595 x 842 pts -->
                    <xsl:when test="$vValUnits = '%' and $vDimension='width'">
                        <xsl:variable name="vPts" select="$vValNum * 5.95"/>
                        <xsl:value-of select="string(round($vPts + ($vPts div 3)))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- it is % and height -->
                        <xsl:variable name="vPts" select="$vValNum * 8.42"/>
                        <xsl:value-of select="string(round($vPts + ($vPts div 3)))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <!-- ################## -->
    <!-- ##### TABLES ##### -->
    <!-- ################## -->
    <xsl:template match="gz:Tabular">
        <xsl:choose>
            <!-- If a table only contains a single image then count it as a <figure> -->
            <xsl:when test="html:table[@cols='1']/html:tbody[count(*) = 1]/html:tr[count(*) = 1]/html:td[count(*) = 1]/gz:Image">

                <figure>
                    <!-- If a the Image has a paragraph of text immediately preceeding it then make this the caption -->
                    <xsl:if test="local-name(preceding-sibling::*[1]) = 'P' and preceding-sibling::gz:P[1]/.[count(*) = 1]">
                        <figcaption>
                            <xsl:value-of select="preceding-sibling::gz:P[1]/gz:Text"/>
                        </figcaption>
                    </xsl:if>
                    <xsl:apply-templates select=".//gz:Image">
                        <xsl:with-param name="logo" select="false()"/>
                    </xsl:apply-templates>
                </figure>
            </xsl:when>
            <xsl:otherwise>
                <div data-gazettes="Tabular">
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Suppress the immediately preeceeding paragraph in the instance where there is a table contains only an image -->
    <xsl:template match="gz:P[count(*) = 1 and (local-name(following-sibling::*[1]) = 'Tabular') and following-sibling::*[1]/html:table[@cols='1']/html:tbody[count(*) = 1]/html:tr[count(*) = 1]/html:td[count(*) = 1]/gz:Image]"/>

    <xsl:template match="gz:Number">
        <dl>
            <dd>Number:</dd>
            <dt id="number">
                <xsl:apply-templates/>
            </dt>
        </dl>
    </xsl:template>

    <xsl:template match="gz:TableText">
        <dl>
            <dd>Table text:</dd>
            <dt id="tableText">
                <xsl:apply-templates/>
            </dt>
        </dl>
    </xsl:template>

    <xsl:template match="html:table">
        <table>
            <xsl:copy-of select="@cols"/>
            <xsl:apply-templates/>
        </table>
    </xsl:template>

    <xsl:template match="html:caption">
        <caption>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </caption>
    </xsl:template>

    <xsl:template match="html:colgroup">
        <colgroup>
            <xsl:variable name="colgroup" select="."/>
            <xsl:for-each select="@*">
                <xsl:choose>
                    <!-- span is only a valid attribute when colgroup contains 0 col elements -->
                    <xsl:when test="name() = 'span' and count($colgroup/html:col) &gt; 0"/>
                    <xsl:otherwise>
                        <xsl:copy/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:variable name="totalwidth">
                <xsl:value-of select="sum(html:col/number(replace(@width, 'pt', '')))"/>
            </xsl:variable>
            <!-- Add HTML5 data attribute for the original total width in pt, for use in printing -->
            <xsl:attribute name="data-original-width" select="concat(round($totalwidth),'pt')"/>
            <!-- xsl:variable name="totalcolumns"><xsl:value-of select="count(html:col)"/></xsl:variable -->
            <!--xsl:message>
				<xsl:value-of select="$totalwidth"/>
			</xsl:message-->
            <xsl:for-each select="html:col">
                <col>
                    <xsl:variable name="thiscolumn" select="number(replace(@width, 'pt', ''))"/>
                    <xsl:attribute name="width"><xsl:value-of select="round((100 div $totalwidth) * $thiscolumn)"/>%</xsl:attribute>
                </col>
            </xsl:for-each>
        </colgroup>
    </xsl:template>

    <xsl:template match="html:col">
        <col>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </col>
    </xsl:template>

    <xsl:template match="html:thead">
        <thead>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </thead>
    </xsl:template>

    <xsl:template match="html:tfoot">
        <tfoot>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </tfoot>
    </xsl:template>

    <xsl:template match="html:tbody">
        <tbody>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </tbody>
    </xsl:template>

    <xsl:template match="html:tr">
        <tr>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="html:td">
        <td>
            <xsl:if test="@rowspan and @rowspan != '1'">
                <xsl:attribute name="rowspan" select="@rowspan"/>
            </xsl:if>
            <xsl:if test="@colspan and @colspan != '1'">
                <xsl:attribute name="colspan" select="@colspan"/>
            </xsl:if>
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xsl:template match="html:td/gz:P/gz:Text">
        <p data-gazettes="Text">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="html:th">
        <th>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </th>
    </xsl:template>

    <xsl:template name="gazettes-metadata">
        <gazette-metadata xmlns="http://www.gazettes.co.uk/metadata">
            <bundle-id>
                <xsl:value-of select="$bundleId"/>
            </bundle-id>
            <notice-id>
                <xsl:value-of select="$noticeId"/>
            </notice-id>
            <status>
                <xsl:value-of select="$status"/>
            </status>
            <submitted-date>
                <xsl:value-of select="$submitted-date"/>
            </submitted-date>
            <version-count>
                <xsl:value-of select="$version-count"/>
            </version-count>
            <notice-code>
                <xsl:value-of select="$noticeType"/>
            </notice-code>
            <xsl:sequence select="$category"/>
            <notice-logo>
                <xsl:value-of select="//*[local-name()='Image']"/>
            </notice-logo>
            <notice-capture-method>gazette-schema-xml</notice-capture-method>
            <edition>
                <xsl:value-of select="$edition"/>
            </edition>
            <xsl:if test="$issueNumber">
                <issue>
                    <xsl:value-of select="$issueNumber"/>
                </issue>

                <xsl:if test="not($pageNumber='0')">
                    <page-number>
                        <xsl:value-of select="$pageNumber"/>
                    </page-number>
                </xsl:if>
            </xsl:if>
            <legacy-notice-number>
                <xsl:value-of select="//gz:Notice/@Reference"/>
            </legacy-notice-number>
            <user-submitted>
                <xsl:value-of select="$user-submitted"/>
            </user-submitted>
            <xsl:variable name="publicationDate">
                <xsl:apply-templates select="//ukm:PublishDate"/>
            </xsl:variable>
            <publication-date>
                <xsl:value-of select="$publishDate"/>
            </publication-date>
            <publication-year>
                <xsl:value-of select="substring($publicationDate,1,4)"/>
            </publication-year>
            <issue-isbn>
                <xsl:value-of select="$issue-isbn"/>
            </issue-isbn>

            <organisation-id>
                <xsl:value-of select="$organisationId"/>
            </organisation-id>
            <xsl:if test="$isCompanyLawNotice">
                <title>
                    <xsl:value-of select="//gz:CompanyName"/>
                </title>
                <company-number>
                    <xsl:value-of select="//gz:CompanyNumber"/>
                </company-number>
            </xsl:if>
        </gazette-metadata>
    </xsl:template>

    <xsl:template name="summary">
        <section class="summary">
            <dl>
                <dt>Company Number</dt>
                <dd>
                    <xsl:value-of select="//gz:CompanyNumber"/>
                </dd>
                <dt>Document Type</dt>
                <dd>
                    <xsl:value-of select="//gz:DocumentType"/>
                </dd>
                <dt>Date of Issue</dt>
                <dd>
                    <xsl:value-of select="format-date(//gz:Date[@Class='Issued']/@Date,'[D] [MNn] [Y0001]')"/>
                </dd>
            </dl>
        </section>
    </xsl:template>

    <xsl:template match="gz:Administrator/gz:Reference">
        <span about="this:IP1" property="person:hasIPReferenceNumber" datatype="xsd:string">
            <xsl:text>(</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>)</xsl:text>
        </span>
    </xsl:template>

    <xsl:template name="Legislation">
        <xsl:if test="$edition = 'London'">
            <section>
                <p>Notice is hereby given pursuant to section 27 (Deceased Estates) of the Trustee Act 1925, that any person having a claim against or an interest in the estate of any of the deceased persons whose names and addresses are set out above is hereby required to send particulars in writing of his claim or interest to the person or persons whose names and addresses are set out above, and to send such particulars before the date specified in relation to that deceased person displayed above, after which date the personal representatives will distribute the estate among the persons entitled thereto having regard only to the claims and interests of which they have had notice and will not, as respects the property so distributed, be liable to any person of whose claim they shall not then have had notice.</p>
            </section>
        </xsl:if>
        <xsl:if test="$edition = 'Belfast'">
            <section>
                <p> Notice is hereby given pursuant to section 28 (Deceased Estates) of the Trustee Act (Northern Ireland) 1958, that any person having a claim against or an interest in the estate of any of the deceased persons whose names and addresses are set out above is hereby required to send particulars in writing of his claim or interest to the person or persons whose names and addresses are set out above, and to send such particulars before the date specified in relation to that deceased person displayed above, after which date the personal representatives will distribute the estate among the persons entitled thereto having regard only to the claims and interests of which they have had notice and will not, as respects the property so distributed, be liable to any person of whose claim they shall not then have had notice. </p>
            </section>
        </xsl:if>
    </xsl:template>

    <xsl:template match="processing-instruction('BR')">
        <br/>
    </xsl:template>

    <!-- 
	This function generates P1|P2|P3|P4 blocks 
	depends on function wlf:findP1s for param p1s

	eg:
currentPos: 2
items:
	<P/>       pos 1    - line 1
	<P1/><P1/> pos 2, 3 - line 2
	<P/>       pos 4    - line 3
	<P1/>      pos 5    - line 4
	<P>        pos 6    - line 5
positions: (2,4,5,6)
result: apply-templates on subsequence (line 2) for currentPos=2
result: apply-templates on subsequence (line 4) for currentPos=5
	-->
    <xsl:function name="wlf:apply-subsequence">
        <xsl:param name="currentPos" as="xs:integer"/>
        <xsl:param name="positions" as="xs:integer*"/>
        <xsl:param name="items" as="item()*"/>

        <xsl:variable name="start" as="xs:integer" select="index-of($positions, $currentPos)"/>
        <xsl:variable name="end" as="xs:integer" select="$start + 1"/>
        <xsl:variable name="count" as="xs:integer" select="$positions[$end] - $positions[$start]"/>
        <ul>
            <xsl:apply-templates select="subsequence($items, $positions[$start], $count)"/>
        </ul>
    </xsl:function>

    <!-- 
	This function returns a set of integer positions as follows:
	index 1: start position of P1|P2|P3|P4
	index 2: end position + 1 of P1|P2|P3|P4
	index 3: start position of next P1|P2|P3|P4
	index 4: end position + 1 of next P1|P2|P3|P4
	...
	eg:
items:
	<P/>       pos 1 
	<P1/><P1/> pos 2, 3
	<P/>       pos 4
	<P1/>      pos 5
	<P>        pos 6
returns integer set: (2,4,5,6)
	count of integer set must always be even
	-->
    <xsl:function name="wlf:findP1s" as="xs:integer*">
        <xsl:param name="items" as="item()*"/>
        <xsl:for-each select="$items">
            <xsl:variable name="prevPos" as="xs:integer" select="position() - 1"/>
            <xsl:variable name="nextPos" as="xs:integer" select="position() + 1"/>
            <xsl:if test="name(.) = ('P1','P2','P3') and not(name(.) = name($items[$prevPos]))">
                <xsl:sequence select="position()"/>
            </xsl:if>
            <xsl:if test="name(.) = ('P1','P2','P3') and not(name(.) = name($items[$nextPos]))">
                <xsl:sequence select="$nextPos"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="wlf:getTimeStamp">
        <xsl:param name="arg"/>
        <xsl:choose>
            <xsl:when test="$arg castable as xs:time">
                <xsl:value-of select="$arg"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:analyze-string select="$arg" regex="^([0-9]*):([0-9]*):([0-9]*)([.0-9]*)">
                    <xsl:matching-substring>
                        <xsl:value-of select="concat(wlf:get2Digits(regex-group(1)),':', wlf:get2Digits(regex-group(2)),':',wlf:get2Digits(regex-group(3)))"/>
                    </xsl:matching-substring>

                    <xsl:non-matching-substring>
                        <xsl:value-of select="$arg"/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="wlf:get2Digits">
        <xsl:param name="arg"/>
        <xsl:value-of select="if ($arg castable as xs:integer and xs:integer($arg) &lt; 10) then concat('0',$arg) else $arg"/>
    </xsl:function>

    <xsl:function name="wlf:stripSpecialChars">
        <xsl:param name="string"/>
        <!--<xsl:variable name="AllowedSymbols" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789()*%$#@!~&lt;&gt;,.?[]=- +   /\ '"/>-->
        <xsl:variable name="AllowedSymbols" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'"/>
        <xsl:value-of select="
      translate(
      $string,
      translate($string, $AllowedSymbols, ''),
      '')
      "/>
    </xsl:function>

    <xsl:function name="wlf:tokenizeAndCapitalizeFirstWord">
        <xsl:param name="string"/>
        <xsl:variable name="tolkenisedString" select="tokenize(lower-case($string),' ')"/>
        <xsl:variable name="finalString">
            <xsl:for-each select="$tolkenisedString">
                <xsl:value-of select="wlf:capitalize-first(wlf:stripSpecialChars(.))"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$finalString"/>
    </xsl:function>
</xsl:stylesheet>
