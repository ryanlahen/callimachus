/*
 * Copyright (c) 2013 3 Round Stones Inc., Some Rights Reserved
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
package org.callimachusproject.rewrite;

import java.net.URI;

import junit.framework.TestCase;

import org.apache.http.HttpResponse;
import org.callimachusproject.annotations.alternate;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.openrdf.annotations.Iri;
import org.openrdf.annotations.Param;
import org.openrdf.model.vocabulary.RDF;
import org.openrdf.model.vocabulary.RDFS;
import org.openrdf.repository.Repository;
import org.openrdf.repository.RepositoryConnection;
import org.openrdf.repository.object.ObjectConnection;
import org.openrdf.repository.object.ObjectRepository;
import org.openrdf.repository.object.config.ObjectRepositoryConfig;
import org.openrdf.repository.object.config.ObjectRepositoryFactory;
import org.openrdf.repository.sail.SailRepository;
import org.openrdf.sail.memory.MemoryStore;

public class RedirectTest extends TestCase {

	@Iri("http://example.com/Concept")
	public interface Concept {
		@alternate("http://example.com/")
		HttpResponse literal();

		@alternate("http://example.com/{+1}/{+2}")
		HttpResponse readDomain(@Param("1") String one, @Param("2") String two);

		@alternate("{+this}{#frag}")
		HttpResponse frag(@Iri("urn:test:frag") String frag);

		@alternate("{+this}?{+query}")
		HttpResponse replaceQuery(@Iri("urn:test:query") String query);

		@alternate("{+this}?param={value}")
		HttpResponse param(@Iri("urn:test:value") String value);

		@alternate("{+value}")
		HttpResponse resolve(@Iri("urn:test:value") java.net.URI value);
	}

	private Repository repository;
	private ObjectRepositoryConfig config = new ObjectRepositoryConfig();
	private ObjectConnection con;
	private Concept concept;

	private Repository createRepository() throws Exception {
		return new SailRepository(new MemoryStore());
	}

	private ObjectRepository getRepository() throws Exception {
		Repository repository = createRepository();
		repository.initialize();
		RepositoryConnection con = repository.getConnection();
		try {
			con.begin();
			con.clear();
			con.clearNamespaces();
			con.setNamespace("test", "urn:test:");
			con.commit();
		} finally {
			con.close();
		}
		ObjectRepositoryFactory factory = new ObjectRepositoryFactory();
		return factory.createRepository(config, repository);
	}

	@Before
	public void setUp() throws Exception {
		config.addConcept(Concept.class);
		repository = getRepository();
		con = (ObjectConnection) repository.getConnection();
		con.setAutoCommit(false);
		con.setNamespace("rdf", RDF.NAMESPACE);
		con.setNamespace("rdfs", RDFS.NAMESPACE);
		con.setAutoCommit(true);
	}

	@After
	public void tearDown() throws Exception {
		try {
			if (con.isOpen()) {
				con.close();
			}
			repository.shutDown();
		} catch (Exception e) {
		}
	}

	@Test
	public void testLiteral() throws Exception {
		concept = con.addDesignation(con.getObject("urn:test:concept"),
				Concept.class);
		assertEquals("http://example.com/", concept.literal().getFirstHeader("Location").getValue());
	}

	@Test
	public void testSubsitution() throws Exception {
		concept = con.addDesignation(con.getObject("http://www.example.com/pathinfo"),
				Concept.class);
		assertEquals("http://www.example.com/pathinfo#sub", concept.frag("sub").getFirstHeader("Location").getValue());
	}

	@Test
	public void testDomain() throws Exception {
		concept = con.addDesignation(con.getObject("http://www.example.com/pathinfo"),
				Concept.class);
		assertEquals("http://example.com/www/pathinfo", concept.readDomain("www", "pathinfo").getFirstHeader("Location").getValue());
	}

	@Test
	public void testQueryString() throws Exception {
		concept = con.addDesignation(con.getObject("http://www.example.com/pathinfo"),
				Concept.class);
		assertEquals("http://www.example.com/pathinfo?qs", concept.replaceQuery("qs").getFirstHeader("Location").getValue());
	}

	@Test
	public void testQueryParameter() throws Exception {
		concept = con.addDesignation(con.getObject("http://www.example.com/pathinfo"),
				Concept.class);
		assertEquals("http://www.example.com/pathinfo?param=foo%20bar", concept.param("foo bar").getFirstHeader("Location").getValue());
	}

	@Test
	public void testQueryParameterURIEncoding() throws Exception {
		concept = con.addDesignation(con.getObject("http://www.example.com/pathinfo"),
				Concept.class);
		assertEquals("http://example.com/%E2%9C%93", concept.resolve(URI.create("http://example.com/✓")).getFirstHeader("Location").getValue());
	}

}
