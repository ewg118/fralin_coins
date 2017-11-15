<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nuds="http://nomisma.org/nuds"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mets="http://www.loc.gov/METS/" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="nuds" version="2.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:variable name="coinType" select="//nuds:typeDesc/@xlink:href"/>
    <xsl:variable name="recordId" select="/nuds:nuds/nuds:control/nuds:recordId"/>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="nuds:nuds">
        <nuds xmlns="http://nomisma.org/nuds" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mets="http://www.loc.gov/METS/"
            xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xsi:schemaLocation="http://nomisma.org/nuds http://nomisma.org/nuds.xsd" recordType="physical">

            <xsl:apply-templates/>
        </nuds>
    </xsl:template>

    <xsl:template match="nuds:control">
        <xsl:element name="control" namespace="http://nomisma.org/nuds">
            <!-- reorder -->
            <xsl:apply-templates select="nuds:recordId"/>
            <xsl:apply-templates select="nuds:otherRecordId"/>
            <xsl:apply-templates select="nuds:publicationStatus"/>
            <xsl:apply-templates select="nuds:maintenanceStatus"/>
            <xsl:apply-templates select="nuds:maintenanceAgency"/>
            <xsl:apply-templates select="nuds:maintenanceHistory"/>            
            <xsl:apply-templates select="nuds:rightsStmt"/>
            <xsl:apply-templates select="nuds:semanticDeclaration"/>
        </xsl:element>
    </xsl:template>
    
    <!-- insert description into previousColl -->
    <xsl:template match="nuds:previousColl[not(child::*)]">      
        <xsl:if test="not(contains(., 'Republik'))">
            <xsl:element name="previousColl" namespace="http://nomisma.org/nuds">
                <xsl:element name="description" namespace="http://nomisma.org/nuds">
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:element>
        </xsl:if>        
    </xsl:template>
    
    <!-- insert rightsstatement URI-->
    <xsl:template match="nuds:rightsStmt">
        <xsl:element name="rightsStmt" namespace="http://nomisma.org/nuds">
            <license xmlns="http://nomisma.org/nuds" xlink:type="simple"
                xlink:href="http://opendatacommons.org/licenses/odbl/">Metadata are openly licensed with a Open Data Commons Open Database License (ODbL)</license>
            <rights xmlns="http://nomisma.org/nuds" xlink:type="simple"
                xlink:href="http://rightsstatements.org/vocab/NoC-US/1.0/">The object and images are not under copyright (Public Domain) in the United States.</rights>
        </xsl:element>
    </xsl:template>

    <xsl:template match="nuds:maintenanceHistory">
        <xsl:element name="maintenanceHistory" namespace="http://nomisma.org/nuds">
            <xsl:apply-templates/>

            <maintenanceEvent xmlns="http://nomisma.org/nuds">
                <eventType>revised</eventType>
                <eventDateTime standardDateTime="{current-dateTime()}">
                    <xsl:value-of select="current-dateTime()"/>
                </eventDateTime>
                <agentType>machine</agentType>
                <agent>XSLT</agent>
                <eventDescription>Extracted typological data from coin type URI; moved URI to nuds:reference[@arcrole='nmo:hasTypeSeriesItem']. Restructured to
                    make compatible with current NUDS XSD schema.</eventDescription>
            </maintenanceEvent>
        </xsl:element>
    </xsl:template>

    <xsl:template match="nuds:descMeta">
        <xsl:element name="descMeta" namespace="http://nomisma.org/nuds">
            
            <!-- place in order -->
            <xsl:apply-templates select="nuds:title"/>
            <xsl:apply-templates select="nuds:typeDesc"/>
            <xsl:apply-templates select="nuds:physDesc"/>
            <xsl:apply-templates select="nuds:findspotDesc"/>
            <xsl:apply-templates select="nuds:refDesc"/>            
            
            <xsl:if test="not(nuds:refDesc) and string($coinType)">
                <xsl:element name="refDesc" namespace="http://nomisma.org/nuds">
                    <xsl:element name="reference" namespace="http://nomisma.org/nuds">
                        <xsl:attribute name="xlink:arcrole">nmo:hasTypeSeriesItem</xsl:attribute>
                        <xsl:attribute name="xlink:type">simple</xsl:attribute>
                        <xsl:attribute name="xlink:href" select="$coinType"/>
                        <tei:title>
                            <xsl:value-of select="document(concat($coinType, '.xml'))//nuds:title"/>
                        </tei:title>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            
            <xsl:apply-templates select="nuds:adminDesc"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="nuds:typeDesc">
        <xsl:element name="typeDesc" namespace="http://nomisma.org/nuds">


            <!-- reorder elements -->
            <xsl:choose>
                <xsl:when test="@xlink:href">
                    <xsl:variable name="xml" select="concat(@xlink:href, '.xml')"/>
                    <xsl:variable name="typeDesc" as="node()*">
                        <xsl:copy-of select="document($xml)//nuds:typeDesc" copy-namespaces="no"/>
                    </xsl:variable>

                    <xsl:apply-templates select="$typeDesc/nuds:objectType"/>
                    <xsl:apply-templates select="$typeDesc/nuds:date"/>
                    <xsl:apply-templates select="$typeDesc/nuds:dateRange"/>
                    <xsl:apply-templates select="$typeDesc/nuds:denomination"/>
                    <xsl:apply-templates select="$typeDesc/nuds:manufacture"/>
                    <xsl:apply-templates select="$typeDesc/nuds:authority"/>
                    <xsl:apply-templates select="$typeDesc/nuds:geographic[child::*]"/>
                    <xsl:apply-templates select="$typeDesc/nuds:obverse"/>
                    <xsl:apply-templates select="$typeDesc/nuds:reverse"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="nuds:objectType"/>
                    <xsl:apply-templates select="nuds:date"/>
                    <xsl:apply-templates select="nuds:dateRange"/>
                    <xsl:apply-templates select="nuds:denomination"/>
                    <xsl:apply-templates select="nuds:manufacture"/>
                    <xsl:apply-templates select="nuds:authority"/>
                    <xsl:apply-templates select="nuds:geographic[child::*]"/>
                    <xsl:apply-templates select="nuds:obverse"/>
                    <xsl:apply-templates select="nuds:reverse"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="nuds:obverse | nuds:reverse">
        <xsl:element name="{name()}" namespace="http://nomisma.org/nuds">
            <xsl:apply-templates select="nuds:legend"/>
            <xsl:apply-templates select="nuds:type"/>
            <xsl:apply-templates select="nuds:persname"/>
        </xsl:element>
    </xsl:template>
    
    <!-- suppress blank authority/geographic elements -->
    <xsl:template match="nuds:authority|nuds:geographic">
        <xsl:if test="child::*">
            <xsl:element name="{local-name()}" namespace="http://nomisma.org/nuds">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="nuds:refDesc">
        <xsl:if test="child::nuds:reference[@xlink:arcrole or (nuds:identifer and nuds:title)]">
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
        </xsl:if>        
    </xsl:template>

    <!-- replace NUDS titles with TEI namespaced elements -->
    <xsl:template match="nuds:reference">
        <xsl:element name="reference" namespace="http://nomisma.org/nuds">

            <xsl:choose>
                <xsl:when test="@xlink:arcrole">
                    <xsl:attribute name="xlink:arcrole">nmo:hasTypeSeriesItem</xsl:attribute>
                    <xsl:attribute name="xlink:type">simple</xsl:attribute>
                    <xsl:attribute name="xlink:href" select="@xlink:href"/>
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="nuds:title">
                        <tei:title>
                            <xsl:value-of select="nuds:title"/>
                        </tei:title>
                    </xsl:if>
                    <xsl:if test="nuds:identifier">
                        <xsl:text> </xsl:text>
                        <tei:idno>
                            <xsl:value-of select="nuds:identifier"/>
                        </tei:idno>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="nuds:chronItem">
        <xsl:element name="chronItem" namespace="http://nomisma.org/nuds">

            <!-- insert date for the hoard provenance event -->
            <xsl:choose>
                <xsl:when test="contains($recordId, '1987.46') and child::nuds:description">
                    <date standardDate="1985" xmlns="http://nomisma.org/nuds">1985</date>
                </xsl:when>
                <xsl:when test="contains($recordId, '1991.17') and child::nuds:description">
                    <date standardDate="1983" xmlns="http://nomisma.org/nuds">1983</date>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="nuds:acquisition">
        <xsl:choose>
            <xsl:when test="contains($recordId, '1987.46')">
                <date standardDate="1987" xmlns="http://nomisma.org/nuds">1987</date>
            </xsl:when>
            <xsl:when test="contains($recordId, '1989.12')">
                <date standardDate="1989-06-26" xmlns="http://nomisma.org/nuds">June 26, 1989</date>
            </xsl:when>
            <xsl:when test="contains($recordId, '1989.19')">
                <date standardDate="1989-09" xmlns="http://nomisma.org/nuds">September 1989</date>
            </xsl:when>
            <xsl:when test="contains($recordId, '1990.18')">
                <date standardDate="1990" xmlns="http://nomisma.org/nuds">1990</date>
            </xsl:when>
            <xsl:when test="contains($recordId, '1991.17')">
                <date standardDate="1991" xmlns="http://nomisma.org/nuds">1991</date>
            </xsl:when>
            <xsl:when test="contains($recordId, '1992')">
                <date standardDate="1992-11-04" xmlns="http://nomisma.org/nuds">November 4, 1992</date>
            </xsl:when>
            <xsl:when test="contains($recordId, '1994')">
                <date standardDate="1994" xmlns="http://nomisma.org/nuds">1994</date>
            </xsl:when>
            <xsl:when test="contains($recordId, '1995.3')">
                <date standardDate="1995" xmlns="http://nomisma.org/nuds">1995</date>
            </xsl:when>
            <xsl:when test="contains($recordId, '1996.2')">
                <date standardDate="1996" xmlns="http://nomisma.org/nuds">1996</date>
            </xsl:when>
            <xsl:when test="contains($recordId, '2001.4')">
                <date standardDate="2001" xmlns="http://nomisma.org/nuds">2001</date>
            </xsl:when>
            <xsl:when test="contains($recordId, '2012')">
                <date standardDate="2012" xmlns="http://nomisma.org/nuds">2012</date>
            </xsl:when>
        </xsl:choose>

        <xsl:element name="acquiredFrom" namespace="http://nomisma.org/nuds">
            <xsl:value-of select="nuds:acquiredFrom"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@standardDateTime">
        <xsl:attribute name="standardDateTime" select="substring-before(., 'Z')"/>
    </xsl:template>
    
    <!-- make date XSD instead of ISO 8601 compliant -->
    <xsl:template match="@standardDate">
        <xsl:choose>
            <xsl:when test="number(.) &lt;= 0">
                <xsl:attribute name="standardDate" select="format-number((number(.) - 1), '0000')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="standardDate" select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
