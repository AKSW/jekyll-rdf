# jekyll-rdf
[![Build Status](https://travis-ci.org/white-gecko/jekyll-rdf.png?branch=develop)](https://travis-ci.org/white-gecko/jekyll-rdf)
[![Coverage Status](https://coveralls.io/repos/github/white-gecko/jekyll-rdf/badge.png?branch=develop)](https://coveralls.io/github/white-gecko/jekyll-rdf?branch=develop)
A [Jekyll plugin](https://jekyllrb.com/docs/plugins/) for including RDF data in your static site.

The API Documentation is available at [http://www.rubydoc.info/gems/jekyll-rdf/](http://www.rubydoc.info/gems/jekyll-rdf/).<br />
For additional documentation please have a look at [http://rubygems.org/gems/jekyll-rdf](http://rubygems.org/gems/jekyll-rdf)
# Installation
## Installation as a gem
The easiest and fastest way to install our project is the installation as a gem. The following command automatically installs the project and all required components such as Jekyll and the RDF-library
```
gem install jekyll-rdf
```
## Installation with the git-repository
To install the project with the git-repository you will need `git` on your system. The first step is just cloning the repository:
```
git clone git@github.com:DTP16/jekyll-rdf.git
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
Add `jekyll-rdf` to your `_config.yml`:
```yaml
gems: [jekyll-rdf]
```
Specify path to your RDF-File in `_config.yml`:
```yaml
jekyll_rdf:
  path: "simpsons.ttl"
```

Running `jekyll build` will render the RDF resources to `_site/rdfsites/…` for including resource pages into the root of the site you have to specify the `url:` and `baseurl:` parameters of the jekyll configuration accordingly.

In the example of the simpsons model it could be:
```yaml
baseurl: "/INF3580"
url: "http://www.ifi.uio.no"
```

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
```html
Age: {{ page.rdf | rdf_property: 'http://xmlns.com/foaf/0.1/age' }}
```
### Optional Language Selection
To select a specific language please add a a second parameter to the filter:
```html
Age: {{ page.rdf | rdf_property: 'http://xmlns.com/foaf/0.1/job','en' }}
```
### Multiple Objects
To get more than one object connected to the current subject through a given predicate please use the filter `rdf_property` in conjunction with a third argument set to `true` (the second argument for the language can be omitted by setting it to `nil`):
```html
Sisters: <br />
{% assign resultset = page.rdf | rdf_property: 'http://www.ifi.uio.no/INF3580/family#hasSister', nil, true %}
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
{% assign resultset = page.rdf | rdf_property: 'http://xmlns.com/foaf/0.1/currentProject','de' %}
<ul>
{% for result in resultset %}
    <li>{{ result }}</li>
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
It is possible to pre define a set of prefixes for the use in `rdf_property` and `sparql_query`, shortening the amount of text required for each filter. Just define your prefixes in a separate file and include the key `rdf_prefix_path` together with a relative path in the yaml-frontmatter of every layout you want to use your prefixes for. The path gets resolved to `/your/jekyll-directory/rdf-data/rdf_prefix_path`. The format of this prefix file should correspond to the ttl-format.
It is also adviced to always enclose complete (without prefixes) URIs in `<` and `>` before passing them to `rdf_property` or `sparql_query`, otherwise an exception (UnMarkedUri) will be thrown.

## Configuration
### Set default template and map templates to resources
It is possible to map to a specific ressource, type or superclass
```yaml
  'default_template' => 'rdf_index.html',
  'class_template_mappings' => {
    'http://xmlns.com/foaf/0.1/Person' => 'person.html'
  },
  'instance_template_mappings' => {
    'http://www.ifi.uio.no/INF3580/simpsons#Abraham' => 'abraham.html'
  }
```
A template mapped to a class will be used to render each instance of that class and its subclasses.
Each instance is rendered with its most specific class mapped to a template.
If the mapping is ambigiuous for one resource, a warning will be output to your command window, so watch out!

### Host different resources through a single Host page
If the URI of a resource contains a fragment identifier the resource can be hosted together with other resources with the same URI on a single page. To activate this feature `use_hash_gathering` has to be set to true in the `_config.yml` file.
```yaml
  'instance_uri_template_mappings' => {
    'http://www.ifi.uio.no/INF3580/simpsons#' => 'family.html'
  }
```

```html
  {% for member in page.sub_rdf%}
    {% include simPerson.html person = member%}
  {% endfor %}
```
The example above uses the template `family.html` to render a single page containing every resource whose URI begins with `http://www.ifi.uio.no/INF3580/simpsons#`. Jekyll-rdf collects all resources with a fragment indetifier in their URI (from here on called `subResources`) and passes them through `page.sub_rdf` into the templates of its superResource (resources whose URIs are equal to its subResources, but do not contain a fragment identifier).
To render resources with a fragment identifier without a rendered superResource, set `render_orphaned_uris` to `true`.

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
## Liquid Filters
|Name|Parameter|Optional Parameter|Optional Flag|Description|Example|
|---	|---	|---    |---	|---	|---	|
|rdf_property|predicate-URI as String|language-tag as String|true to get a list|Returns a single object or an array with objects which are connected to the current subject through a given predicate|```{{ page.rdf \| rdf_property: 'http://xmlns.com/foaf/0.1/job','en' }}``` ```{% assign resultset = page.rdf \| rdf_property: 'http://xmlns.com/foaf/0.1/currentproject','en', true %}{% for result in resultset %}<li>{{ result }}</li>{% endfor %}```|
|sparql_query|SPARQL-Query as String|-|-|Runs a SPARQL-Query with the current subject as ?resourceURI|```{% assign query = 'SELECT ?sub ?pre WHERE { ?sub ?pre ?resourceUri }' %}{% assign resultset = page.rdf \| sparql_query: query %}<table>{% for result in resultset %}<tr><td>{{ result.sub }}</td><td>{{ result.pre }}</td></tr>{% endfor %}</table>```|
## Plugin Configuration (\_config.yml)
|Name|Parameter|Default|Description|Example|
|---	|---	|---	|---	|---	|
|path|Relative path to the RDF-File|no default|Specifies the path to the RDF file you want to render the website for|```path: "rdf-data/simpsons.ttl"```|
|language|Language-Tag as String|no default|Specifies the preferred language when you select objects using our Liquid filters|```language: "en"```|
|include_blank|Boolean-Expression|false|Specifies whether blank nodes should also be rendered or not|```include_blank: true```|
|render_orphaned_uris|Boolean-Expression|false|Decide to render resources referenced by URI fragment identifier without a container URI (or not)|```render_orphaned_uirs: true```|
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
