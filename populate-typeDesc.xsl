<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nuds="http://nomisma.org/nuds"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mets="http://www.loc.gov/METS/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs xsi" version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:variable name="coinType" select="//nuds:typeDesc/@xlink:href"/>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="nuds:maintenanceHistory">
        <xsl:element name="maintenanceHistory" namespace="http://nomisma.org/nuds">
            <xsl:apply-templates/>

            <xsl:if test="string($coinType)">
                <maintenanceEvent xmlns="http://nomisma.org/nuds">
                    <eventType>revised</eventType>
                    <eventDateTime standardDateTime="{current-dateTime()}">
                        <xsl:value-of select="current-dateTime()"/>
                    </eventDateTime>
                    <agentType>machine</agentType>
                    <agent>XSLT</agent>
                    <eventDescription>Extracted typological data from coin type URI; moved URI to
                        nuds:reference[@arcrole='nmo:hasTypeSeriesItem']</eventDescription>
                </maintenanceEvent>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template match="nuds:descMeta">
        <xsl:apply-templates/>
        <xsl:if test="not(nuds:refDesc) and string($coinType)">
            <xsl:element name="refDesc" namespace="http://nomisma.org/nuds">
                <xsl:element name="reference" namespace="http://nomisma.org/nuds">
                    <xsl:attribute name="xlink:arcrole">nmo:hasTypeSeriesItem</xsl:attribute>
                    <xsl:attribute name="xlink:type">simple</xsl:attribute>
                    <xsl:attribute name="xlink:href" select="$coinType"/>

                    <xsl:value-of select="document(concat($coinType, '.xml'))//nuds:title"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="nuds:typeDesc[@xlink:href]">
        <xsl:variable name="xml" select="concat(@xlink:href, '.xml')"/>

        <xsl:element name="typeDesc" namespace="http://nomisma.org/nuds">
            <xsl:copy-of select="document($xml)//nuds:typeDesc/*" copy-namespaces="no"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="nuds:refDesc[not(child::nuds:reference[@xlink:arcole])]">
        <xsl:element name="refDesc" namespace="http://nomisma.org/nuds">
            <xsl:apply-templates select="nuds:reference[not(nuds:title = 'RIC')]"/>
            <xsl:if test="string($coinType)">
                <xsl:element name="reference" namespace="http://nomisma.org/nuds">
                    <xsl:attribute name="xlink:arcrole">nmo:hasTypeSeriesItem</xsl:attribute>
                    <xsl:attribute name="xlink:type">simple</xsl:attribute>
                    <xsl:attribute name="xlink:href" select="$coinType"/>

                    <xsl:value-of select="document(concat($coinType, '.xml'))//nuds:title"/>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
