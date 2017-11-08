# jekyll-rdf

A [Jekyll plugin](https://jekyllrb.com/docs/plugins/) for including RDF data in your static site.

[![Gem Version](https://badge.fury.io/rb/jekyll-rdf.svg)](https://badge.fury.io/rb/jekyll-rdf)
[![Build Status](https://travis-ci.org/white-gecko/jekyll-rdf.svg?branch=develop)](https://travis-ci.org/white-gecko/jekyll-rdf)
[![Coverage Status](https://coveralls.io/repos/github/white-gecko/jekyll-rdf/badge.svg?branch=develop)](https://coveralls.io/github/white-gecko/jekyll-rdf?branch=develop)

The API Documentation is available at [RubyDoc.info](http://www.rubydoc.info/gems/jekyll-rdf/).

# Contents

1. [Installation](#installation)
2. [Usage](#usage)
    1. [Integrate with Jekyll](#integrate-with-jekyll)
    2. [Make use of RDF data](#make-use-of-rdf-data)
    3. [Configuration](#configuration)
3. [Parameters and configuration options at a glance](#parameters-and-configuration-options-at-a-glance)
4. [Development](#development)
5. [License](#license)

# Installation

## Installation as a gem
The easiest and fastest way to install our project is the installation as a gem. The following command automatically installs the project and all required components such as Jekyll and the RDF-library
```
gem install jekyll-rdf
```

## Installation from source
To install the project with the git-repository you will need `git` on your system. The first step is just cloning the repository:
```
git clone git@github.com:white-gecko/jekyll-rdf.git
```
A folder named `jekyll-rdf` will be automatically generated. You need to switch into this folder and compile the ruby gem to finish the installation:
```
cd jekyll-rdf
gem build jekyll-rdf.gemspec
gem install jekyll-rdf -*.gem
```

# Usage
## Integrate with Jekyll
First, you need a jekyll page. In order to create one, just do:
```
jekyll new my_page
cd my_page
```

Further there are some parameters required in your `_config.yml` for `jekyll-rdf`. I.e. the `url` and `baseurl` parameters are used for including the resource pages into the root of the site, the plug-in has to be configured, and the path to the RDF file has to be present.

```yaml
url: "http://www.ifi.uio.no"
baseurl: "/INF3580"

plugins:
    - jekyll-rdf

jekyll_rdf:
    path: "simpsons.ttl"
```

Running `jekyll build` will render the RDF resources to the `_site/…` directory.
RDF resources whose IRIs don't start with the configured jekyll `url` and `baseurl` are rendered to the `_site/rdfsites/…` subdirectory.

*Note:* Since Jekyll 3.3.0 there is a special behavior of the `jekyll serve` command in a development environment.
Jekyll overwrites the `site.url` variable with your host and port reference, as [described in the Jekyll documentation](https://jekyllrb.com/docs/variables/#site-variables).
The behavior breaks the jekyll-rdf resource creation.
If you want to use `jekyll serve` you have to run `jekyll serve --skip-initial-build` or set `JEKYLL_ENV=production`.

## Make use of RDF data
### Templates
Now, create one or more files (e.g `rdf_index.html` or `person.html`) in the `_layouts`-directory to edit the temaplate for rdf-pages. For each resource a page will be rendered. See example below:

```html
---
layout: default
---
<div class="home">
  <h1 class="page-heading"><b>{{ page.rdf.iri }}</b></h1>
  <p>
    <h3>Statements in which {{ page.rdf.iri }} occurs as subject:</h3>
    {% include statements_table.html collection=page.rdf.statements_as_subject %}
  </p>
  <p>
    <h3>Statements in which {{ page.rdf.iri }} occurs as predicate:</h3>
    {% include statements_table.html collection=page.rdf.statements_as_predicate %}
  </p>
  <p>
    <h3>Statements in which {{ page.rdf.iri }} occurs as object:</h3>
    {% include statements_table.html collection=page.rdf.statements_as_object %}
  </p>
</div>
```

### Template Examples
We included some template examples at
* `test/source/_layouts/rdf_index.html`
* `test/source/_layouts/person.html`

### Get the IRI of a resource

    {{ page.rdf }}

Is the currently rendered resource.

    {{ page.rdf.iri }}

Returns the IRI of the currently rendered resource.

### Liquid Filters
To access objects which are connected to the current subject via a predicate you can use our custom liquid filters. For single objects or lists of objects use the `rdf_property`-filter (see [1](#single-objects) and [2](#multiple-objects)).

### Single Objects
To access one object which is connected to the current subject through a given predicate please filter `page.rdf` data with the `rdf_property`-filter. Example:
```
Age: {{ page.rdf | rdf_property: '<http://xmlns.com/foaf/0.1/age>' }}
```

### Optional Language Selection
To select a specific language please add a a second parameter to the filter:
```
Age: {{ page.rdf | rdf_property: '<http://xmlns.com/foaf/0.1/job>','en' }}
```

### Multiple Objects
To get more than one object connected to the current subject through a given predicate please use the filter `rdf_property` in conjunction with a third argument set to `true` (the second argument for the language can be omitted by setting it to `nil`):
```html
Sisters: <br />
{% assign resultset = page.rdf | rdf_property: '<http://www.ifi.uio.no/INF3580/family#hasSister>', nil, true %}
<ul>
{% for result in resultset %}
    <li>{{ result }}</li>
{% endfor %}
</ul>
```

### Optional Language Selection
To select a specific language please add a second parameter to the filter:
```html
Book titles: <br />
{% assign resultset = page.rdf | rdf_property: '<http://xmlns.com/foaf/0.1/currentProject>','de' %}
<ul>
{% for result in resultset %}
    <li>{{ result }}</li>
{% endfor %}
</ul>
```

### RDF Containers and Collections
To support [RDF Containers](https://www.w3.org/TR/rdf-schema/#ch_containervocab) and [RDF Collections](https://www.w3.org/TR/rdf-schema/#ch_collectionvocab) we provide the `rdf_container` and `rdf_collection` filters.

In both cases the respective container resource resp. head of the collection needs to be identified and then passed through the respective filter.
For containers we currently support explicit instances of `rdf:Bag`, `rdf:Seq` and `rdf:Alt` with the members identified using the `rdfs:ContainerMembershipProperty`s: `rdf:_1`, `rdf:_2`, `rdf:_3` ….
Collections are identified using `rdf:first`, `rdf:rest` and terminated with `L rdf:rest rdf:nil`.
Since the head of a collection needs to be identified you cannot use a blank node there, you can identify it indirectly through the predicate which contains the collection.

Example graph:

```
@prefix ex: <http://example.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .

ex:Resource ex:lists ex:List ;
            ex:directList ("hello" "from" "turtle") .
            ex:hasContainer ex:Container .

ex:List rdf:first "hello" ;
        rdf:rest ("rdf" "list") .

ex:Container a rdf:Bag ;
             rdf:_1 "hello" ;
             rdf:_2 "rdf" ;
             rdf:_3 "container" .
```

The template for `ex:Resource`:

```
{% assign list = page.rdf | rdf_collection: '<http://example.org/directList>' %}
<ol>
{% for item in list %}
<li>{{ item }}</li>
{% endfor %}
</ol>

{% assign container = page.rdf | rdf_property: '<http://example.org/hasContainer>' | rdf_container %}
<ul>
{% for item in container %}
<li>{{ item }}</li>
{% endfor %}
</ul>
```

### Custom SPARQL Query
We implemented a liquid filter `sparql_query` to run custom SPARQL queries. Each occurence of `?resourceUri` gets replaced with the current URI.
*Caution:* You have to separate query and resultset variables because of Liquids concepts. Example:
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
</table>
```

### Defining Prefixes for RDF
It is possible to declare a set of prefixes which can be used in the `rdf_property` and `sparql_query` liquid-filters.
This allows to shorten the amount of text required for each liquid-filter.
The syntax of the prefix declarations the same as for [SPARQL 1.1](https://www.w3.org/TR/2013/REC-sparql11-query-20130321/).
Just put your prefixes in a separate file and include the key `rdf_prefix_path` together with a relative path in the [YAML Front Matter](https://jekyllrb.com/docs/frontmatter/) of a file where your prefixes should be used.
The path gets resolved to `<your jekyll-directory>/rdf-data/<rdf_prefix_path>`.

For the prefixes the same rules apply as for other variables defined in the YAML Front Matter.
“These variables will then be available to you to access using Liquid tags both further down in the file and also in any layouts or includes that the page or post in question relies on.” (source: [YAML Front Matter](https://jekyllrb.com/docs/frontmatter/)).
This is especially relevant if you are using prefixes in includes.

## Configuration

### Map resources to templates
It is possible to map a specific class (resp. RDF-type) or individual resources to a template.
```yaml
  class_template_mappings:
      "http://xmlns.com/foaf/0.1/Person": "person.html"
  instance_template_mappings:
      "http://aksw.org/Team": "team.html"
```

A template mapped to a class will be used to render each instance of that class and its subclasses.
Each instance is rendered with its most specific class mapped to a template.
If the mapping is ambiguous for a resource, a warning will be output to your command window, so watch out!

It is also possible to define a default template, which is used for all resources, which are not covered by the `class_template_mappings` or `instance_template_mappings`.

```yaml
  default_template: "default.html"
```

### Dealing with Fragment Identifiers
If the URI of a resource contains a [fragment identifier (`#…`)](https://en.wikipedia.org/wiki/Fragment_identifier) the resource can be hosted together with other resources with the same base URI up to the fragment identifier on a single page.
The page will by accessible through the base URI, while in the template the individual URIs with a fragment identifier are accessible through the collection `page.sub_rdf`.

**Example**

In the `_config.yml`:
```yaml
  'instance_template_mappings' :
    'http://www.ifi.uio.no/INF3580/simpsons' : 'family.html'
```

In `_layouts/family.html`:
```html
  {% for member in page.sub_rdf%}
    {% include simPerson.html person = member%}
  {% endfor %}
```

The example uses the template `family.html` to render a single page containing every resource whose URI begins with `http://www.ifi.uio.no/INF3580/simpsons#`, was well as the resource `http://www.ifi.uio.no/INF3580/simpsons` itself.
Jekyll-rdf collects all resources with a fragment identifier in their URI (from here on called `subResources`) and passes them through `page.sub_rdf` into the templates of its `superResource` (resources whose base URI is the same as of its `subResources` except for the fragment identifier).

### Restrict resource selection
Additionally, you can restrict the overall resource selection by adding a SPARQL query as `restriction` parameter to `_config.yml`. Please use ?resourceUri as the placeholder for the resulting literal:
```yaml
  restriction: "SELECT ?resourceUri WHERE { ?resourceUri <http://www.ifi.uio.no/INF3580/family#hasFather> <http://www.ifi.uio.no/INF3580/simpsons#Homer> }"
```

There are 3 pre-defined keywords for restrictions implemented:
* `subjects` will load all subject URIs
* `predicates` will load all predicate URIs
* `objects` will load all object URIs

### Blank Nodes
Furthermore you can decide if you want to render blank nodes or not. You just need to add `include_blank`to `_config.yml`:
```yaml
jekyll_rdf:
  include_blank: true
```

### Preferred Language
Finally it is also possible to set a preferred language for the RDF-literals with the option `language`:
```yaml
jekyll_rdf:
  language: "en"
```

### Example configuration
An example configuration could look like this:
```yaml
jekyll_rdf:
  path: "rdf-data/simpsons.ttl"
  language: "en"
  include_blank: true
  restriction: "SELECT ?s WHERE { ?s ?p ?o}"
  default_template: "rdf_index.html"
  class_template_mappings:
    "http://xmlns.com/foaf/0.1/Person": "person.html"
  instance_template_mappings:
    "http://www.ifi.uio.no/INF3580/simpsons#Abraham": "abraham.html"
```

# Parameters and configuration options at a glance

## Resource
Every resource returned by one of `jekyll-rdf`s filters is an object that liquid can also handle like a string. They all have the following methods usable in Liquid.

### Resource.statements_as_subject
Return a list of statements whose subject is the current resource.
The statements in the returned list can be accessed by addressing their positions: `Statement.subject`, `Statement.predicate`, respective `Statement.object`.

### Resource.statements_as_predicate
Return a list of statements whose predicate is the current resource.
The statements in the returned list can be accessed by addressing their positions: `Statement.subject`, `Statement.predicate`, respective `Statement.object`.

### Resource.statements_as_object
Return a list of statements whose object is the current resource.
The statements in the returned list can be accessed by addressing their positions: `Statement.subject`, `Statement.predicate`, respective `Statement.object`.

### Resource.page_url
Return the URL of the page representing this RdfResource.

### Resource.render_path
Return the path to the page representing this RdfResource. Use it with care.

### Resource.covered
This method is relevant for rendering pages for IRIs containing a fragment identifier (`http://superresource#anchor`).
This method returns true for the super-resource (`http://superresource`) if it is actually described in the given knowledgebase.

### Resource.inspect
Returns a verbose String representing this resource.

## Liquid Filters
### rdf_get
**Synopsis:** `<resource_iri> | rdf_get`

**Parameters:**
- `<resource_iri>` is a string representing an RDF resource, with prefix (`prefix:name`) or a full IRI (`<http://ex.org/name>`). To reference the resource of the current page use `page.rdf`, `page`, or `nil`.

**Description:** Takes the provided IRI and returns the corresponding RdfResource object from your knowledge base.
On this object you can call the methods as described in the section [Resource](Resource).

**Example:**
```
{{'<http://www.ifi.uio.no/INF3580/simpsons>' | rdf_get }}
```

**Result:**
```html
http://www.ifi.uio.no/INF3580/simpsons
```

### rdf_property
**Synopsis:** `<rdf_resource> | rdf_property: <property>, [<lang>] OR [<lang>, <list>] OR [nil, <list>]`

**Parameters:**
- `<rdf_resource>` is an RdfResource. To reference the resource of the current page use `page.rdf`, `page`, or `nil`.
- `<property>` is a string representing an RDF predicate, with prefix (`prefix:name`) or a full IRI (`<http://ex.org/name>`).
- `<lang>` is a language tag (e.g. `de`). If this parameter is omitted replace it by `nil`.
- `<list>` is a boolean value (`true`, `false`).

**Description:** Returns the object, of the triple `<rdf_resource> <predicate> ?object`.
The returned object can by any of the kind, resource, literal, or blanknode.

**Example (default):**
```
{assign resource = '<http://www.ifi.uio.no/INF3580/simpsons#Homer>' | rdf_get }
{{ resource | rdf_property: '<http://xmlns.com/foaf/0.1/job>' }}
```
**Result:**
```html
"unknown"
  ```

**Example (with language):**
```
{assign resource = '<http://www.ifi.uio.no/INF3580/simpsons#Homer>' | rdf_get }
{{ resource | rdf_property: '<http://xmlns.com/foaf/0.1/job>', 'de' }}
```
**Result:**
```html
"unbekannt"
```

**Example (return as list):**
```
{assign resource = '<http://www.ifi.uio.no/INF3580/simpsons#Homer>' | rdf_get }
{% assign resultset = resource | rdf_property: '<http://xmlns.com/foaf/0.1/job>', nil, true %}
{% for result in resultset %}
<li>{{ result }}</li>
{% endfor %}
```
**Result:**
```html
<li>"unknown"</li>
<li>"unbekannt"</li>
<li>"unbekannter Job 2"</li>
<li>"unknown Job 2"</li>
```

### rdf_inverse_property
**Synopsis:** `<rdf_resource> | rdf_inverse_property: <property>, [<list>]`

**Parameters:**
- `<rdf_resource>` is an RdfResource. To reference the resource of the current page use `page.rdf`, `page`, or `nil`.
- `<property>` is a string representing an RDF predicate, with prefix (`prefix:name`) or a full IRI (`<http://ex.org/name>`).
- `<list>` is a boolean value (`true`, `false`).

**Description:** Same as rdf_property, but in inverse direction.
It returns the subject, of the triple `?subject <predicate> <rdf_resource>`.
The returned object can by any of the kind, resource, or blanknode.

**Examples (default):**
```
{assign resource = '<http://www.ifi.uio.no/INF3580/simpsons#Homer>' | rdf_get }
{{ page.rdf | rdf_inverse_property: '<http://www.ifi.uio.no/INF3580/family#hasFather>' }}
```
**Result:**
```html
http://www.ifi.uio.no/INF3580/simpsons#Bart
```

**Example (as list):**
```
{assign resource = '<http://www.ifi.uio.no/INF3580/simpsons#Homer>' | rdf_get }
{% assign resultset = resource | rdf_property: '<http://www.ifi.uio.no/INF3580/family#hasFather>', true %}
{% for result in resultset %}
<li>{{ result }}</li>
{% endfor %}
```
**Result:**
```html
http://www.ifi.uio.no/INF3580/simpsons#Bart
http://www.ifi.uio.no/INF3580/simpsons#Lisa
http://www.ifi.uio.no/INF3580/simpsons#Maggie
```

### sparql_query
**Synopsis:** `<rdf_resource> | sparql_query: <query>` **OR** `<reference_array> | sparql_query: <query>`

**Parameters:**
- `<rdf_resource>` is an RdfResource which will replace `?resourceUri` in the query. To omit this parameter or reference the resource of the current page use `page.rdf`, `page`, or `nil`.
- `<reference_array>` an array containing IRIs as Strings or `rdf_resource`. They will consecutive replace each `?resourceUri_<index>` in your query.
- `<query>` a string containing a SPARQL query.

**Description:** Evaluates `query` on the given knowledge base and returns an array of results (result set).
Each entry object in the result set (result) contains the selected variables as resources or literals.
You can use `?resourceUri` inside the query to reference the resource which is given as `<rdf_resource>`.

**Example (page)**
```
<!--Rendering the page of resource Lisa -->
{% assign query = 'SELECT ?sub ?pre WHERE { ?sub ?pre ?resourceUri }' %}
{% assign resultset = page | sparql_query: query %}
<table>
{% for result in resultset %}
  <tr><td>{{ result.sub }}</td><td>{{ result.pre }}</td></tr>
{% endfor %}
</table>
```
**Result:**
```html
<table>
<tr><td>http://www.ifi.uio.no/INF3580/simpsons#TheSimpsons</td><td>http://www.ifi.uio.no/INF3580/family#hasFamilyMember</td></tr>
<tr><td>http://www.ifi.uio.no/INF3580/simpsons#Bart</td><td>http://www.ifi.uio.no/INF3580/family#hasSister</td></tr>
<tr><td>http://www.ifi.uio.no/INF3580/simpsons#Maggie</td><td>http://www.ifi.uio.no/INF3580/family#hasSister</td></tr>
...
```

**Example (array)**
```
{% assign query = 'SELECT ?x WHERE {?resourceUri_0 ?x ?resourceUri_1}' %}
<!-- something that creates array = ["<http://www.ifi.uio.no/INF3580/simpsons#Homer>", "<http://www.ifi.uio.no/INF3580/simpsons#Marge>"] -->
{% assign resultset = array | sparql_query: query %}
<table>
{% for result in resultset %}
  <tr><td>{{ result.x }}</td></tr>
{% endfor %}
</table>
```
**Result:**
```
<table>
  <tr><td>http://www.ifi.uio.no/INF3580/family#hasSpouse</td></tr>
</table>
```

### rdf_container
**Synopsis:** `<rdf_container_head> | rdf_container`

**Parameters:**
- `<rdf_container_head>` is an RdfResource. To reference the resource of the current page use `page.rdf`, `page`, or `nil`.

**Description:** Returns an array with resources for each element in the container whose head is referenced by `rdf_container_head`.

**Examples:**
```
{% assign resource = '<http://www.ifi.uio.no/INF3580/simpson-container#Container>' | rdf_get %}
{% assign array = resource | rdf_container %}
{% for item in array %}
{{ item }}
{% endfor %}
```
###### Result:
```html
http://www.ifi.uio.no/INF3580/simpsons#Homer
http://www.ifi.uio.no/INF3580/simpsons#Marge
http://www.ifi.uio.no/INF3580/simpsons#Bart
http://www.ifi.uio.no/INF3580/simpsons#Lisa
http://www.ifi.uio.no/INF3580/simpsons#Maggie

```

### rdf_collection
**Synopsis:** `<rdf_collection_head> | rdf_collection` or `<rdf_resource> | rdf_collection: "<property>"`

**Parameters:**
- `<rdf_collection_head>` is an RdfResource. To reference the resource of the current page use `page.rdf`, `page`, or `nil`.

- `<rdf_resource>` is an RdfResource. To reference the resource of the current page use `page.rdf`, `page`, or `nil`.
- `<property>` is a string representing an RDF predicate, with prefix (`prefix:name`) or a full IRI (`<http://ex.org/name>`).

**Description:** Returns an array with resources for each element in the collection whose head is referenced by `rdf_collection_head`.
Instead of directly referencing a head it is also possible to specify the property referencing the collection head.

**Example (specify head resource):**
```
{% assign resource = '<http://www.ifi.uio.no/INF3580/simpson-collection#Collection>' | rdf_get %}
{% assign array = resource | rdf_collection %}
{% for item in array %}
{{ item }}
{% endfor %}
```
**Result:**
```html
http://www.ifi.uio.no/INF3580/simpsons#Homer
http://www.ifi.uio.no/INF3580/simpsons#Marge
http://www.ifi.uio.no/INF3580/simpsons#Bart
http://www.ifi.uio.no/INF3580/simpsons#Lisa
http://www.ifi.uio.no/INF3580/simpsons#Maggie
```

**Example (specify via property):**
```
{% assign resource = '<http://www.ifi.uio.no/INF3580/simpsons>' | rdf_get %}
{% assign array = resource | rdf_collection: "<http://www.ifi.uio.no/INF3580/simpsons#familycollection>" %}
{% for item in array %}
{{ item }}
{% endfor %}
```
**Result:**
```html
http://www.ifi.uio.no/INF3580/simpsons#Homer
http://www.ifi.uio.no/INF3580/simpsons#Marge
http://www.ifi.uio.no/INF3580/simpsons#Bart
http://www.ifi.uio.no/INF3580/simpsons#Lisa
http://www.ifi.uio.no/INF3580/simpsons#Maggie
```

## Plugin Configuration (\_config.yml)
|Name|Parameter|Default|Description|Example|
|---	|---	|---	|---	|---	|
|path|Relative path to the RDF-File|no default|Specifies the path to the RDF file you want to render the website for|```path: "rdf-data/simpsons.ttl"```|
|language|Language-Tag as String|no default|Specifies the preferred language when you select objects using our Liquid filters|```language: "en"```|
|include_blank|Boolean-Expression|false|Specifies whether blank nodes should also be rendered or not|```include_blank: true```|
|restriction|SPARQL-Query as String or subjects / objects / predicates|no default|Restricts the resource-selection with a given SPARQL-Query or the three keywords subjects (only subject URIs), objects, predicates|```restriction: "SELECT ?resourceUri WHERE { ?resourceUri <http://www.ifi.uio.no/INF3580/family#hasFather> <http://www.ifi.uio.no/INF3580/simpsons#Homer> }"```|
|default_template|Filename of the default RDF-template in _layouts directory|no default|Specifies the template-file you want Jekyll to use to render all RDF resources|```default_template: "rdf_index.html"```|
|instance_template_mappings|Target URI as String : filename of the template as String|no default|Maps given URIs to template-files for rendering an individual instance|```instance_template_mappings: "http://www.ifi.uio.no/INF3580/simpsons#Abraham": "abraham.html"```|
|class_template_mappings|Target URI as String : filename of the template as String|no default|Maps given URIs to template-files for rendering all instances of that class|```class_template_mappings: "http://xmlns.com/foaf/0.1/Person": "person.html"```|

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

## Build API Doc
To generate the API Doc please navigate to `jekyll-rdf/lib` directory and run
```
gem install yard
yardoc *
```

The generated documentation is placed into `jekyll-rdf/lib/doc` directory.

# License
jekyll-rdf is licensed under the [MIT license](https://github.com/DTP16/jekyll-rdf/tree/master/LICENSE).
