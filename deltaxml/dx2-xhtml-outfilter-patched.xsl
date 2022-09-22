<?xml version="1.0" encoding="iso-8859-1"?>
<!-- Copyright (c) 2003-2010 DeltaXML Ltd. All rights reserved -->
<!-- $Id$ -->
<!--
    This stylesheet takes an XHTML delta file, i.e. the result of
    comparing two XHTML files, and generates another standard XHTML
    file which shows the differences.

    This is an example only and may not work correctly for all input files.

    Based on XHTML Transitional.

    By changing this stylesheet, you can flag changes to the user in
    any way you wish. For example, if you do not want deleted images
    displayed then change the template that deals with deleted images.
  -->

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:deltaxml="http://www.deltaxml.com/ns/well-formed-delta-v1"
                xmlns:dxa="http://www.deltaxml.com/ns/non-namespaced-attribute"
                xmlns:dxx="http://www.deltaxml.com/ns/xml-namespaced-attribute"
                exclude-result-prefixes="deltaxml dxa dxx">

  <!-- Output can be pretty-printed -->
  <!-- You could also add instructions for adding DOCTYPE info
       such as systemIds or publicIds here, the XML dec is not output
       as this has a tendency to put certain rendering engines such
       as IE into quirks-mode, not 'standards-mode'
       Also consider using non-standard xhtml output methods,
       such as saxon:xhtml depending upon pipeline/tooling -->

  <xsl:output method="xhtml" indent="no" omit-xml-declaration="yes" />

  <xsl:param name="includeButtons" select="'yes'"/>
  
  <xsl:param name="old-color" select="'#FF5555'"/>
  <xsl:param name="new-color" select="'#90EE90'"/>
  
  <xsl:param name="old-style" select="concat('background:', $old-color)"/>
  <xsl:param name="new-style" select="concat('background:', $new-color)"/>
  <xsl:param name="old-img-style" select="'border: 2px solid red'"/>
  <xsl:param name="new-img-style" select="'border: 2px solid green'"/>
  
  <!-- There are basically four modes:
    - process unchanged data by copying to output
    - process added data by by copying to output, with text spanned using the
      deltaxml-new CSS class.
    - process deleted data by by copying to output, with text spanned using the
      deltaxml-old CSS class.
    - process modified data, treating each child to see which of the above apply

    The deltaxml-new and deltaxml-old CSS classes can be configured to
    style the changed text as desired.  Please see the head modification
    template below. 

    In paragraph and similar types of element we process the DeltaXML
    elements and output both the old and new data.  In some other elements
    this may result in incorrect data (eg. in the <style> element.  In these
    cases we have decided to simply use the data form the new file.  If this
    approach does not meet your needs please modify this script as
    appropriate.
  -->

  <!-- process any modified node (we do not need to check for mods as this applies to
  all nodes -->
  <xsl:template match="*">
   <xsl:variable name="element-name">
    <xsl:call-template name="find-element-name">
      <xsl:with-param name="element" select="."/>
    </xsl:call-template>
   </xsl:variable>
   <xsl:element name="{$element-name}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="node()"/>
   </xsl:element>
  </xsl:template>

  <!-- The head modification template -->
  <xsl:template match="xhtml:head">
    <xsl:element name="head" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*, deltaxml:attributes"/>
      <xsl:comment>Generated by the DeltaXML.com xhtml-outfilter.xsl</xsl:comment>
      <xsl:comment>Using XSL Processor: <xsl:value-of select="system-property('xsl:vendor')"/></xsl:comment>
      <xsl:apply-templates select="node() except deltaxml:attributes"/>
      <xsl:if test="$includeButtons='yes'">
        <xsl:element name="style" namespace="http://www.w3.org/1999/xhtml">
          <xsl:attribute name="type">text/css</xsl:attribute>
          body { margin-top: 50px }
          a.button { background: #DDD; border: 2px outset black; padding: 2px; margin: 2px; font-family: sans-serif; font-size: small;}
          a.button:hover { cursor:pointer; }
          a.button:active { border-style: inset; }
        </xsl:element>
        <xsl:element name="script" namespace="http://www.w3.org/1999/xhtml">
          <xsl:attribute name="type">text/javascript</xsl:attribute>
            function view(doc) {
              var allSpans=document.getElementsByTagName("*");
              if(doc=="old") {
                for(i=0;i!=allSpans.length;i++) {
                  var displayType= "inline";
                  if (allSpans[i].localName == "tr") {
                    displayType= "table-row";
                  } else if (allSpans[i].localName == "li") {
                    displayType= "list-item";
                  }
                  var name=allSpans[i].className;
                  if(name=="deltaxml-new" || name=="deltaxml-new-img" || name=="deltaxml-new-format" || name=="add_version" || name=="modify_version") {
                    allSpans[i].style.display="none";
                  } else if (name=="deltaxml-old" || name=="deltaxml-old-img" || name=="deltaxml-old-format" || name=="delete_version") {
                    allSpans[i].style.display= displayType;
                    allSpans[i].style.background="#FFF";
                    //need to take border off images
                    var allImgs=allSpans[i].getElementsByTagName("img");
                    for(j=0;j!=allImgs.length;j++) {
                      allImgs[j].style.border="none";
                    }
                  }
                }
              } else if(doc=="new") {
                for(i=0;i!=allSpans.length;i++) {
                  var displayType= "inline";
                  if (allSpans[i].localName == "tr") {
                    displayType= "table-row";
                  } else if (allSpans[i].localName == "li") {
                    displayType= "list-item";
                  }
                  var name=allSpans[i].className;
                  if(name=="deltaxml-new" || name=="deltaxml-new-img" || name=="deltaxml-new-format" || name=="add_version") {
                    allSpans[i].style.display= displayType;
                    allSpans[i].style.background="#FFF";
                    //need to take border off images
                    var allImgs=allSpans[i].getElementsByTagName("img");
                    for(j=0;j!=allImgs.length;j++) {
                      allImgs[j].style.border="none";
                    }
                  } else if (name=="deltaxml-old" || name=="deltaxml-old-img" || name=="deltaxml-old-format" || name=="delete_version" || name=="modify_version") {
                    allSpans[i].style.display="none";
                   }
                }
              } else if(doc=="both") {
                for(i=0;i!=allSpans.length;i++) {
                  var displayType= "inline";
                  if (allSpans[i].localName == "tr") {
                    displayType= "table-row";
                  } else if (allSpans[i].localName == "li") {
                    displayType= "list-item";
                  }
                  var name=allSpans[i].className;
                  if(name=="deltaxml-new" || name=="deltaxml-new-format" || name=="deltaxml-new-img") {
                    allSpans[i].style.display= displayType;
                    allSpans[i].style.background="<xsl:value-of select="$new-color"/>";
                    //need to add border to images
                    var allImgs=allSpans[i].getElementsByTagName("img");
                    for(j=0;j!=allImgs.length;j++) {
                      allImgs[j].style.border="2px solid green";
                    }
                  } else if(name=="deltaxml-old" || name=="deltaxml-old-format" || name=="deltaxml-old-img") {
                    allSpans[i].style.display= displayType;
                    allSpans[i].style.background="<xsl:value-of select="$old-color"/>";
                    //need to add border to images
                    var allImgs=allSpans[i].getElementsByTagName("img");
                    for(j=0;j!=allImgs.length;j++) {
                      allImgs[j].style.border="2px solid red";
                    }
                  } else if (name=="add_version" || name=="delete_version") {
                    allSpans[i].style.display="none";
                  } else if (name=="modify_version") {
                    allSpans[i].style.display= displayType;
                  }
                }
              }
            }
  
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>
  
  <!-- add buttons to the body -->
  <xsl:template match="xhtml:body">
    <xsl:element name="body" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*, deltaxml:attributes"/>
      
      <xsl:if test="$includeButtons='yes'">
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
          <xsl:attribute name="style">position:fixed; clear:both; top:0px</xsl:attribute>
          <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
            <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
              <xsl:attribute name="class">button</xsl:attribute>
              <xsl:attribute name="onclick">view('old')</xsl:attribute>
              View Old
            </xsl:element>
            <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
              <xsl:attribute name="class">button</xsl:attribute>
              <xsl:attribute name="onclick">view('new')</xsl:attribute>
              View New
            </xsl:element>
            <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
              <xsl:attribute name="class">button</xsl:attribute>
              <xsl:attribute name="onclick">view('both')</xsl:attribute>
              View Both
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
      <xsl:apply-templates select="* except deltaxml:attributes"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="deltaxml:textGroup">
   <xsl:if test="deltaxml:text[@deltaxml:deltaV2='A']">
    <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="class" namespace="">deltaxml-old</xsl:attribute>
      <xsl:attribute name="style" namespace=""><xsl:value-of select="$old-style"/></xsl:attribute>
     <xsl:value-of select="deltaxml:text[@deltaxml:deltaV2='A']/text()"/>
    </xsl:element>
   </xsl:if>
   <xsl:if test="deltaxml:text[@deltaxml:deltaV2='B']">
    <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="class" namespace="">deltaxml-new</xsl:attribute>
      <xsl:attribute name="style" namespace=""><xsl:value-of select="$new-style"/></xsl:attribute>
     <xsl:value-of select="deltaxml:text[@deltaxml:deltaV2='B']/text()"/>
    </xsl:element>
   </xsl:if>
  </xsl:template>

  <xsl:template match="deltaxml:textGroup" mode="added-data">
    <xsl:if test="deltaxml:text[@deltaxml:deltaV2='B']">
      <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
        <xsl:attribute name="class" namespace="">deltaxml-new</xsl:attribute>
        <xsl:attribute name="style" namespace=""><xsl:value-of select="$new-style"/></xsl:attribute>
        <xsl:value-of select="deltaxml:text[@deltaxml:deltaV2='B']/text()"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="deltaxml:textGroup" mode="deleted-data">
    <xsl:if test="deltaxml:text[@deltaxml:deltaV2='A']">
      <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
        <xsl:attribute name="class" namespace="">deltaxml-old</xsl:attribute>
        <xsl:attribute name="style" namespace=""><xsl:value-of select="$old-style"/></xsl:attribute>
        <xsl:value-of select="deltaxml:text[@deltaxml:deltaV2='A']/text()"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <!-- process any added node -->
  <xsl:template match="*[@deltaxml:deltaV2='B'][not(self::deltaxml:textGroup)]">
   <xsl:apply-templates mode="added-data" select="."/>
  </xsl:template>
  
  <xsl:template match="*" mode="added-data">
   <xsl:variable name="element-name">
    <xsl:call-template name="find-element-name">
      <xsl:with-param name="element" select="."/>
    </xsl:call-template>
   </xsl:variable>
   <xsl:element name="{$element-name}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="@*" mode="added-data"/>
    <xsl:apply-templates select="node()" mode="added-data"/>
   </xsl:element>
  </xsl:template>

  <xsl:template match="text()" mode="added-data">
   <xsl:if test="string-length(.)>0">
    <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="class" namespace="">deltaxml-new</xsl:attribute>
      <xsl:attribute name="style" namespace=""><xsl:value-of select="$new-style"/></xsl:attribute>
     <xsl:value-of select="."/>
    </xsl:element>
   </xsl:if>
  </xsl:template>
  
  <xsl:template match="*" mode="new-format">
    <xsl:variable name="element-name">
      <xsl:call-template name="find-element-name">
        <xsl:with-param name="element" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:element name="{$element-name}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*" mode="new-format"/>
      <xsl:apply-templates select="node()" mode="new-format"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="text()" mode="new-format">
    <xsl:if test="string-length(.)>0">
      <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
        <xsl:attribute name="class" namespace="">deltaxml-new-format</xsl:attribute>
        <xsl:attribute name="style" namespace=""><xsl:value-of select="$new-style"/></xsl:attribute>
        <xsl:value-of select="."/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*" mode="old-format">
    <xsl:variable name="element-name">
      <xsl:call-template name="find-element-name">
        <xsl:with-param name="element" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:element name="{$element-name}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*" mode="old-format"/>
      <xsl:apply-templates select="node()" mode="old-format"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="text()" mode="old-format">
    <xsl:if test="string-length(.)>0">
      <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
        <xsl:attribute name="class" namespace="">deltaxml-old-format</xsl:attribute>
        <xsl:attribute name="style" namespace=""><xsl:value-of select="$old-style"/></xsl:attribute>
        <xsl:value-of select="."/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
  <!-- Write out attributes -->
  <xsl:template match="@*" mode="added-data">
    <xsl:copy-of select="."/>
  </xsl:template>
  <xsl:template match="@*" mode="deleted-data">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="@*" mode="new-format">
    <xsl:choose>
      <xsl:when test="namespace-uri(.)!='http://www.deltaxml.com/ns/well-formed-delta-v1'">
        <xsl:copy-of select="."/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="@*" mode="old-format">
    <xsl:choose>
      <xsl:when test="namespace-uri(.)!='http://www.deltaxml.com/ns/well-formed-delta-v1'">
        <xsl:copy-of select="."/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Deal with any elements added where formatted text is not allowed -->
  
  <!-- For these elements, output changes delimited by [] or similar -->
  <xsl:template match="xhtml:textarea | xhtml:title | xhtml:option" mode="added-data">
   <xsl:variable name="element-name">
    <xsl:call-template name="find-element-name">
      <xsl:with-param name="element" select="."/>
    </xsl:call-template>
   </xsl:variable>
   <xsl:element name="{$element-name}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="@*"/>
    <xsl:text>+[[</xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:text>]]+</xsl:text>
   </xsl:element>
  </xsl:template>

  <!-- For these elements, we output the new data and ignore old so that we
    ensure that the data is valid. So old data here is lost -->
  <xsl:template match="xhtml:script | xhtml:style " mode="added-data">
   <xsl:variable name="element-name">
    <xsl:call-template name="find-element-name">
      <xsl:with-param name="element" select="."/>
    </xsl:call-template>
   </xsl:variable>
   <xsl:element name="{$element-name}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="@*"/>
     <xsl:value-of select="text()"/>
   </xsl:element>
  </xsl:template>
  
  <!-- process any deleted node -->
  <xsl:template match="*[@deltaxml:deltaV2='A'][not(self::deltaxml:textGroup)]">
   <xsl:apply-templates mode="deleted-data" select="."/>
  </xsl:template>

  <xsl:template match="*" mode="deleted-data">
   <xsl:variable name="element-name">
    <xsl:call-template name="find-element-name">
      <xsl:with-param name="element" select="."/>
    </xsl:call-template>
   </xsl:variable>
   <xsl:element name="{$element-name}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="@*"/>
     <xsl:apply-templates select="node()" mode="deleted-data"/>
   </xsl:element>
  </xsl:template>

  <xsl:template match="text()" mode="deleted-data">
   <xsl:if test="string-length(.)>0">
   <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
     <xsl:attribute name="class" namespace="">deltaxml-old</xsl:attribute>
     <xsl:attribute name="style" namespace=""><xsl:value-of select="$old-style"/></xsl:attribute>
    <xsl:value-of select="."/>
   </xsl:element>
   </xsl:if>
  </xsl:template>

  <!-- For deleted images, just note they are deleted -->
  <xsl:template match="xhtml:img" mode="deleted-data">
    <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="class">deltaxml-old-img</xsl:attribute>
      <xsl:element name="img" namespace="http://www.w3.org/1999/xhtml">
        <xsl:attribute name="style" namespace=""><xsl:value-of select="$old-img-style"/></xsl:attribute>
        <xsl:apply-templates select="@*"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="xhtml:img" mode="added-data">
    <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="class">deltaxml-new-img</xsl:attribute>
      <xsl:element name="img" namespace="http://www.w3.org/1999/xhtml">
        <xsl:attribute name="style" namespace=""><xsl:value-of select="$new-img-style"/></xsl:attribute>
        <xsl:apply-templates select="@*"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <!-- Deal with any elements deleted where formatted text is not allowed -->
  
  <!-- For these elements, output changes delimited by [] or similar -->
  <xsl:template match="xhtml:textarea | xhtml:title | xhtml:option" mode="deleted-data">
   <xsl:variable name="element-name">
    <xsl:call-template name="find-element-name">
      <xsl:with-param name="element" select="."/>
    </xsl:call-template>
   </xsl:variable>
   <xsl:element name="{$element-name}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="@*"/>
    <xsl:text>-[[</xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:text>]]-</xsl:text>
   </xsl:element>
  </xsl:template>

  <!-- For these elements, we output the new data and ignore old so that we
    ensure that the data is valid. So old data here is lost -->
  <xsl:template match="xhtml:script | xhtml:style | xhtml:area
                     | xhtml:base | xhtml:basefont | xhtml:br | xhtml:hr | xhtml:input
                     | xhtml:isindex | xhtml:link | xhtml:meta | xhtml:param " mode="deleted-data">
  </xsl:template>


  <!-- Deal with any elements where formatted text is not allowed -->
  
  <!-- For these elements, output changes delimited by [] or similar -->
  <xsl:template match="xhtml:textarea | xhtml:title | xhtml:option">
   <xsl:variable name="element-name">
    <xsl:call-template name="find-element-name">
      <xsl:with-param name="element" select="."/>
    </xsl:call-template>
   </xsl:variable>
   <xsl:element name="{$element-name}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="@*"/>
     <xsl:apply-templates select="node()" mode="delimited-text-only-data"/>
   </xsl:element>
  </xsl:template>

  <xsl:template match="text()" mode="delimited-text-only-data">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="deltaxml:textGroup" mode="delimited-text-only-data">
  <!-- output the old and new text with special text to separate them -->
    <xsl:text>-[[</xsl:text>
    <xsl:value-of select="./deltaxml:text[@deltaxml:deltaV2='A']/text()"/>
    <xsl:text>]]- +[[</xsl:text>
    <xsl:value-of select="./deltaxml:text[@deltaxml:deltaV2='B']/text()"/>
    <xsl:text>]]+</xsl:text>
  </xsl:template>

  <!-- For these elements, we output the new data and ignore old so that we
    ensure that the data is valid. So old data here is lost -->
  <xsl:template match="*[self::xhtml:script or self::xhtml:style][not(@deltaxml:deltaV2=('A', 'B'))]">
   <xsl:variable name="element-name">
    <xsl:call-template name="find-element-name">
      <xsl:with-param name="element" select="."/>
    </xsl:call-template>
   </xsl:variable>
   <xsl:element name="{$element-name}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="@*"/>
     <xsl:apply-templates select="node()" mode="new-text-only-data"/>
   </xsl:element>
  </xsl:template>

  <xsl:template match="deltaxml:comment">
    <xsl:comment>
      <xsl:apply-templates/>
    </xsl:comment>
  </xsl:template>
  
  <xsl:template match="deltaxml:comment" mode="new-text-only-data">
    <xsl:comment>
      <xsl:apply-templates/>
    </xsl:comment>
  </xsl:template>

  <xsl:template match="text()" mode="new-text-only-data">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="deltaxml:textGroup" mode="new-text-only-data">
  <!-- output the new text only -->
    <xsl:value-of select="./deltaxml:text[@deltaxml:deltaV2='B']/text()"/>
  </xsl:template>


  <!-- Finds and returns the correct element name, returing it without prefix
  if this is in XHTML namespace -->
  <xsl:template name="find-element-name">
   <xsl:param name="element"/>
   <xsl:choose>
    <xsl:when test="namespace-uri($element)='http://www.w3.org/1999/xhtml'">
      <xsl:value-of select="local-name($element)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="name($element)"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:template>

  <xsl:template match="node() | @*" mode="added-style-data">
    <xsl:copy>
      <xsl:apply-templates select="@* except @deltaxml:deltaV2 | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="deltaxml:textGroup" mode="added-style-data">
    <xsl:value-of select="deltaxml:text[@deltaxml:deltaV2='B']/text()"/>
  </xsl:template>
  
  <xsl:function name="deltaxml:get-attribute-for-version" as="attribute()?">
    <xsl:param name="current-attribute" as="node()"/>
    <xsl:param name="version" as="xs:string"/>
    
    <xsl:choose>
      <xsl:when test="$current-attribute/deltaxml:attributeValue[@deltaxml:deltaV2=$version]">
        <xsl:choose>
          <xsl:when test="namespace-uri($current-attribute)='http://www.deltaxml.com/ns/non-namespaced-attribute'">
            <xsl:attribute name="{local-name($current-attribute)}" namespace="" select="$current-attribute/deltaxml:attributeValue[@deltaxml:deltaV2=$version]"/>
          </xsl:when>
          <xsl:when test="namespace-uri($current-attribute)='http://www.deltaxml.com/ns/xml-namespaced-attribute'">
            <xsl:attribute name="{local-name($current-attribute)}" namespace="http://www.w3.org/XML/1998/namespace" select="$current-attribute/deltaxml:attributeValue[@deltaxml:deltaV2=$version]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="{local-name($current-attribute)}" namespace="{namespace-uri($current-attribute)}" select="$current-attribute/deltaxml:attributeValue[@deltaxml:deltaV2=$version]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template match="deltaxml:attributes" mode="added-style-data">
    <xsl:for-each select="*">
      <xsl:copy-of select="deltaxml:get-attribute-for-version(., 'B')"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="*[@deltaxml:deltaV2='A'][not(self::deltaxml:textGroup or self::deltaxml:attributes)]" mode="added-style-data"/>

  <xsl:template match="node() | @*" mode="deleted-style-data">
    <xsl:copy>
      <xsl:apply-templates select="@* except @deltaxml:deltaV2 | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="deltaxml:textGroup" mode="deleted-style-data">
    <xsl:value-of select="deltaxml:text[@deltaxml:deltaV2='A']/text()"/>
  </xsl:template>
  
  <xsl:template match="deltaxml:attributes" mode="deleted-style-data">
    <xsl:for-each select="*">
      <xsl:copy-of select="deltaxml:get-attribute-for-version(., 'A')"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="*[@deltaxml:deltaV2='B'][not(self::deltaxml:textGroup or self::deltaxml:attributes)]" mode="deleted-style-data"/>

  <!-- process a deleted version block -->
  <xsl:template match="xhtml:*[@class='delete_version'][@deltaxml:deltaV2='A']" priority="1">
    <xsl:if test="$includeButtons='yes'">
      <xsl:copy>
        <xsl:attribute name="style">display: none;</xsl:attribute>
        <xsl:apply-templates mode="deleted-style-data" select="@* except @xhtml:style | * | text() | comment()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="xhtml:*[@class='add_version'][@deltaxml:deltaV2='B']" priority="1">
    <xsl:if test="$includeButtons='yes'">
      <xsl:copy>
        <xsl:attribute name="style">display: none;</xsl:attribute>
        <xsl:apply-templates mode="added-style-data" select="@* except @xhtml:style | * | text() | comment()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="xhtml:*[@class='modify_version'][@deltaxml:deltaV2='A!=B']" priority="1">
    <xsl:choose>
      <xsl:when test="$includeButtons='yes'">
        <xsl:copy>
          <xsl:apply-templates select="@* | * | text() | comment()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | * | text() | comment()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Attribute handling -->
  
  <!-- Write out new attribute values as the 'real' attributes -->
  <!--<xsl:template match="deltaxml:attributes">
    <xsl:apply-templates select="node()"></xsl:apply-templates>
  </xsl:template>-->

  <!-- Remove deltaxml:delta and other delta attributes for normal mode, added mode and deleted mode-->
  <xsl:template match="@deltaxml:deltaV2 | @deltaxml:key | @deltaxml:ordered | 
                       @deltaxml:comment | @deltaxml:word-by-word | @deltaxml:format "/>
    
  <xsl:template match="@deltaxml:deltaV2 | @deltaxml:key | @deltaxml:ordered | 
                       @deltaxml:comment | @deltaxml:word-by-word | @deltaxml:format" mode="deleted-data"/>
    
  <xsl:template match="@deltaxml:deltaV2 |  @deltaxml:key | @deltaxml:ordered | 
                       @deltaxml:comment | @deltaxml:word-by-word | @deltaxml:format" mode="added-data"/>

  <!-- Write out other attributes -->
  <xsl:template match="@*">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="deltaxml:attributes">
    <xsl:for-each select="*">
      <xsl:copy-of select="deltaxml:get-attribute-for-version(., 'B')"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="deltaxml:attributes" mode="added-data">
    <xsl:for-each select="*">
      <xsl:copy-of select="deltaxml:get-attribute-for-version(., 'B')"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="deltaxml:attributes" mode="deleted-data">
    <xsl:for-each select="*">
      <xsl:copy-of select="deltaxml:get-attribute-for-version(., 'A')"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="xhtml:li[@deltaxml:deltaV2='A'] | xhtml:tr[@deltaxml:deltaV2='A']" priority="1">
    <xsl:copy>
      <xsl:attribute name="class">delete_version</xsl:attribute>
      <xsl:attribute name="style">display: none;</xsl:attribute>
      <xsl:apply-templates select="@* except (@deltaxml:deltaV2, @class, @style) | node()" mode="deleted-style-data"/>
    </xsl:copy>
    <xsl:copy>
      <xsl:attribute name="class">modify_version</xsl:attribute>
      <xsl:apply-templates select="@* | node()" mode="deleted-data"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="xhtml:li[@deltaxml:deltaV2='B'] | xhtml:tr[@deltaxml:deltaV2='B']" priority="1">
    <xsl:copy>
      <xsl:attribute name="class">add_version</xsl:attribute>
      <xsl:attribute name="style">display: none;</xsl:attribute>
      <xsl:apply-templates select="@* except (@deltaxml:deltaV2, @class, @style) | node()" mode="added-style-data"/>
    </xsl:copy>
    <xsl:copy>
      <xsl:attribute name="class">modify_version</xsl:attribute>
      <xsl:apply-templates select="@* | node()" mode="added-data"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
