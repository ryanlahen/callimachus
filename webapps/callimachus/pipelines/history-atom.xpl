<?xml version="1.0" encoding="UTF-8" ?>
<p:pipeline version="1.0"
        xmlns:p="http://www.w3.org/ns/xproc"
        xmlns:c="http://www.w3.org/ns/xproc-step"
        xmlns:l="http://xproc.org/library"
        xmlns:calli ="http://callimachusproject.org/rdf/2009/framework#">
    <p:serialization port="result" media-type="application/atom+xml" method="xml" />
    <p:option name="this"  required="true"  />
    <p:load>
        <p:with-option 
            name="href" 
            select="concat('../queries/history.rq?results&amp;this=', encode-for-uri($this))"/>
    </p:load>
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../transforms/sparql-results-atom.xsl" />
        </p:input>
    </p:xslt>
    <p:xslt>
        <p:with-param name="xsltId" select="resolve-uri('../transforms/divert-atom-links.xsl')" />
        <p:input port="stylesheet">
            <p:document href="../transforms/divert-atom-links.xsl" />
        </p:input>
    </p:xslt>
</p:pipeline>
