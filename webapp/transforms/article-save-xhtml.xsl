<?xml version="1.0" encoding="UTF-8"?>
<!--
  - Copyright (c) 2014 3 Round Stones Inc., Some Rights Reserved
  -
  - Licensed under the Apache License, Version 2.0 (the "License");
  - you may not use this file except in compliance with the License.
  - You may obtain a copy of the License at
  -
  -     http://www.apache.org/licenses/LICENSE-2.0
  -
  - Unless required by applicable law or agreed to in writing, software
  - distributed under the License is distributed on an "AS IS" BASIS,
  - WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  - See the License for the specific language governing permissions and
  - limitations under the License.
  -
  -->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xhtml="http://www.w3.org/1999/xhtml" 
    xmlns="http://docbook.org/ns/docbook" 
    xmlns:xl   ="http://www.w3.org/1999/xlink"
    version="1.0" 
    exclude-result-prefixes="xsl xhtml">
<xsl:output media-type="application/docbook+xml" method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:key name="section" match="node()[not(name()='h1' or name()='h2' or name()='h3' or name()='h4' or name()='h5' or name()='h6')]"
use="generate-id(preceding-sibling::*[name()='h1' or name()='h2' or name()='h3' or name()='h4' or name()='h5' or name()='h6'][1])"/>

<xsl:key name="h1" match="xhtml:h1" use="generate-id(preceding::*[name()='head' or name()='h1'][1])"/>
<xsl:key name="h2" match="xhtml:h2" use="generate-id(preceding::*[name()='head' or name()='h1'][1])"/>
<xsl:key name="h3" match="xhtml:h3" use="generate-id(preceding::*[name()='head' or name()='h1' or name()='h2'][1])"/>
<xsl:key name="h4" match="xhtml:h4" use="generate-id(preceding::*[name()='head' or name()='h1' or name()='h2' or name()='h3'][1])"/>
<xsl:key name="h5" match="xhtml:h5" use="generate-id(preceding::*[name()='head' or name()='h1' or name()='h2' or name()='h3' or name()='h4'][1])"/>
<xsl:key name="h6" match="xhtml:h6" use="generate-id(preceding::*[name()='head' or name()='h1' or name()='h2' or name()='h3' or name()='h4' or name()='h5'][1])"/>

<xsl:template match="text()|comment()">
    <xsl:copy />
</xsl:template>

<xsl:template match="@*">
    <xsl:attribute name="{local-name()}">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<!-- use template id instead -->
<xsl:template match="@id|@xml:id" />

<!-- ignore random styles -->
<xsl:template match="@style" />

<xsl:template match="@lang|@xml:lang">
    <xsl:attribute name="xml:lang">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<xsl:template match="@title">
    <xsl:attribute name="xl:title">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<xsl:template match="*">
    <xsl:element name="{local-name()}">
        <xsl:apply-templates select="@*|node()" />
    </xsl:element>
</xsl:template>

<xsl:template match="xhtml:span[@style and not(@class)]">
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="xhtml:font">
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="xhtml:br">
    <xsl:text>&#xA;</xsl:text>
</xsl:template>

<xsl:template match="xhtml:html">
    <article version="5.0">
        <xsl:choose>
            <xsl:when test="xhtml:body/xhtml:h1/xhtml:a[@name and not(@href) and not(preceding-sibling::*) and string-length(normalize-space(preceding-sibling::node()))=0]">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="xhtml:body/xhtml:h1/xhtml:a[1]/@name" />
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="xhtml:body/xhtml:h1/@id">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="xhtml:body/xhtml:h1/@id" />
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
        <xsl:apply-templates select="xhtml:body"/>
    </article>
</xsl:template>

<xsl:template match="xhtml:body">
    <xsl:apply-templates select="@*" />
    <xsl:if test="not(*)">
        <para />
    </xsl:if>
    <xsl:choose>
        <xsl:when test="not(*[name()='h1' or name()='h2' or name()='h3' or name()='h4' or name()='h5' or name()='h6'])">
            <!-- No sections if there are no heading elements (article without title nor sections)-->
            <title />
            <xsl:apply-templates />
        </xsl:when>
        <xsl:when test="'h1'=name(*[1])">
            <xsl:apply-templates select="h1[1]/preceding-sibling::node()" />
            <title><xsl:apply-templates select="xhtml:h1[1]/node()" /></title>
            <xsl:if test="not(key('section', generate-id(xhtml:h1[1]))[self::*] or key('h2', generate-id(xhtml:h1[1])))">
                <para />
            </xsl:if>
            <xsl:apply-templates select="key('section', generate-id(xhtml:h1[1]))" />
            <xsl:apply-templates select="key('h6', generate-id(xhtml:h1[1]))" />
            <xsl:apply-templates select="key('h5', generate-id(xhtml:h1[1]))" />
            <xsl:apply-templates select="key('h4', generate-id(xhtml:h1[1]))" />
            <xsl:apply-templates select="key('h3', generate-id(xhtml:h1[1]))" />
            <xsl:apply-templates select="key('h2', generate-id(xhtml:h1[1]))" />
            <xsl:apply-templates select="key('h1', generate-id(xhtml:h1[1]))" />
        </xsl:when>
        <xsl:otherwise>
            <title><xsl:apply-templates select="*[name()='h1' or name()='h2' or name()='h3' or name()='h4' or name()='h5' or name()='h6'][1]/node()" /></title>
            <xsl:apply-templates select="*[name()='h1' or name()='h2' or name()='h3' or name()='h4' or name()='h5' or name()='h6'][1]/preceding-sibling::node()" />
            <xsl:apply-templates select="key('h6', generate-id(/xhtml:html/xhtml:head))" />
            <xsl:apply-templates select="key('h5', generate-id(/xhtml:html/xhtml:head))" />
            <xsl:apply-templates select="key('h4', generate-id(/xhtml:html/xhtml:head))" />
            <xsl:apply-templates select="key('h3', generate-id(/xhtml:html/xhtml:head))" />
            <xsl:apply-templates select="key('h2', generate-id(/xhtml:html/xhtml:head))" />
            <xsl:apply-templates select="key('h1', generate-id(/xhtml:html/xhtml:head))" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="xhtml:h1">
    <section>
        <xsl:call-template name="id" />
        <title><xsl:apply-templates /></title>
        <xsl:if test="not(key('section', generate-id())[self::*] or key('h2', generate-id()))">
            <para />
        </xsl:if>
        <xsl:apply-templates select="key('section', generate-id())" />
        <xsl:apply-templates select="key('h6', generate-id())" />
        <xsl:apply-templates select="key('h5', generate-id())" />
        <xsl:apply-templates select="key('h4', generate-id())" />
        <xsl:apply-templates select="key('h3', generate-id())" />
        <xsl:apply-templates select="key('h2', generate-id())" />
        <xsl:apply-templates select="key('h1', generate-id())" />
    </section>
</xsl:template>

<xsl:template match="xhtml:h2">
    <section>
        <xsl:call-template name="id" />
        <title><xsl:apply-templates /></title>
        <xsl:if test="not(key('section', generate-id())[self::*] or key('h3', generate-id()))">
            <para />
        </xsl:if>
        <xsl:apply-templates select="key('section', generate-id())" />
        <xsl:apply-templates select="key('h6', generate-id())" />
        <xsl:apply-templates select="key('h5', generate-id())" />
        <xsl:apply-templates select="key('h4', generate-id())" />
        <xsl:apply-templates select="key('h3', generate-id())" />
    </section>
</xsl:template>

<xsl:template match="xhtml:h3">
    <section>
        <xsl:call-template name="id" />
        <title><xsl:apply-templates /></title>
        <xsl:if test="not(key('section', generate-id())[self::*] or key('h4', generate-id()))">
            <para />
        </xsl:if>
        <xsl:apply-templates select="key('section', generate-id())" />
        <xsl:apply-templates select="key('h6', generate-id())" />
        <xsl:apply-templates select="key('h5', generate-id())" />
        <xsl:apply-templates select="key('h4', generate-id())" />
    </section>
</xsl:template>

<xsl:template match="xhtml:h4">
    <section>
        <xsl:call-template name="id" />
        <title><xsl:apply-templates /></title>
        <xsl:if test="not(key('section', generate-id())[self::*] or key('h5', generate-id()))">
            <para />
        </xsl:if>
        <xsl:apply-templates select="key('section', generate-id())" />
        <xsl:apply-templates select="key('h6', generate-id())" />
        <xsl:apply-templates select="key('h5', generate-id())" />
    </section>
</xsl:template>

<xsl:template match="xhtml:h5">
    <section>
        <xsl:call-template name="id" />
        <title><xsl:apply-templates /></title>
        <xsl:if test="not(key('section', generate-id())[self::*] or key('h6', generate-id()))">
            <para />
        </xsl:if>
        <xsl:apply-templates select="key('section', generate-id())" />
        <xsl:apply-templates select="key('h6', generate-id())" />
    </section>
</xsl:template>

<xsl:template match="xhtml:h6">
    <section>
        <xsl:call-template name="id" />
        <title><xsl:apply-templates /></title>
        <xsl:if test="not(key('section', generate-id())[self::*])">
            <para />
        </xsl:if>
        <xsl:apply-templates select="key('section', generate-id())" />
    </section>
</xsl:template>

<!-- para elements -->
<xsl:template match="xhtml:p">
    <para>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@*[name()!= 'style']" />
        <xsl:apply-templates />
    </para>
</xsl:template>

<xsl:template match="xhtml:blockquote">
    <blockquote>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@*" />
        <xsl:apply-templates />
    </blockquote>
</xsl:template>

<xsl:template match="xhtml:div">
    <!-- ignore sections nested in div (they will be pulled out after this section) -->
    <xsl:apply-templates select="*[not(name()='h1' or name()='h2' or name()='h3' or name()='h4' or name()='h5' or name()='h6') and not(preceding-sibling::xhtml:h1 or preceding-sibling::xhtml:h2 or preceding-sibling::xhtml:h3 or preceding-sibling::xhtml:h4 or preceding-sibling::xhtml:h5 or preceding-sibling::xhtml:h6)]" />
</xsl:template>

<xsl:template match="xhtml:div[@contenteditable='false'][xhtml:pre]">
    <xsl:apply-templates select="xhtml:pre" />
</xsl:template>

<xsl:template match="xhtml:pre[not(@class='prettyprint')][not(xhtml:code[not(@class)])]">
    <screen>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@*" />
        <xsl:apply-templates />
    </screen>
</xsl:template>

<xsl:template match="xhtml:pre[@class='prettyprint']">
    <programlisting>
        <xsl:call-template name="id" />
        <xsl:apply-templates />
    </programlisting>
</xsl:template>

<xsl:template match="xhtml:pre[xhtml:code[not(@class) or matches(@class,'language-\S')]]">
    <xsl:apply-templates select="xhtml:code" />
</xsl:template>

<xsl:template match="xhtml:pre/xhtml:code[not(@class) or matches(@class,'language-\S')]">
    <programlisting>
        <xsl:call-template name="id" />
        <xsl:if test="matches(@class,'language-\S')">
            <xsl:attribute name="language">
                <xsl:value-of select="replace(@class,'^.*language-(\S+).*$','$1')" />
            </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="." />
    </programlisting>
</xsl:template>

<!-- Hyperlinks -->
<!-- 
    link - A hypertext link
     - @xlink:href  - Identifies a link target with a URI.
     - @xlink:title - Identifies the XLink title of the link.
     - @linkend     - Points to an internal link target by identifying the value of its xml:id attribute.
  -->
<xsl:template match="xhtml:a[@name and not(@href)]">
    <xsl:if test="preceding-sibling::* or string-length(normalize-space(preceding-sibling::node()))&gt;0">
        <anchor xml:id="{@name}" />
    </xsl:if>
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="xhtml:a[@href and not(starts-with(@href,'#'))]">
    <link xl:href="{@href}">
        <xsl:if test="@title">
            <xsl:attribute name="xl:title" namespace="http://www.w3.org/1999/xlink">
                <xsl:value-of select="@title"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@lang" />
        <xsl:apply-templates />
    </link>
</xsl:template>

<xsl:template match="xhtml:a[starts-with(@href,'#')]">
    <link linkend="{substring-after(@href,'#')}">
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@lang" />
        <xsl:apply-templates />
        <xsl:if test="@title">
            <remark><xsl:value-of select="@title" /></remark>
        </xsl:if>
    </link>
</xsl:template>

<!-- Images -->
<xsl:template match="xhtml:figure | xhtml:p[@class='figure']">
    <informalfigure>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@*" />
        <xsl:apply-templates />
    </informalfigure>
</xsl:template>

<xsl:template match="xhtml:figcaption |xhtml:span[@class='caption']">
    <caption>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@*" />
        <simpara>
            <xsl:apply-templates />
        </simpara>
    </caption>
</xsl:template>

<xsl:template match="xhtml:figcaption/xhtml:p">
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="xhtml:img">
    <inlinemediaobject>
        <xsl:call-template name="imageobject" />
    </inlinemediaobject>
</xsl:template>

<xsl:template match="xhtml:body/xhtml:img">
    <figure>
        <title><xsl:value-of select="@title" /></title>
        <mediaobject>
            <xsl:call-template name="imageobject" />
        </mediaobject>
    </figure>
</xsl:template>

<xsl:template match="xhtml:figure/xhtml:img|xhtml:p[@class='figure']/xhtml:img">
    <mediaobject>
        <xsl:call-template name="imageobject" />
    </mediaobject>
</xsl:template>

<xsl:template name="imageobject">
    <xsl:if test="@alt">
        <alt>
            <xsl:value-of select="@alt" />
        </alt>
    </xsl:if>
    <imageobject>
        <imagedata>
            <xsl:choose>
                <xsl:when test="@align">
                    <xsl:attribute name="align">
                        <xsl:value-of select="@align" />
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="contains(@style, 'float:left')">
                    <xsl:attribute name="align">
                        <xsl:text>left</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="contains(@style, 'float:right')">
                    <xsl:attribute name="align">
                        <xsl:text>right</xsl:text>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="@*[name()!= 'alt' and name()!='title' and name()!='align']" />
        </imagedata>
    </imageobject>
    <xsl:if test="@title">
        <caption>
            <simpara><xsl:value-of select="@title" /></simpara>
        </caption>
    </xsl:if>
</xsl:template>

<xsl:template match="xhtml:img/@alt|xhtml:img/@title|xhtml:img/@border" />

<xsl:template match="xhtml:img/@src">
    <xsl:attribute name="fileref">
        <xsl:value-of select="." />
    </xsl:attribute>
</xsl:template>

<xsl:template match="xhtml:img/@width">
    <xsl:if test="string-length() &gt; 0">
        <xsl:attribute name="contentwidth">
            <xsl:value-of select="concat(.,'px')" />
        </xsl:attribute>
    </xsl:if>
</xsl:template>

<xsl:template match="xhtml:img/@height">
    <xsl:if test="string-length() &gt; 0">
        <xsl:attribute name="contentdepth">
            <xsl:value-of select="concat(.,'px')" />
        </xsl:attribute>
    </xsl:if>
</xsl:template>

<xsl:template match="xhtml:img/@style">
    <xsl:if test="not(../@width) and contains(../@style, 'width:')">
        <xsl:attribute name="contentwidth">
            <xsl:value-of select="concat(substring-before(substring-after(../@style,'width:'),'px'),'px')" />
        </xsl:attribute>
    </xsl:if>
    <xsl:if test="not(../@height) and contains(../@style, 'height:')">
        <xsl:attribute name="contentdepth">
            <xsl:value-of select="concat(substring-before(substring-after(../@style,'height:'),'px'),'px')" />
        </xsl:attribute>
    </xsl:if>
</xsl:template>

<xsl:template match="xhtml:img/@hspace">
    <xsl:variable name="width">
        <xsl:choose>
            <xsl:when test="../@width">
                <xsl:value-of select="../@width" />
            </xsl:when>
            <xsl:when test="contains(substring-after(../@style,'width:'),'px')">
                <xsl:value-of select="substring-before(substring-after(../@style, 'width:'), 'px')" />
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length() &gt; 0">
        <xsl:attribute name="width">
            <xsl:value-of select="concat(2 * number() + number($width),'px')" />
        </xsl:attribute>
    </xsl:if>
</xsl:template>

<xsl:template match="xhtml:img/@vspace">
    <xsl:variable name="height">
        <xsl:choose>
            <xsl:when test="../@height">
                <xsl:value-of select="../@height" />
            </xsl:when>
            <xsl:when test="contains(substring-after(../@style,'height:'),'px')">
                <xsl:value-of select="substring-before(substring-after(../@style, 'height:'), 'px')" />
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length() &gt; 0">
        <xsl:attribute name="depth">
            <xsl:value-of select="concat(2 * number() + number($height),'px')" />
        </xsl:attribute>
    </xsl:if>
</xsl:template>

<!-- LIST ELEMENTS -->
<xsl:template match="xhtml:ul">
    <itemizedlist>
        <xsl:apply-templates select="@*" />
        <xsl:call-template name="id" />
        <xsl:apply-templates />
    </itemizedlist>
</xsl:template>

<xsl:template match="xhtml:ol">
    <orderedlist>
        <xsl:apply-templates select="@*" />
        <xsl:call-template name="id" />
        <xsl:apply-templates />
    </orderedlist>
</xsl:template>

<!-- This template makes a DocBook variablelist out of an HTML definition list -->
<xsl:template match="xhtml:dl">
    <variablelist>
        <xsl:for-each select="xhtml:dt">
            <varlistentry>
                <term>
                    <xsl:apply-templates select="@*" />
                    <xsl:call-template name="id" />
                    <xsl:apply-templates />
                </term>
                <xsl:apply-templates select="following-sibling::xhtml:dd[1]"/>
            </varlistentry>
        </xsl:for-each>
    </variablelist>
</xsl:template>

<xsl:template match="xhtml:dd">
    <listitem>
        <xsl:apply-templates select="@*" />
        <xsl:call-template name="id" />
        <simpara>
            <xsl:apply-templates select="node()[not(self::xhtml:ul or self::xhtml:ol or self::xhtml:dl)]" />
        </simpara>
        <xsl:apply-templates select="xhtml:ul|xhtml:ol|xhtml:dl" />
    </listitem>
</xsl:template>

<xsl:template match="xhtml:li">
    <listitem>
        <xsl:apply-templates select="@*" />
        <xsl:call-template name="id" />
        <simpara>
            <xsl:apply-templates select="node()[not(self::xhtml:ul or self::xhtml:ol or self::xhtml:dl)]" />
        </simpara>
        <xsl:apply-templates select="xhtml:ul|xhtml:ol|xhtml:dl" />
    </listitem>
</xsl:template>

<xsl:template match="xhtml:dd[xhtml:p]">
    <listitem>
        <xsl:apply-templates select="@*" />
        <xsl:call-template name="id" />
        <xsl:apply-templates />
    </listitem>
</xsl:template>

<xsl:template match="xhtml:li[xhtml:p]">
    <listitem>
        <xsl:apply-templates select="@*" />
        <xsl:call-template name="id" />
        <xsl:apply-templates />
    </listitem>
</xsl:template>

<xsl:template match="xhtml:caption|xhtml:tbody|xhtml:tr|xhtml:thead|xhtml:tfoot|xhtml:colgroup|xhtml:col">
    <xsl:element name="{local-name()}" 
                 namespace="http://docbook.org/ns/docbook">
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@lang" />
        <xsl:apply-templates select="@align|@colspan|@rowspan|@valign" />
        <xsl:apply-templates />
    </xsl:element>
</xsl:template>

<xsl:template match="xhtml:td|xhtml:th">
    <xsl:element name="{local-name()}"
                 namespace="http://docbook.org/ns/docbook">
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@lang" />
        <xsl:apply-templates select="@align|@colspan|@rowspan|@valign" />
        <xsl:apply-templates />
    </xsl:element>
</xsl:template>

<xsl:template match="xhtml:td[xhtml:p|xhtml:blockquote|xhtml:div|xhtml:pre|xhtml:figure|xhtml:ul|xhtml:ol|xhtml:dl|xhtml:table]|xhtml:th[xhtml:p|xhtml:blockquote|xhtml:div|xhtml:pre|xhtml:figure|xhtml:ul|xhtml:ol|xhtml:dl|xhtml:table]">
    <xsl:element name="{local-name()}"
                 namespace="http://docbook.org/ns/docbook">
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@lang" />
        <xsl:apply-templates select="@align|@colspan|@rowspan|@valign" />
        <xsl:apply-templates mode="block" />
    </xsl:element>
</xsl:template>

<xsl:template mode="block" match="text()">
    <xsl:if test="string-length(normalize-space())!=0">
        <para>
            <xsl:apply-templates select="." />
        </para>
    </xsl:if>
</xsl:template>

<xsl:template mode="block" match="*">
    <para>
        <xsl:apply-templates select="." />
    </para>
</xsl:template>

<xsl:template mode="block" match="comment()|xhtml:p|xhtml:blockquote|xhtml:div|xhtml:pre|xhtml:figure|xhtml:ul|xhtml:ol|xhtml:dl|xhtml:table">
    <xsl:apply-templates select="." />
</xsl:template>


<!-- tables -->
<xsl:template match="xhtml:table[not(xhtml:caption)]">
    <informaltable>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@lang" />
        <xsl:apply-templates select="@summary|@width|@border|@cellspacing|@cellpadding|@frame|@rules" />
        <xsl:if test="not(@width) and matches(@style, 'width:\s*\d+px')">
            <xsl:attribute name="width">
                <xsl:value-of select="replace(@style, '.*width:\s*(\d+)px.*', '$1')" />
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates mode="col" select="(xhtml:thead/xhtml:tr|xhtml:tbody/xhtml:tr)[not(*/@colspan)][1]/(xhtml:th|xhtml:td)" />
        <xsl:apply-templates select="*[not(self::xhtml:col)]" />
    </informaltable>
</xsl:template>

<xsl:template match="xhtml:table[xhtml:caption]">
    <table>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@lang" />
        <xsl:apply-templates select="@summary|@width|@border|@cellspacing|@cellpadding|@frame|@rules" />
        <xsl:apply-templates select="xhtml:caption" />
        <xsl:apply-templates mode="col" select="(xhtml:thead/xhtml:tr|xhtml:tbody/xhtml:tr)[not(*/@colspan)][1]/(xhtml:th|xhtml:td)" />
        <xsl:apply-templates select="*[not(self::xhtml:caption or self::xhtml:col)]" />
    </table>
</xsl:template>

<xsl:template match="xhtml:th|xhtml:td" mode="col">
    <col>
        <xsl:apply-templates select="@align|@char|@charoff|@valign|@width" />
        <xsl:if test="@colspan">
            <xsl:attribute name="span">
                <xsl:value-of select="@colspan" />
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="not(@width) and matches(@style, 'width:\s*\d+px')">
            <xsl:attribute name="width">
                <xsl:value-of select="replace(@style, '.*width:\s*(\d+)px.*', '$1')" />
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="not(@width) and matches(@style, 'width:\s*\d+%')">
            <xsl:attribute name="width">
                <xsl:value-of select="replace(@style, '.*width:\s*(\d+%).*', '$1')" />
            </xsl:attribute>
        </xsl:if>
    </col>
</xsl:template>

<!-- inline formatting -->

<xsl:template match="xhtml:code">
    <code>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@*" />
        <xsl:apply-templates mode="code" />
    </code>
</xsl:template>

<xsl:template match="xhtml:code[@class='classname']">
    <classname>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </classname>
</xsl:template>

<xsl:template match="xhtml:code[@class='command']">
    <command>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </command>
</xsl:template>

<xsl:template match="xhtml:code[@class='envar']">
    <envar>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </envar>
</xsl:template>

<xsl:template match="xhtml:code[@class='exceptionname']">
    <exceptionname>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </exceptionname>
</xsl:template>

<xsl:template match="xhtml:code[@class='filename']">
    <filename>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </filename>
</xsl:template>

<xsl:template match="xhtml:code[@class='function']">
    <function>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </function>
</xsl:template>

<xsl:template match="xhtml:code[@class='initializer']">
    <initializer>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </initializer>
</xsl:template>

<xsl:template match="xhtml:code[@class='interfacename']">
    <interfacename>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </interfacename>
</xsl:template>

<xsl:template match="xhtml:code[@class='literal']">
    <literal>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </literal>
</xsl:template>

<xsl:template match="xhtml:code[@class='methodname']">
    <methodname>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </methodname>
</xsl:template>

<xsl:template match="xhtml:code[@class='modifier']">
    <modifier>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </modifier>
</xsl:template>

<xsl:template match="xhtml:code[@class='ooclass']">
    <ooclass>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </ooclass>
</xsl:template>

<xsl:template match="xhtml:code[@class='ooexception']">
    <ooexception>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </ooexception>
</xsl:template>

<xsl:template match="xhtml:code[@class='oointerface']">
    <oointerface>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </oointerface>
</xsl:template>

<xsl:template match="xhtml:code[@class='parameter']">
    <parameter>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </parameter>
</xsl:template>

<xsl:template match="xhtml:code[@class='prompt']">
    <prompt>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </prompt>
</xsl:template>

<xsl:template match="xhtml:code[@class='property']">
    <property>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </property>
</xsl:template>

<xsl:template match="xhtml:code[@class='returnvalue']">
    <returnvalue>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </returnvalue>
</xsl:template>

<xsl:template match="xhtml:code[@class='symbol']">
    <symbol>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </symbol>
</xsl:template>

<xsl:template match="xhtml:code[@class='token']">
    <token>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </token>
</xsl:template>

<xsl:template match="xhtml:code[@class='type']">
    <type>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </type>
</xsl:template>

<xsl:template match="xhtml:code[@class='uri']">
    <uri>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </uri>
</xsl:template>

<xsl:template match="xhtml:code[@class='userinput']">
    <userinput>
        <xsl:call-template name="id" />
        <xsl:apply-templates mode="code" />
    </userinput>
</xsl:template>

<xsl:template mode="code" match="node()">
    <xsl:apply-templates select="." />
</xsl:template>

<xsl:template mode="code" match="xhtml:code">
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="xhtml:var|xhtml:code[@class='varname']">
    <varname>
        <xsl:call-template name="id" />
        <xsl:apply-templates />
    </varname>
</xsl:template>

<xsl:template match="xhtml:samp">
    <computeroutput>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@*" />
        <xsl:apply-templates />
    </computeroutput>
</xsl:template>

<xsl:template match="xhtml:q">
    <quote>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@*" />
        <xsl:apply-templates />
    </quote>
</xsl:template>

<xsl:template match="xhtml:b">
    <emphasis role="bold">
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@*" />
        <xsl:apply-templates />
    </emphasis>
</xsl:template>

<xsl:template match="xhtml:strong">
    <emphasis role="strong">
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@*" />
        <xsl:apply-templates />
    </emphasis>
</xsl:template>

<xsl:template match="xhtml:i | xhtml:em">
    <emphasis>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@*" />
        <xsl:apply-templates />
    </emphasis>
</xsl:template>

<xsl:template match="xhtml:u | xhtml:cite">
    <citetitle>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@*" />
        <xsl:apply-templates />
    </citetitle>
</xsl:template>

<xsl:template match="xhtml:sup">
    <superscript>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@*" />
        <xsl:apply-templates />
    </superscript>
</xsl:template>

<xsl:template match="xhtml:sub">
    <subscript>
        <xsl:call-template name="id" />
        <xsl:apply-templates select="@*" />
        <xsl:apply-templates />
    </subscript>
</xsl:template>

<xsl:template name="id">
    <xsl:choose>
        <xsl:when test="self::xhtml:a/@name">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="@name" />
            </xsl:attribute>
        </xsl:when>
        <xsl:when test="xhtml:a[@name and not(@href) and not(preceding-sibling::*) and string-length(normalize-space(preceding-sibling::node()))=0]">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="xhtml:a[1]/@name" />
            </xsl:attribute>
        </xsl:when>
        <xsl:when test="@id">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="@id" />
            </xsl:attribute>
        </xsl:when>
        <xsl:when test="@xml:id">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="@xml:id" />
            </xsl:attribute>
        </xsl:when>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
