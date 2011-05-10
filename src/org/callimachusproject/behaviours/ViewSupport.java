/*
 * Portions Copyright (c) 2009-10 Zepheira LLC and James Leigh, Some
   Rights Reserved
 * Portions Copyright (c) 2010-11 Talis Inc, Some Rights Reserved 
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

package org.callimachusproject.behaviours;

import static org.callimachusproject.stream.SPARQLWriter.toSPARQL;
import static org.callimachusproject.stream.XMLEventUtility.toInputStream;
import static org.openrdf.query.QueryLanguage.SPARQL;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;

import javax.tools.FileObject;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.transform.TransformerException;

import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.message.BasicHttpRequest;
import org.callimachusproject.concepts.Page;
import org.callimachusproject.rdfa.RDFEventReader;
import org.callimachusproject.rdfa.RDFParseException;
import org.callimachusproject.rdfa.RDFaReader;
import org.callimachusproject.rdfa.events.Triple;
import org.callimachusproject.rdfa.events.TriplePattern;
import org.callimachusproject.rdfa.model.CURIE;
import org.callimachusproject.rdfa.model.IRI;
import org.callimachusproject.rdfa.model.PlainLiteral;
import org.callimachusproject.rdfa.model.TermFactory;
import org.callimachusproject.stream.About;
import org.callimachusproject.stream.BufferedXMLEventReader;
import org.callimachusproject.stream.PrependTriple;
import org.callimachusproject.stream.RDFXMLEventReader;
import org.callimachusproject.stream.RDFaProducer;
import org.callimachusproject.stream.ReducedTripleReader;
import org.callimachusproject.stream.SPARQLProducer;
import org.callimachusproject.stream.SPARQLResultReader;
import org.callimachusproject.stream.TriplePatternStore;
import org.callimachusproject.stream.TriplePatternVariableStore;
import org.openrdf.http.object.annotations.header;
import org.openrdf.http.object.annotations.query;
import org.openrdf.http.object.annotations.transform;
import org.openrdf.http.object.annotations.type;
import org.openrdf.http.object.client.HTTPObjectClient;
import org.openrdf.http.object.exceptions.BadRequest;
import org.openrdf.http.object.exceptions.ResponseException;
import org.openrdf.http.object.traits.VersionedObject;
import org.openrdf.model.URI;
import org.openrdf.query.MalformedQueryException;
import org.openrdf.query.QueryEvaluationException;
import org.openrdf.query.TupleQuery;
import org.openrdf.query.TupleQueryResult;
import org.openrdf.repository.RepositoryException;
import org.openrdf.repository.object.ObjectConnection;
import org.openrdf.repository.object.RDFObject;

/**
 * Extracts parts of this template and constructs the RDF needed for this
 * template.
 * 
 * @author James Leigh
 * @author Steve Battle
 * 
 */
public abstract class ViewSupport implements Page, RDFObject, VersionedObject, FileObject {
	
	private static final String NS = "http://callimachusproject.org/rdf/2009/framework#";
	private static TermFactory tf = TermFactory.newInstance();
	public static String TRIAL = System.getProperty("trial");

	@Override
	public String calliConstructHTML(Object target) throws Exception {
		return calliConstructHTML(target, null);
	}

	/* calliConstruct() is used e.g. by the view tab (not exclusively) and returns 'application/xhtml+xml'.
	 * It returns the complete XHTML page.
	 */
	
	@Override
	public InputStream calliConstruct(Object target, String query) throws Exception {
		String uri = null;
		if (target instanceof RDFObject) {
			uri = ((RDFObject) target).getResource().stringValue();
		}
		// trial may be set to e.g 'disabled' to switch off the new functionality
		if ("enabled".equals(TRIAL) && "view".equals(query)) {
			ObjectConnection con = getObjectConnection();
			uri = uri == null ? null : toUri().resolve(uri).toASCIIString();
			URI uriValue = con.getValueFactory().createURI(uri);

			// Apply the XSLT stylesheet to the template
			BufferedXMLEventReader template = new BufferedXMLEventReader(xslt(query));
			int bufferStart = template.mark();

			// Generate SPARQL from the template and evaluate
			RDFEventReader rdfa = new RDFaReader(uri, template, toString());
			SPARQLProducer sparql = new SPARQLProducer(rdfa, SPARQLProducer.QUERY.SELECT);
			TupleQuery q = con.prepareTupleQuery(SPARQL, toSPARQL(sparql), uri);
			q.setBinding("this", uriValue);
			TupleQueryResult results = q.evaluate();

			// Populate the template from the result set
			template.reset(bufferStart);
			XMLEventReader xrdfa = new RDFaProducer(template, results, sparql.getOrigins(), uriValue);
			return toInputStream(xrdfa);
		}
		else {
			XMLEventReader data = calliConstructRDF(query, null, uri);
			return calliConstructTemplate(null, query, data);
		}
	}

	/**
	 * Extracts an element from the template (without variables) and populates
	 * the element with the properties of the about resource.
	 */
	@query("construct")
	@type("application/rdf+xml")
	@header("cache-control:no-store")
	@transform("http://callimachusproject.org/rdf/2009/framework#ConstructTemplate")
	public XMLEventReader calliConstruct(@query("query") String query,
			@query("element") String element,
			@query("about") String about) throws Exception {
		if (about != null && (element == null || element.equals("/1")))
			throw new BadRequest("Missing element parameter");
		return calliConstructRDF(query, element, about);
	}

	/**
	 * Extracts an element from the template (without variables).
	 */
	@query("template")
	@transform("http://callimachusproject.org/rdf/2009/framework#ConstructTemplate")
	public XMLEventReader template(@query("query") String query,
			@query("element") String element) throws Exception {
		return null;
	}

	/**
	 * Returns the given element with all known possible children.
	 */
	@query("options")
	@type("application/rdf+xml")
	@header("cache-control:no-store")
	@transform("http://callimachusproject.org/rdf/2009/framework#ConstructTemplate")
	public XMLEventReader options(@query("query") String query,
			@query("element") String element) throws Exception {
		String base = toUri().toASCIIString();
		TriplePatternStore patterns = readPatternStore(query, element, base);
		TriplePattern pattern = patterns.getFirstTriplePattern();
		RDFEventReader q = constructPossibleTriples(patterns, pattern);
		ObjectConnection con = getObjectConnection();

		/* consume UNION form of sparql construct */
		// RDFEventReader rdf = new RDFStoreReader(toSPARQL(q), patterns, con);
		RDFEventReader rdf = new SPARQLResultReader(toSPARQL(q), patterns, con);
		
		return new RDFXMLEventReader(new ReducedTripleReader(rdf));
	}

	@query("query")
	@type("application/sparql-query")
	public byte[] query(@query("element") String element, @query("about") String about)
			throws XMLStreamException, IOException, TransformerException,
			RDFParseException {
		String base = toUri().toASCIIString();
		TriplePatternStore query = new TriplePatternStore(base);
		String uri = about == null ? query.resolve(query.getReference()) : query.resolve(about);
		RDFEventReader reader = readPatterns("view", element, uri);
		try {
			query.consume(reader);
		} finally {
			reader.close();
		}
		return query.toString().getBytes(Charset.forName("UTF-8"));
	}

	protected RDFEventReader readPatterns(String query, String element,
			String about) throws XMLStreamException, IOException,
			TransformerException {
		return openPatternReader(query, element, about);
	}

	protected abstract InputStream calliConstructTemplate(String element,
			String query, XMLEventReader rdf) throws Exception;

	private XMLEventReader xslt(String qry) throws IOException,
			XMLStreamException {
		HTTPObjectClient client = HTTPObjectClient.getInstance();
		String uri = getResource().stringValue();
		String target = uri + (qry == null ? "?xslt" : "?xslt&query=" + qry);
		HttpRequest request = new BasicHttpRequest("GET", target);
		HttpResponse response = client.service(request);
		if (response.getStatusLine().getStatusCode() >= 300)
			throw ResponseException.create(response);
		InputStream input = response.getEntity().getContent();
		XMLInputFactory factory = XMLInputFactory.newInstance();
		return factory.createXMLEventReader(input);
	}

	private XMLEventReader calliConstructRDF(String query, String element,
			String about) throws XMLStreamException, IOException,
			TransformerException, RDFParseException, RepositoryException,
			MalformedQueryException, QueryEvaluationException {
		String uri = about == null ? null : toUri().resolve(about).toASCIIString();
		TriplePatternStore qry = readPatternStore(query, element, uri);
		ObjectConnection con = getObjectConnection();

		/* consume UNION form of sparql construct */
		// RDFEventReader rdf = new RDFStoreReader(qry, con, uri);
		RDFEventReader rdf = new SPARQLResultReader(qry, con, uri);

		rdf = new ReducedTripleReader(rdf);
		if (uri != null && element == null) {
			IRI subj = tf.iri(uri);
			rdf = new About(subj, rdf);
			String label = getETag(uri);
			if (label != null) {
				CURIE etag = tf.curie(NS, "etag", "calli");
				PlainLiteral obj = tf.literal(label);
				rdf = new PrependTriple(new Triple(subj, etag, obj), rdf);
			}
		}
		return new RDFXMLEventReader(rdf);
	}

	private TriplePatternStore readPatternStore(String query, String element,
			String about) throws XMLStreamException, IOException,
			TransformerException, RDFParseException {
		String base = toUri().toASCIIString();
		TriplePatternStore qry = new TriplePatternVariableStore(base);
		RDFEventReader reader = readPatterns(query, element, about);
		try {
			qry.consume(reader);
		} finally {
			reader.close();
		}
		return qry;
	}

	private String getETag(String uri) throws RepositoryException {
		ObjectConnection con = getObjectConnection();
		VersionedObject target = (VersionedObject) con.getObject(uri);
		String revision = target.revision();
		if (revision == null)
			return null;
		return "W/" + '"' + revision + '"';
	}
	
}
