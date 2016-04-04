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
Now, you can access a collection of all RDF statements in your ERB templates:

```html
<table>
  {% for statement in site.data.rdf %}
    <tr>
      <td>{{ statement[0] }}</td> <!-- Subject -->
      <td>{{ statement[1] }}</td> <!-- Predicate -->
      <td>{{ statement[2] }}</td> <!-- Object -->
    </tr>
  {% endfor %}
</table>
```

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

