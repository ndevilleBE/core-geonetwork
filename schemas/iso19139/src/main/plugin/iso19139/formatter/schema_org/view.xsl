<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tr="java:org.fao.geonet.services.metadata.format.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xslUtils="java:org.fao.geonet.util.XslUtil"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">




  <xsl:variable name="baseurl" select="xslUtils:getSiteUrl()"/>	
  
  <!-- Load the editor configuration to be able
  to render the different views -->
  <xsl:variable name="configuration"
                select="document('../../layout/config-editor.xml')"/>

			
  <!-- Some utility -->
  <xsl:include href="../../layout/evaluate.xsl"/>
  <xsl:include href="../../layout/utility-tpl-multilingual.xsl"/>


  
  <!-- The core formatter XSL layout based on the editor configuration -->
  <xsl:include href="sharedFormatterDir/xslt/render-layout.xsl"/>
  <!--<xsl:include href="../../../../../data/formatter/xslt/render-layout.xsl"/>-->

  <!-- Define the metadata to be loaded for this schema plugin-->
  <xsl:variable name="metadata"
                select="/root/gmd:MD_Metadata"/>


  <!-- Specific schema rendering -->
  <xsl:template mode="getMetadataTitle" match="gmd:MD_Metadata">
    <xsl:variable name="value"
                  select="gmd:identificationInfo/*/gmd:citation/*/gmd:title"/>	  
    <xsl:value-of select="$value/gco:CharacterString"/>
  </xsl:template>

  <xsl:template mode="getMetadataAbstract" match="gmd:MD_Metadata">
    <xsl:variable name="value"
                  select="gmd:identificationInfo/*/gmd:abstract"/>
    <xsl:value-of select="$value/gco:CharacterString"/>
  </xsl:template>

  <!-- Most of the elements are ... -->
  <xsl:template mode="render-field"
                match="*[gco:CharacterString|gco:Integer|gco:Decimal|
       gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|
       gco:Angle|gmx:FileName|
       gco:Scale|gco:Record|gco:RecordType|gmx:MimeFileType|gmd:URL|
       gco:LocalName|gmd:PT_FreeText|gml:beginPosition|gml:endPosition|
       gco:Date|gco:DateTime|*/@codeListValue]"
                priority="50">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value" select="*|*/@codeListValue"/>
        <xsl:apply-templates mode="render-value" select="@*"/>
      </dd>
    </dl>
  </xsl:template>

  <!-- Some elements are only containers so bypass them -->
  <xsl:template mode="render-field"
                match="*[count(gmd:*) = 1]"
                priority="50">

    <xsl:apply-templates mode="render-value" select="@*"/>
    <xsl:apply-templates mode="render-field" select="*"/>
  </xsl:template>


  <!-- Some major sections are boxed -->
  <xsl:template mode="render-field"
                match="*[name() = $configuration/editor/fieldsWithFieldset/name
    or @gco:isoType = $configuration/editor/fieldsWithFieldset/name]|
      gmd:report/*|
      gmd:result/*|
      gmd:extent[name(..)!='gmd:EX_TemporalExtent']|
      *[$isFlatMode = false() and gmd:* and not(gco:CharacterString) and not(gmd:URL)]">

    <div class="entry name">
      <h3>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
        <xsl:apply-templates mode="render-value"
                             select="@*"/>
      </h3>
      <div class="target">
        <xsl:apply-templates mode="render-field" select="*"/>
      </div>
    </div>
  </xsl:template>


  <!-- Bbox is displayed with an overview and the geom displayed on it
  and the coordinates displayed around -->
  <xsl:template mode="render-field"
                match="gmd:EX_GeographicBoundingBox[gmd:westBoundLongitude/gco:Decimal != '']">
	<div itemprop="spatial"  itemscope="itemscope" itemtype="http://schema.org/Place">
		  <span itemprop="geo" itemscope="itemscope" itemtype="http://schema.org/geoShape">
		  <dl><dt>Locatie</dt><dd>
		  <div class="thumbnail">
		  S: <i><xsl:value-of select="gmd:southBoundLatitude/gco:Decimal"/></i> 
		  E: <i><xsl:value-of select="gmd:eastBoundLongitude/gco:Decimal"/></i> 
		  N: <i><xsl:value-of select="gmd:northBoundLatitude/gco:Decimal"/></i> 
		  W: <i><xsl:value-of select="gmd:westBoundLongitude/gco:Decimal"/></i>
		  </div>
		  </dd>
		  </dl>
		  <meta itemprop="box" content="{gmd:southBoundLatitude/gco:Decimal} {gmd:eastBoundLongitude/gco:Decimal} {gmd:northBoundLatitude/gco:Decimal} {gmd:westBoundLongitude/gco:Decimal}" />
    </span>
	</div>
		<script>
			var x1=parseFloat('<xsl:value-of select="gmd:westBoundLongitude/gco:Decimal"/>');
			var x2=parseFloat('<xsl:value-of select="gmd:eastBoundLongitude/gco:Decimal"/>');
			var y1=parseFloat('<xsl:value-of select="gmd:southBoundLatitude/gco:Decimal"/>');
			var y2=parseFloat('<xsl:value-of select="gmd:northBoundLatitude/gco:Decimal"/>');
		</script>
		<link rel="stylesheet" href="//cdn.leafletjs.com/leaflet/v0.7.7/leaflet.css"/>
		
		<script src="//cdn.leafletjs.com/leaflet/v0.7.7/leaflet.js">//
		</script>
		<script src="../../maps/script.js">//
		</script>

  </xsl:template>

    <!-- A contact is displayed with its role as header -->
  <xsl:template mode="render-field"
                match="*/gmd:lineage"
                priority="100">
	<dl>
    <dt>Beschrijving herkomst</dt>
	<dd itemprop="about">
      <xsl:value-of select="gco:CharacterString"/>
	</dd>
	</dl>
  </xsl:template>
  
     
  <xsl:template mode="render-field"
                match="*/gmd:purpose"
                priority="100">
	<dl>
    <dt>Beschrijving doel</dt>
	<dd itemprop="about">
      <xsl:value-of select="gco:CharacterString"/>
	</dd>
	</dl>
  </xsl:template>
  
    
  <xsl:template mode="render-field"
                match="*/gmd:abstract"
                priority="100">
	<dl>
    <dt>Samenvatting</dt>
	<dd itemprop="description">
      <xsl:value-of select="gco:CharacterString"/>
	</dd>
	</dl>
  </xsl:template>

  <xsl:template mode="render-field"
                match="*/gmd:MD_LegalConstraints/gmd:otherConstraints"
                priority="100">
	<dl>
    <dt>Juridische beperkingen</dt>
	<dd itemprop="license">
      <xsl:value-of select="gco:CharacterString"/>
	</dd>
	</dl>
  </xsl:template>
  
  <xsl:template mode="render-field"
                match="*/gmd:useLimitation"
                priority="100">
	<dl>
    <dt>Gebruiks beperkingen</dt>
	<dd>
      <xsl:value-of select="gco:CharacterString" />
	</dd>
	</dl>
  </xsl:template>
  
  <xsl:template mode="render-field"
                match="*/gmd:alternateTitle"
                priority="100">
	<dl>
    <dt>Alternatieve titel</dt>
	<dd itemprop="alternateName">
      <xsl:apply-templates mode="render-value" select="*/gmd:alternateTitle" />
	</dd>
	</dl>
  </xsl:template>
  
   <xsl:template mode="render-field"
                match="*/gmd:language"
                priority="200">		
	<dl>
    <dt>Taal</dt>
	<dd itemprop="inLanguage">
      <xsl:apply-templates mode="render-value" select="*/gmd:language" />
	</dd>
	</dl>
  </xsl:template>
  
  <xsl:template mode="render-field"
                match="*/srv:coupledResource"
                priority="1000">		
			<!-- skip -->
  </xsl:template>
  
  <xsl:template mode="render-field"
                match="*/srv:SV_CoupledResource"
                priority="1000">		
			<!-- skip -->
  </xsl:template>
  
  <xsl:template mode="render-field"
                match="*/srv:couplingType"
                priority="100">		
			<!-- skip -->
  </xsl:template>
  
  <xsl:template mode="render-field"
                match="*/srv:containsOperations"
                priority="100">		
			<!-- skip -->
  </xsl:template>
  
  <xsl:template mode="render-field"
                match="*/srv:SV_OperationMetadata"
                priority="100">		
			<!-- skip -->
  </xsl:template>

  <xsl:template mode="render-field"
                match="*/gmd:title"
                priority="100">		
			<!-- skip -->
  </xsl:template>
  
  <xsl:template mode="render-field"
                match="*/srv:couplingType"
                priority="100">		
			<!-- skip -->
  </xsl:template>
  
  <xsl:template mode="render-field"
                match="*/srv:containsOperations"
                priority="100">		
			<!-- skip -->
  </xsl:template>
  

    
<xsl:template mode="render-field"
                match="*/srv:operatesOn"
                priority="105">
  <div itemprop="dataset" itemscope="itemscope" itemtype="http://schema.org/Dataset">
   <meta itemprop="url" content="{$baseurl}/doc/dataset/{./@uuidref}" />
   
   <xsl:variable name="dsUUID">
   <xsl:choose>
   <xsl:when test="contains(lower-case(./@xlink:href),'id=')">
  	 <xsl:value-of select="tokenize(tokenize(lower-case(./@xlink:href),'id=')[2],'&amp;')[1]"/>
   </xsl:when>
   <xsl:otherwise>
   	<xsl:value-of select="./@uuidref"/>
   </xsl:otherwise>	
   </xsl:choose>
   </xsl:variable>

<xsl:variable name="mdTitle" select="xslUtils:getIndexField(null, $dsUUID, 'title','dut')"/>
<xsl:variable name="mdTitle2" select="xslUtils:getIndexField(null, $dsUUID, '_defaultTitle','dut')"/>


   <xsl:if test="string-length($dsUUID)>0">
     <a href="{$baseurl}/doc/dataset/{$dsUUID}" class="btn btn-sm btn-primary">Dataset in Catalogus
     <xsl:value-of select="$mdTitle"/> 2 <xsl:value-of select="$mdTitle2"/></a><br/>
   </xsl:if>
 </div>
 </xsl:template>
  
  
     <xsl:template mode="render-field"
                match="*/gmd:dateStamp"
                priority="100">		
	<dl>
    <dt>Datum</dt>
	<dd itemprop="dateModified">
      <xsl:apply-templates mode="render-value" select="*/gmd:datestamp" />
	</dd>
	</dl>
  </xsl:template>
  

  
  <!-- A contact is displayed with its role as header -->
  <xsl:template mode="render-field"
                match="*[gmd:CI_ResponsibleParty]"
                priority="100">
    <xsl:variable name="email">
	<span itemprop="email">
      <xsl:apply-templates mode="render-value"
                           select="*/gmd:contactInfo/
                                      */gmd:address/*/gmd:electronicMailAddress"/></span>
    </xsl:variable>

    <!-- Display name is <org name> - <individual name> (<position name> -->
    <xsl:variable name="displayName">
      <span itemprop="name">
	  <xsl:choose>
        <xsl:when
                test="*/gmd:organisationName and */gmd:individualName">
          <!-- Org name may be multilingual -->
          <xsl:apply-templates mode="render-value"
                               select="*/gmd:organisationName"/>
          -
          <xsl:value-of select="*/gmd:individualName"/>
		  
          <xsl:if test="*/gmd:positionName">
            (<xsl:apply-templates mode="render-value"
                                  select="*/gmd:positionName"/>)
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="*/gmd:organisationName|*/gmd:individualName"/>
        </xsl:otherwise>
      </xsl:choose>
	  </span>
    </xsl:variable>

    <div class="gn-contact col-md-4 col-sm-12" style="border:1px solid gray;float:right;border-radius:8px" >
      <h3>
        <i class="fa fa-envelope"></i>
        <xsl:apply-templates mode="render-value"
                             select="*/gmd:role/*/@codeListValue"/>
      </h3>
      <div class="row">
        <div class="col-xs-12">
          <address itemprop="author" itemscope="itemscope" itemtype="http://schema.org/Organization">
            <strong>
              <xsl:choose>
                <xsl:when test="$email!=''">
				  <meta content="{normalize-space($email)}" itemprop="email" />
                  <a href="mailto:{normalize-space($email)}"><xsl:value-of select="$displayName"/></a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$displayName"/>
                </xsl:otherwise>
              </xsl:choose>
            </strong><br/>
            <xsl:for-each select="*/gmd:contactInfo/*">
				<span itemprop="address"  itemscope="itemscope" itemtype="http://schema.org/PostalAddress">
              <xsl:for-each select="gmd:address/*/(gmd:deliveryPoint)">
				<span itemprop="streetAddress">
                <xsl:apply-templates mode="render-value" select="."/></span><br/>
              </xsl:for-each>
			  <xsl:for-each select="gmd:address/*/(gmd:city)">
                <span itemprop="addressLocality">
                <xsl:apply-templates mode="render-value" select="."/></span><br/>
              </xsl:for-each>
			  <xsl:for-each select="gmd:address/*/(gmd:administrativeArea)">
                <span itemprop="addressRegion">
                <xsl:apply-templates mode="render-value" select="."/></span><br/>
              </xsl:for-each>
			  <xsl:for-each select="gmd:address/*/(gmd:postalCode)">
                <span itemprop="postalCode">
                <xsl:apply-templates mode="render-value" select="."/></span><br/>
              </xsl:for-each>
			  <xsl:for-each select="gmd:address/*/(gmd:country)">
                <span itemprop="addressCountry">
                <xsl:apply-templates mode="render-value" select="."/></span><br/>
              </xsl:for-each>
			  </span>
            
			  <xsl:variable name="phoneNumber">
			  
			  <xsl:for-each select="gmd:phone/*/gmd:voice[normalize-space(.) != '']">
				  <xsl:if test="not(contains(gco:CharacterString,'31'))"><xsl:text>(+31)</xsl:text></xsl:if>
                  <xsl:apply-templates mode="render-value" select="."/>
              </xsl:for-each>
			  </xsl:variable>
			  <xsl:variable name="faxNumber">
              <xsl:for-each select="gmd:phone/*/gmd:facsimile[normalize-space(.) != '']">
                  <xsl:apply-templates mode="render-value" select="."/>  
              </xsl:for-each>
			  </xsl:variable>
			  
			  <xsl:variable name="CPUrl">
				  <xsl:for-each select="gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL[normalize-space(.) != '']">
				  	<xsl:if test="not(starts-with(., 'http'))">http://</xsl:if>
					  <xsl:value-of select="."/>
				  </xsl:for-each>
			  </xsl:variable>
			  <xsl:if test="$CPUrl!=''">
				   <a href="{$CPUrl}" target="_blank">
				   <i class="fa fa-link"></i> <span itemprop="url"><xsl:value-of select="$CPUrl"/></span></a>
			  </xsl:if>	
			  
			  
			  <xsl:if test="$phoneNumber!=''">
			  <span itemprop="contactPoint" itemscope="itemscope" itemtype="http://schema.org/ContactPoint">
			  <meta itemprop="contactType" content="customer support"/>	
			  
			  <xsl:if test="normalize-space(gmd:contactInstructions)!=''">
			  <span itemprop="description">
              <xsl:apply-templates mode="render-field"
                                   select="gmd:contactInstructions"/></span>				
				</xsl:if>
				
				<xsl:if test="normalize-space($phoneNumber)!=''">
				<a href="tel:{normalize-space($phoneNumber)}">
                  <i class="fa fa-phone"></i> <span  itemprop="telephone"><xsl:value-of select="$phoneNumber"/></span>
                </a><br/>
				</xsl:if>
                <xsl:if test="normalize-space($faxNumber)!=''">
					<a href="fax:{normalize-space($faxNumber)}">
					  <i class="fa fa-fax"></i> <span itemprop="faxNumber"><xsl:value-of select="$faxNumber"/></span>
					</a><br/>
				  </xsl:if>				  
			  
			  
			  
			  <xsl:if test="normalize-space(gmd:hoursOfService)!=''">
			  <span itemprop="hoursAvailable" itemscope="itemscope" itemtype="http://schema.org/OpeningHoursSpecification">	
				  <span itemprop="description">
					<xsl:apply-templates mode="render-field"
									   select="gmd:hoursOfService"/>
				  </span>
			  </span></xsl:if>	
			  
			  </span>
			  
			</xsl:if>
            </xsl:for-each>
          </address>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Metadata linkage -->
  <xsl:template mode="render-field"
                match="gmd:fileIdentifier"
                priority="100">
    <dl>
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
 
		<xsl:variable name="mdid"><xsl:apply-templates mode="render-value" select="*"/></xsl:variable>
		<xsl:value-of select="$mdid"/>
		  <meta itemprop="url" content="{$baseurl}/doc/dataset/{$mdid}" />
		  <meta content="http://www.nationaalgeoregister.nl/geonetwork/resource/{$mdid}" itemprop="isBasedOnUrl"/>
		<xsl:apply-templates mode="render-value" select="@*"/>
        <br/>
		<a class="btn btn-default" href="http://www.nationaalgeoregister.nl/geonetwork/resource/{$mdid}">
          <span>Originele URL</span>
        </a>
		<a class="btn btn-default" href="{$baseurl}/srv/dut/xml.metadata.get?uuid={$mdid}">
          <span>Metadata In XML</span>
        </a> <a class="btn btn-default" href="{$baseurl}/srv/dut/rdf.metadata.get?uuid={$mdid}">
          <span>Metadata In RDF/XML</span>
        </a>
        
        <!-- these uuid's are hardcoded links to aan and adressen metadata-->
        <xsl:if test="$mdid='b105faf5-83f7-4fd9-8a5a-7b804fabc0b6' or $mdid='aef01552-615d-4173-924d-4dbbde34b515' or $mdid='4fa03182-df71-4c39-87da-e7d5c0b82d88' or $mdid='02f0a3f1-f918-4e3c-b150-a7265ca8ee4a' ">
			<meta content="http://www.ldproxy.net/aan/aan" itemprop="contentUrl"/>
        	<br/><a href="http://www.ldproxy.net/aan/aan" target="_blank" class="btn btn-success">Browse data</a>		
		</xsl:if>
		
		<xsl:if test="$mdid='76091be7-358a-4a44-8182-b4139c96c6a4' or $mdid='3a97fbe4-2b0d-4e9c-9644-276883400dd7' or $mdid='4074b3c3-ca85-45ad-bc0d-b5fca8540z0b' or $mdid='06b6c650-cdb1-11dd-ad8b-0800200c9a77' ">
			<meta content="http://www.ldproxy.net/bag/inspireadressen" itemprop="contentUrl"/>
        	<br/><a href="http://www.ldproxy.net/bag/inspireadressen" target="_blank" class="btn btn-success">Browse data</a>		
		</xsl:if>
      </dd>
    </dl>
    
    
		
  </xsl:template>

  <!-- Linkage -->
  <xsl:template mode="render-field"
                match="*[gmd:CI_OnlineResource and */gmd:linkage/gmd:URL != '']"
                priority="100">
    <dl class="gn-link" itemprop="distribution" itemscope="itemscope" itemtype="http://schema.org/DataDownload" >
      <dt>
	  <xsl:choose>
		  <xsl:when test="contains(*/gmd:protocol,'WMS') or contains(*/gmd:protocol,'WMTS') or contains(*/gmd:protocol,'SOS') or contains(*/gmd:protocol,'WCS')">
			View service information
		  </xsl:when>
		  <xsl:otherwise>Download</xsl:otherwise>
	  </xsl:choose>
        
      </dt>
      <dd>
        <xsl:variable name="linkDescription">
          <xsl:apply-templates mode="render-value" select="*/gmd:description"/>
        </xsl:variable>

		<xsl:variable name="dlUrl">
		<xsl:if test="not(starts-with(*/gmd:linkage/gmd:URL, 'http'))">http://</xsl:if>
		<xsl:choose>
		  <xsl:when test="contains(*/gmd:protocol,'WMS')">
				<xsl:value-of select="*/gmd:linkage/gmd:URL"/>
				<xsl:if test="not(contains(*/gmd:linkage/gmd:URL,'?'))"><xsl:text>?</xsl:text></xsl:if>
				<xsl:if test="not(contains(*/gmd:linkage/gmd:URL,'request='))">
					<xsl:text>&amp;request=GetCapabilities&amp;service=WMS&amp;version=1.3.0</xsl:text>
				</xsl:if>
		  </xsl:when>
		  <xsl:when test="contains(*/gmd:protocol,'WFS')">
				<xsl:value-of select="*/gmd:linkage/gmd:URL"/>
				<xsl:if test="not(contains(*/gmd:linkage/gmd:URL,'?'))"><xsl:text>?</xsl:text></xsl:if>
				<xsl:if test="not(contains(*/gmd:linkage/gmd:URL,'request='))">
					<xsl:text>&amp;service=WFS&amp;version=2.0.0&amp;request=GetFeature&amp;typename=</xsl:text>
					<xsl:value-of select="normalize-space(*/gmd:name)" />
				</xsl:if>
		  </xsl:when>
		  <xsl:when test="contains(*/gmd:protocol,'WMTS')">
			<xsl:value-of select="*/gmd:linkage/gmd:URL"/>
				<xsl:if test="not(contains(*/gmd:linkage/gmd:URL,'?'))"><xsl:text>?</xsl:text></xsl:if>
				<xsl:if test="not(contains(*/gmd:linkage/gmd:URL,'request='))">
					<xsl:text>&amp;request=GetCapabilities&amp;service=WMTS&amp;version=1.0.0</xsl:text>
				</xsl:if>
		  </xsl:when>
		  <xsl:when test="contains(*/gmd:protocol,'SOS')">
			<xsl:value-of select="*/gmd:linkage/gmd:URL"/>
				<xsl:if test="not(contains(*/gmd:linkage/gmd:URL,'?'))"><xsl:text>?</xsl:text></xsl:if>
				<xsl:if test="not(contains(*/gmd:linkage/gmd:URL,'request='))">
					<xsl:text>&amp;request=GetCapabilities&amp;service=SOS&amp;version=2.0</xsl:text>
				</xsl:if>
		  </xsl:when>
		  <xsl:when test="contains(*/gmd:protocol,'WCS')">
			<xsl:value-of select="*/gmd:linkage/gmd:URL"/>
				<xsl:if test="not(contains(*/gmd:linkage/gmd:URL,'?'))"><xsl:text>?</xsl:text></xsl:if>
				<xsl:if test="not(contains(*/gmd:linkage/gmd:URL,'request='))">
					<xsl:text>&amp;request=GetCapabilities&amp;service=WCS&amp;version=2.0.1</xsl:text>
				</xsl:if>
		  </xsl:when>
		  <xsl:otherwise><xsl:value-of select="*/gmd:linkage/gmd:URL"/></xsl:otherwise>
		  </xsl:choose>
		</xsl:variable>
		
		
		
		<meta content="{$dlUrl}" itemprop="contentUrl"/>
        <a href="{$dlUrl}" target="_blank" class="btn btn-success">Download data</a>
        
      </dd>
    </dl>
	<xsl:if test="contains(*/gmd:protocol,'WMS') and */gmd:name != ''">
	<script>
	// Add each wms layer using L.tileLayer.wms
	L.tileLayer.wms('<xsl:value-of select="normalize-space(*/gmd:linkage/gmd:URL)"/>', {
    format: 'image/png',
    transparent: true,
    layers: '<xsl:value-of select="normalize-space(*/gmd:name)"/>'
	}).addTo(map).setOpacity(.75);
	</script>
	</xsl:if>
	
  </xsl:template>

  <!-- Identifier -->
  <xsl:template mode="render-field"
                match="*[(gmd:RS_Identifier or gmd:MD_Identifier) and
                  */gmd:code/gco:CharacterString != '']"
                priority="100">
    <dl class="gn-code">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>

        <xsl:if test="*/gmd:codeSpace">
          <xsl:apply-templates mode="render-value"
                               select="*/gmd:codeSpace"/>
          /
        </xsl:if>
        <xsl:apply-templates mode="render-value"
                             select="*/gmd:code"/>
        <xsl:if test="*/gmd:version">
          / <xsl:apply-templates mode="render-value"
                                 select="*/gmd:version"/>
        </xsl:if>
        <p>
          <xsl:apply-templates mode="render-field"
                               select="*/gmd:authority"/>
        </p>
      </dd>
    </dl>
  </xsl:template>


  <!-- Display thesaurus name and the list of keywords -->
  <xsl:template mode="render-field"
                match="gmd:descriptiveKeywords[*/gmd:thesaurusName/gmd:CI_Citation/gmd:title]"
                priority="100">
    <dl class="gn-keyword">
      <dt>
        <xsl:apply-templates mode="render-value"
                             select="*/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*"/>

        <xsl:if test="*/gmd:type/*[@codeListValue != '']">
          (<xsl:apply-templates mode="render-value"
                                select="*/gmd:type/*/@codeListValue"/>)
        </xsl:if>
      </dt>
      <dd>
        
            <span itemprop="keywords">
              <xsl:apply-templates mode="render-value"
                                   select="*/gmd:keyword/*"/></span>
  
      </dd>
    </dl>
  </xsl:template>


  <xsl:template mode="render-field"
                match="gmd:descriptiveKeywords[not(*/gmd:thesaurusName/gmd:CI_Citation/gmd:title)]"
                priority="100">
    <dl class="gn-keyword">
      <dt>
        <xsl:value-of select="$schemaStrings/noThesaurusName"/>
        <xsl:if test="*/gmd:type/*[@codeListValue != '']">
          (<xsl:apply-templates mode="render-value"
                                select="*/gmd:type/*/@codeListValue"/>)
        </xsl:if>
      </dt>
      <dd>
        
            <span itemprop="keywords">
              <xsl:apply-templates mode="render-value"
                                   select="*/gmd:keyword/*"/>
            </span>
          
      </dd>
    </dl>
  </xsl:template>

  <!-- Display all graphic overviews in one block -->
  <xsl:template mode="render-field"
                match="gmd:graphicOverview[1]"
                priority="100">
    <dl>
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <ul>
          <xsl:for-each select="parent::node()/gmd:graphicOverview">
            <xsl:variable name="label">
              <xsl:apply-templates mode="localised"
                                   select="gmd:MD_BrowseGraphic/gmd:fileDescription"/>
            </xsl:variable>
            
              <img src="{gmd:MD_BrowseGraphic/gmd:fileName/*}"
                   alt="{$label}" style="max-height:150px;"
				   itemprop="thumbnailUrl"
                   class="img-thumbnail"/>
           
          </xsl:for-each>
        </ul>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template mode="render-field"
                match="gmd:graphicOverview[position() > 1]"
                priority="100"/>


  <xsl:template mode="render-field"
                match="gmd:distributionFormat[1]"
                priority="100">
    <dl class="gn-format">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <ul>
          <xsl:for-each select="parent::node()/gmd:distributionFormat">
            <li><span itemprop="fileFormat">
              <xsl:apply-templates mode="render-value"
                                   select="*/gmd:name"/></span>
              (<xsl:apply-templates mode="render-value"
                                    select="*/gmd:version"/>)
              <p>
                <xsl:apply-templates mode="render-field"
                                     select="*/(gmd:amendmentNumber|gmd:specification|
                              gmd:fileDecompressionTechnique|gmd:formatDistributor)"/>
              </p>
            </li>
          </xsl:for-each>
        </ul>
      </dd>
    </dl>
  </xsl:template>


  <xsl:template mode="render-field"
                match="gmd:distributionFormat[position() > 1]"
                priority="100"/>

  <!-- Date -->
  <xsl:template mode="render-field"
                match="gmd:date"
                priority="100">
    <dl class="gn-date">
      <dt>

        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
		<xsl:if test="*/gmd:dateType/*/@codeListValue!=''">(<xsl:value-of select="*/gmd:dateType/*/@codeListValue"/>)</xsl:if>
      </dt>
	  <xsl:variable name="dt">
	  <xsl:choose>
	  <xsl:when test="*/gmd:dateType/*/@codeListValue='creation'"><xsl:text>dateCreated</xsl:text></xsl:when>
	  <xsl:when test="*/gmd:dateType/*/@codeListValue='publication'"><xsl:text>datePublished</xsl:text></xsl:when>
	  <xsl:when test="*/gmd:dateType/*/@codeListValue='modification'"><xsl:text>dateModified</xsl:text></xsl:when>
	  </xsl:choose>
	  </xsl:variable> 
      <dd>
	  <i>
	  <span itemprop="{$dt}">
        <xsl:apply-templates mode="render-value" select="*/gmd:date/*"/>
	  </span>
      </i>
	  </dd>
    </dl>
  </xsl:template>


  <!-- Enumeration -->
  <xsl:template mode="render-field"
                match="gmd:topicCategory[1]|gmd:obligation[1]|gmd:pointInPixel[1]"
                priority="100">
    <dl class="gn-date">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
          <xsl:for-each select="parent::node()/(gmd:topicCategory|gmd:obligation|gmd:pointInPixel)">
              <xsl:apply-templates mode="render-value"
                                   select="*"/>
          </xsl:for-each>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template mode="render-field"
                match="gmd:topicCategory[position() > 1]|
                        gmd:obligation[position() > 1]|
                        gmd:pointInPixel[position() > 1]"
                priority="100"/>


  <!-- Link to other metadata records -->
  <xsl:template mode="render-field"
                match="*[@uuidref]"
                priority="100">
    <xsl:variable name="nodeName" select="name()"/>

    <!-- Only render the first element of this kind and render a list of
    following siblings. -->
    <xsl:variable name="isFirstOfItsKind"
                  select="count(preceding-sibling::node()[name() = $nodeName]) = 0"/>
    <xsl:if test="$isFirstOfItsKind">
      <dl class="gn-md-associated-resources">
        <dt>
          <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
        </dt>
        <dd>
          <ul>
            <xsl:for-each select="parent::node()/*[name() = $nodeName]">
              <li><a href="#uuid={@uuidref}">
                <i class="fa fa-link"></i>
                <xsl:value-of select="gn-fn-render:getMetadataTitle(@uuidref, $language)"/>
              </a></li>
            </xsl:for-each>
          </ul>
        </dd>
      </dl>
    </xsl:if>
  </xsl:template>

  <!-- Traverse the tree -->
  <xsl:template mode="render-field"
                match="*">
    <xsl:apply-templates mode="render-field"/>
  </xsl:template>

  <!-- ########################## -->
  <!-- Render values for text ... -->
  <xsl:template mode="render-value"
                match="gco:CharacterString|gco:Integer|gco:Decimal|
       gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|gco:Angle|gmx:FileName|
       gco:Scale|gco:Record|gco:RecordType|gmx:MimeFileType|gmd:URL|
       gco:LocalName|gml:beginPosition|gml:endPosition">

    <xsl:choose>
      <xsl:when test="contains(., 'http')">
        <!-- Replace hyperlink in text by an hyperlink -->
        <xsl:variable name="textWithLinks"
                      select="replace(., '([a-z][\w-]+:/{1,3}[^\s()&gt;&lt;]+[^\s`!()\[\]{};:'&apos;&quot;.,&gt;&lt;?«»“”‘’])',
                                    '&lt;a href=''$1''&gt;$1&lt;/a&gt;')"/>

        <xsl:if test="$textWithLinks != ''">
          <xsl:copy-of select="saxon:parse(
                          concat('&lt;p&gt;',
                          replace($textWithLinks, '&amp;', '&amp;amp;'),
                          '&lt;/p&gt;'))"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gmd:PT_FreeText">
    <xsl:apply-templates mode="localised" select="../node()">
      <xsl:with-param name="langId" select="$language"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- ... URL -->
  <xsl:template mode="render-value"
                match="gmd:URL">
    
    <xsl:variable name="myURL">
    <xsl:if test="not(starts-with(., 'http'))">http://</xsl:if>
    <xsl:value-of select="."/>
    </xsl:variable>            
                
    <a href="{$myURL}" target="_blank"><xsl:value-of select="$myURL"/></a>
  </xsl:template>

  <!-- ... Dates - formatting is made on the client side by the directive  -->
  
  <xsl:template mode="render-value"
                match="gco:Date|gco:DateTime">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- ... Codelists -->
  <xsl:template mode="render-value"
                match="@codeListValue">
    <xsl:variable name="id" select="."/>
    <xsl:variable name="codelistTranslation"
                  select="tr:codelist-value-label(
                            tr:create($schema),
                            parent::node()/local-name(), $id)"/>
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc"
                      select="tr:codelist-value-desc(
                            tr:create($schema),
                            parent::node()/local-name(), $id)"/>
        <span title="{$codelistDesc}"><xsl:value-of select="$codelistTranslation"/></span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Enumeration -->
  <xsl:template mode="render-value"
                match="gmd:MD_TopicCategoryCode|
                        gmd:MD_ObligationCode|
                        gmd:MD_PixelOrientationCode">
    <xsl:variable name="id" select="."/>
    <xsl:variable name="codelistTranslation"
                  select="tr:codelist-value-label(
                            tr:create($schema),
                            local-name(), $id)"/>
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc"
                      select="tr:codelist-value-desc(
                            tr:create($schema),
                            local-name(), $id)"/>
        <span title="{$codelistDesc}" itemprop="keywords"><xsl:value-of select="$codelistTranslation"/></span>
      </xsl:when>
      <xsl:otherwise>
        <span itemprop="keywords"><xsl:value-of select="$id"/></span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="render-value"
                match="@gco:nilReason[. = 'withheld']"
                priority="100">
    <i class="fa fa-lock text-warning" title="{{{{'withheld' | translate}}}}"></i>
  </xsl:template>
  <xsl:template mode="render-value"
                match="@*"/>
   
				
	
					
  <!-- Starting point -->
  <xsl:template match="/" priority="100">
  
  <html>
  <head>
  <title><xsl:apply-templates mode="getMetadataTitle" select="$metadata"/></title>
  <xsl:variable name="abs"><xsl:apply-templates mode="getMetadataAbstract" select="$metadata"/></xsl:variable>
  <meta name="description" content="{normalize-space($abs)}"/>
  <link rel="alternate" hreflang="nl" href="http://opendatacat.net/" />
  <link href="//getbootstrap.com/dist/css/bootstrap.min.css" rel="stylesheet"/> 
  <style>
	.toggler,.view-outline,.summary-links-associated-link { display:none }
	.coord { float:left;width:25%; padding:2px; padding: 3px; }
	.extent img { clear:both; padding: 5px; }
	header { padding-top:50px; }
  </style>
  </head>
  
	<body>
     
	
	
	<nav class="navbar navbar-default" style="margin-bottom:0px;">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="{$baseurl}/srv/dut/catalog.search">Opendatacat</a>
        </div>
        <div id="navbar" class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li><a href="{$baseurl}/srv/dut/catalog.search#/search">Zoeken</a></li>
			<li><a href="{$baseurl}/srv/dut/catalog.search#/map">Kaart</a></li>
            <li><a href="http://www.geonovum.nl/onderwerp-artikel/testbed-locatie-data-het-web" target="_top">Over</a></li>
            
          </ul>
        </div>
      </div>
    </nav>
	<div class="row"><div class="col-sm-12">
	<div id="map" class="hidden-xs" style="width:100%;height:250px;background-color:#ddd;border:1px solid #999;">
	<br/>
	</div></div></div>
	
	
    <div class="container gn-metadata-view">


<xsl:variable name="oType" select="$metadata/gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"/>

<xsl:variable name="schemaType">
<xsl:choose>
<xsl:when test="$oType='dataset'">http://schema.org/Dataset</xsl:when>
<xsl:when test="$oType='series'">http://schema.org/DataCatalog</xsl:when>
<xsl:when test="$oType='service'">http://schema.org/DataCatalog</xsl:when>
<xsl:when test="$oType='application'">http://schema.org/SoftwareApplication</xsl:when>
<xsl:when test="$oType='collectionHardware'">http://logd.tw.rpi.edu/web_observatory_tool</xsl:when>
<xsl:when test="$oType='nonGeographicDataset'">http://schema.org/Dataset</xsl:when>
<xsl:when test="$oType='dimensionGroup'">http://schema.org/Dataset</xsl:when>
<xsl:when test="$oType='featureType'">http://schema.org/Dataset</xsl:when>
<xsl:when test="$oType='model'">http://schema.org/APIReference</xsl:when>
<xsl:when test="$oType='tile'">http://schema.org/Dataset</xsl:when>
<xsl:when test="$oType='fieldSession'">http://logd.tw.rpi.edu/web_observatory_project</xsl:when>
<xsl:when test="$oType='collectionSession'">http://logd.tw.rpi.edu/web_observatory_project</xsl:when>
<xsl:otherwise>http://schema.org/Thing</xsl:otherwise>
</xsl:choose>
</xsl:variable>


      <article id="{$metadataUuid}" itemscope="itemscope" itemtype="{$schemaType}">
        <header>
          <h1 itemprop="name" ><xsl:apply-templates mode="getMetadataTitle" select="$metadata"/></h1>
        </header>
        <xsl:apply-templates mode="render-view" select="$viewConfig/*"/>
        
        <footer>

        </footer>
      </article>
    </div>

<script>
  (function(i,s,o,g,r,a,m) { i['GoogleAnalyticsObject']=r;i[r]=i[r]||function() {
  (i[r].q=i[r].q||[]).push(arguments) } ,i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  } )(window,document,'script','//www.google-analytics.com/analytics.js','ga');
  ga('create', 'UA-71094958-1', 'auto');
  ga('send', 'pageview');
</script>
	</body>
</html>
  </xsl:template>					
					
							
</xsl:stylesheet>
