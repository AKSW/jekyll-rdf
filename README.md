# jekyll-rdf
[![Build Status](https://travis-ci.org/DTP16/jekyll-rdf.png?branch=develop)](https://travis-ci.org/DTP16/jekyll-rdf) [![Coverage Status](https://coveralls.io/repos/github/DTP16/jekyll-rdf/badge.png?branch=develop)](https://coveralls.io/github/DTP16/jekyll-rdf?branch=develop)

A [Jekyll plugin](https://jekyllrb.com/docs/plugins/) for including RDF data in your static site.

# Installation
Since jekyll-rdf is still under development, this gem must be built by yourself:
```
git clone git@github.com:DTP16/jekyll-rdf.git
cd jekyll-rdf
gem build jekyll-rdf.gemspec
gem install ./jekyll-rdf-0.0.0.gem
```

# Usage
## Integrate with Jekyll
First, you need a jekyll page. In order to create one, just do:
```
jekyll new my_page
cd my_page
```
Add `jekyll-rdf` to your `_config.yml`:
```yaml
gems: [jekyll-rdf]
```
Specify path to your Turtle-File in `_config.yml`:
```yaml
jekyll_rdf:
  path: "simpsons.ttl"
```

## Make use of RDF data

Now, create one or more files (e.g "rdf_index.html" or "person.html") in _layouts - directory to edit the layout for rdf-pages. For each resource a page will be rendered. See example below:

```html
---
layout: default
---

<div class="home">

  <h1 class="page-heading"><b>{{ page.rdf.name }}</b></h1>

  <p>
    <h3>Statements in which {{ page.rdf.name }} occurs as subject:</h3>
    {% include statements_table.html collection=page.rdf.statements_as_subject %}
  </p>
  <p>
    <h3>Statements in which {{ page.rdf.name }} occurs as predicate:</h3>
    {% include statements_table.html collection=page.rdf.statements_as_predicate %}
  </p>
  <p>
    <h3>Statements in which {{ page.rdf.name }} occurs as object:</h3>
    {% include statements_table.html collection=page.rdf.statements_as_object %}
  </p>

</div>
```

To access objects which are connected to the current subject via a predicate you can use our custom liquid filters. For only one object please use property,
for a list of properties you can use property_list. Example:

```html

<table>
  <tbody>
    <tr>
      {% assign result = page.rdf | rdf_property: 'http://xmlns.com/foaf/0.1/age' %}
      <td>Age</td>
      <td>{{ result }} </td>
    <tr>
    <tr>
       <td>Sisters</td>
       <td>
       {% assign resultset = page.rdf | rdf_property_list: 'http://www.ifi.uio.no/INF3580/family#hasSister' %}
       <ul>
       {% for result in resultset %}
          <li>{{ result }}</li>
       {% endfor %}
       </ul>
       </td>
    </tr>
  </tbody
</table>
```

We implemented a liquid filter to run custom SPARQL queries. Each occurence of `?resourceUri` gets replaced with the current URI.
*Hint:* You have to separate query and resultset variables because of Liquids concepts. Example:

```html
{% assign query = 'SELECT ?sub ?pre WHERE { ?sub ?pre ?resourceUri }' %}
{% assign resultset = page.rdf | sparql_query: query %}
<table>
{% for result in resultset %}
  <tr>
    <td>{{ result.sub }}</td>
    <td>{{ result.pre }}</td>
  </tr>
{% endfor %}
</table
```

## Set default template and map templates to resources

Ii is possible to map to a specific ressource, type or superclass
```yaml
  'default_template' => 'rdf_index.html',
  'template_mappings' => {
    'http://xmlns.com/foaf/0.1/Person' => 'person.html',
    'http://www.ifi.uio.no/INF3580/simpsons#Abraham' => 'abraham.html'
  }
```

## Restrict resource selection
Additionaly, you can restrict the overall resource selection by adding a SPARQL query as `restriction` parameter to `_config.yml`. Please use ?resourceUri as the placeholder for the resulting literal:
```yaml
  restriction: "SELECT ?resourceUri WHERE { ?resourceUri <http://www.ifi.uio.no/INF3580/family#hasFather> <http://www.ifi.uio.no/INF3580/simpsons#Homer> }"
```
There are 3 pre-defined keywords for restrictions implemented:
* `subjects` will load all subject URIs
* `predicates` will load all predicate URIs
* `objects` will load all object URIs

# Development
## Run tests
```
bundle exec rake test
```
## Test page
Everytime the tests are executed, the Jekyll page inside of `test/source` gets processed. Start a slim web server to watch the results in web browser, e.g. Pythons `SimpleHTTPServer` (Python 2, for Python 3 it's `http.server`):
```
cd test/source/_site
python -m SimpleHTTPServer 8000
```
