<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xsl" version="2.0">
	<xsl:import href="gazettes2XHTMLRDFa.xsl"/>
	
	<!-- this works but does nto make well formed XML e.g. img and br with no closing element/empty
	<xsl:output method="html" version="5.0" encoding="UTF-8" indent="yes" /> -->
	<xsl:output method="xhtml" version="1.0" encoding="UTF-8" indent="yes"  omit-xml-declaration="yes"/>
	
	<xsl:template match="/" priority="+1">
		<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html>
</xsl:text>
		<xsl:next-match/>
	</xsl:template>
	
	<xsl:variable name="vHTMLcompatible" select="true()" as="xs:boolean"/>
	<xsl:variable name="paramConfigXml" select="if (doc-available('../forms/configuration/LGconfiguration.xml')) then doc('../forms/configuration/LGconfiguration.xml') else ()"/>
</xsl:stylesheet>