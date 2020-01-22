<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ar="http://argument.chuston.net/v0/argument"
	xmlns="http://www.w3.org/TR/html4/">
	
	<xsl:output method="html" 
		doctype-public="html"
    	omit-xml-declaration="yes"
    	encoding="UTF-8"
    	indent="yes"/>
	
	<xsl:template match="/ar:argument">
		<html>
			<head>
				<title><xsl:value-of select="@title"/></title>
				<link rel="stylesheet" href="style.css"/>
			</head>
			<body>
				<h1 class="title"><xsl:value-of select="@title" /></h1>
				<h2 class="section">Claims</h2>
				<xsl:for-each select="//ar:claims/ar:claim">
					<xsl:sort select="@claimid"  data-type="number"/>
					<xsl:call-template name="claim" />
				</xsl:for-each>
				<h2 class="section">Subjects</h2>
				<table class="subjectList">
					<xsl:for-each select="//ar:subjects/ar:subject">
						<xsl:sort select="@subid"  data-type="text"/>
						<xsl:call-template name="subject" />
					</xsl:for-each>
				</table>
				
				<h2 id="events" class="section">Events</h2>
				<table class="eventList">
					<tr>
						<th class="eventID">Event Id</th>
						<th class="eventDate">Date</th>
						<th class="eventDesc">Description</th>
					</tr>
					<xsl:for-each select="//ar:events/ar:event">
						<xsl:sort select="substring(@pit,1,4)" data-type="number"/>
						<xsl:sort select="substring(@pit,6,2)" data-type="number"/>
						<xsl:sort select="substring(@pit,9,2)" data-type="number"/>
						<xsl:call-template name="event" />
					</xsl:for-each>
				</table>
				
				<h2 id="data" class="section">Data</h2>
				<table class="dataList">
					<xsl:for-each select="//ar:datas/ar:data">
						<xsl:sort select="@did" data-type="number" />
						<tr>
							<td class="dataID">
								<xsl:element name="span">
									<xsl:attribute name="id">
										<xsl:value-of select="concat('data-',@did)"/>
									</xsl:attribute>
								</xsl:element>
								<xsl:value-of select="@did"/>
							</td>
							<td><xsl:apply-templates mode="assert" select="child::*|text()"/> </td>
						</tr>
					</xsl:for-each>
				</table>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template name="subject">
		<tr>
			<td class="subjectID"><xsl:value-of select="@subid"/></td>
			<td class="subjectDesc"><xsl:apply-templates mode="assert" select="text()"/></td>
		</tr>
		<tr>
			<td/>
			<td class="subjectData">
				<!-- <h3>Data:</h3> -->
				<xsl:call-template name="subjectData">
					<xsl:with-param name="subid" select="@subid"/>
				</xsl:call-template>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template name="subjectData">
		<xsl:param name="subid" />
		<ul>
			<xsl:for-each select="//ar:datas/ar:data/ar:subref[@subid=$subid]">
				<xsl:variable name="curDID" select="ancestor::ar:data/@did"/>
				<li class="subjectDataDesc"><xsl:apply-templates mode="assert" select="//ar:data[@did=$curDID]/*|//ar:data[@did=$curDID]/text()" /></li>
			</xsl:for-each>
		</ul>
	</xsl:template>
	
	<xsl:template name="event">
		<tr>
			<td class="eventID"><xsl:value-of select="@eventid"/></td>
			<td class="eventDate"><xsl:value-of select="@pit" /></td>
			<td class="eventDesc"><xsl:apply-templates mode="assert" select="./*|./text()"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template name="claim">
		<table class="claim">
			<tr>
				<td class="claimid"><xsl:value-of select="@claimid"/></td>
				<td class="assert"><xsl:apply-templates mode="assert" select="ar:assert/*|ar:assert/text()"/> </td>
			</tr>
			<xsl:if test="count(ar:warrant)>0">
			<tr>
				<td class="warrant-cell-heading"><u>Warrants:</u></td>
				<td class="claim-warrant-list">
					<xsl:for-each select="ar:warrant">
						<p>
						<xsl:apply-templates mode="assert" select="descendant::ar:desc"/>
						<xsl:element name="a">
							<xsl:attribute name="href"><xsl:value-of select="concat('#data-',ar:dataref/@did)"/></xsl:attribute>
							(<xsl:value-of select="ar:dataref/@did"/>)
						</xsl:element>
						</p>
					</xsl:for-each>
				</td>
			</tr>
			</xsl:if>
		</table>
	</xsl:template>
	
	
	<xsl:template mode="assert" match="ar:subref">
		<xsl:variable name="parmsubid"><xsl:value-of select="@subid"/></xsl:variable>
		<u><xsl:value-of select="//ar:subjects/ar:subject[@subid=$parmsubid]/text()"/></u>
	</xsl:template>
	
	<xsl:template mode="assert" match="ar:dataref">
		<xsl:variable name="parmdataid"><xsl:value-of select="@did"/></xsl:variable>
		<u><xsl:apply-templates mode="assert" select="//ar:datas/ar:data[@did=$parmdataid]/*|//ar:datas/ar:data[@did=$parmdataid]/*/text()"/></u>
	</xsl:template>
	
	<xsl:template mode="assert" match="ar:eventref">
		<xsl:variable name="parmid"><xsl:value-of select="@eventid"/></xsl:variable>
		<i>
			<xsl:apply-templates mode="assert" select="//ar:events/ar:event[@eventid=$parmid]/*|//ar:events/ar:event[@eventid=$parmid]/text()"/>
			(<xsl:value-of select="//ar:events/ar:event[@eventid=$parmid]/@pit"/>)
		</i>
	</xsl:template>
	
	<xsl:template mode="assert" match="ar:claimref">
		<xsl:variable name="parmid"><xsl:value-of select="@claimid"/></xsl:variable>
		<b>Claim <xsl:value-of select="//ar:claims/ar:claim[@claimid=$parmid]/@claimid"/></b>
	</xsl:template>
	
	<xsl:template mode="assert" match="ar:question">
		<span class="question"><xsl:apply-templates mode="assert" select="./*|./text()"/></span>
	</xsl:template>
	
	 <xsl:template match="@*|node()" mode="assert">
     	<xsl:copy>
        	<xsl:apply-templates mode="assert" select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
	<xsl:template mode="assert" match="text()">
		<xsl:copy-of select="."></xsl:copy-of>
	</xsl:template>
	
	<xsl:template match="text()|@*" />
	
</xsl:stylesheet>