<?xml version="1.0" encoding="UTF-8" ?>
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
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:sparql="http://www.w3.org/2005/sparql-results#"
    exclude-result-prefixes="xhtml sparql">
    <xsl:import href="graph.xsl" />
    <xsl:output indent="no" method="xml" />
    <xsl:template match="/">
        <xsl:if test="*">
            <html>
                <head>
                    <title>SPARQL Results</title>
                    <link rel="help" href="../../callimachus-for-web-developers" target="_blank" title="Help" />
                    <style>
                        ul.properties { margin-top: 0px; }
                        li.triple { list-style-type: none }
                        .plain { font-size: large; }
                        .bnode, .plain { font-family: monospace; white-space: pre-wrap; }
                        .typed { color: magenta; }
                        .datatype, .language { color: gray; }
                        .predicate { color: darkgreen; }
                    </style>
                    <xsl:if test="rdf:RDF">
                        <script type="text/javascript">
                            if ($('.literal[property="http://callimachusproject.org/rdf/2009/framework#hasResultLimit"]').length) {
                                var qs = window.location.search.substring(1);
                                window.location.replace(window.location.pathname + '#' + qs + '&amp;error=Too+Many+Results');
                            }
                        </script>
                    </xsl:if>
                    <script type="text/javascript">
                    <![CDATA[
                        var qs = window.location.search.replace(/query=[^&]*&?/,'');
                        if (qs && qs != '?') {
                            jQuery(function($){
                                $('a.describe').each(function(){
                                    this.href = this.href + '&' + qs.substring(1);
                                });
                            });
                        }
                    ]]>
                    </script>
                </head>
                <body>
                    <div class="container">
                        <div class="page-header">
                            <h1>SPARQL Results</h1>
                        </div>
                        <xsl:apply-templates />
                    </div>
                </body>
            </html>
        </xsl:if>
    </xsl:template>
    <xsl:template mode="describe" match="*[@rdf:resource]">
        <xsl:text> </xsl:text>
        <a href="?query=describe%3C{encode-for-uri(@rdf:resource)}%3E" class="describe glyphicon glyphicon-chevron-right"></a>
    </xsl:template>
    <xsl:template mode="describe" match="*[@rdf:about]">
        <xsl:text> </xsl:text>
        <a href="?query=describe%3C{encode-for-uri(@rdf:about)}%3E" class="describe glyphicon glyphicon-chevron-left"></a>
    </xsl:template>
    <xsl:template match="sparql:sparql">
        <table id="sparql">
            <xsl:apply-templates select="*" />
        </table>
    </xsl:template>
    <xsl:template match="sparql:head">
        <thead id="head">
            <xsl:apply-templates select="sparql:variable" />
        </thead>
    </xsl:template>
    <xsl:template match="sparql:variable">
        <th>
            <xsl:value-of select="@name" />
        </th>
    </xsl:template>
    <xsl:template match="sparql:boolean">
        <tbody id="boolean">
            <tr>
                <td>
                    <xsl:value-of select="text()" />
                </td>
            </tr>
        </tbody>
    </xsl:template>
    <xsl:template match="sparql:results">
        <tbody id="results">
            <xsl:apply-templates select="sparql:result" />
        </tbody>
    </xsl:template>
    <xsl:template match="sparql:result">
        <xsl:variable name="current" select="."/> 
        <tr class="result">
            <xsl:for-each select="../../sparql:head[1]/sparql:variable">
                <xsl:variable name="name" select="@name"/> 
                <td>
                    <xsl:apply-templates select="$current/sparql:binding[@name=$name]" /> 
                </td>
            </xsl:for-each>
        </tr>
    </xsl:template>
    <xsl:template match="sparql:binding">
        <xsl:apply-templates select="*" />
    </xsl:template>
    <xsl:template match="sparql:uri">
        <a href="{text()}" class="uri">
            <xsl:call-template name="resource">
                <xsl:with-param name="iri" select="text()"/>
            </xsl:call-template>
        </a>
        <xsl:text> </xsl:text>
        <a href="?query=describe%3C{encode-for-uri(text())}%3E" class="describe glyphicon glyphicon-chevron-right"></a>
    </xsl:template>
    <xsl:template match="sparql:bnode">
        <a class="bnode" resource="_:{text()}" name="{text()}">
            <xsl:text>_:</xsl:text>
            <xsl:value-of select="text()" />
        </a>
    </xsl:template>
    <xsl:template match="sparql:literal">
        <span class="plain literal">
            <xsl:value-of select="text()" />
        </span>
    </xsl:template>
    <xsl:template match="sparql:literal[@datatype and @datatype!='http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral']">
        <span class="typed literal">
            <xsl:attribute name="datatype">
                <xsl:call-template name="iriref">
                    <xsl:with-param name="iri" select="@datatype" />
                </xsl:call-template>
            </xsl:attribute>
            <xsl:value-of select="text()" />
            <span class="datatype">
                <span>^^</span>
                <xsl:call-template name="resource">
                    <xsl:with-param name="iri" select="@datatype" />
                </xsl:call-template>
            </span>
        </span>
    </xsl:template>
    <xsl:template match="sparql:literal[@xml:lang]">
        <span class="plain literal">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="@xml:lang" />
            </xsl:attribute>
            <xsl:value-of select="text()" />
            <span class="language">
                <span>@</span>
                <xsl:value-of select="@xml:lang" />
            </span>
        </span>
    </xsl:template>
    <xsl:template
        match="sparql:literal[@datatype='http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral']">
        <span class="typed literal" datatype="rdf:XMLLiteral">
            <xsl:value-of disable-output-escaping="yes" select="text()" />
        </span>
    </xsl:template>
</xsl:stylesheet>
