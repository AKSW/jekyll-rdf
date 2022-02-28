# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [3.1.2] - ???
### changed
- Repository moved from https://github.com/white-gecko/jekyll-rdf/ to https://github.com/AKSW/jekyll-rdf/
- Add possibility to specify the default graph on a SPARQL endpoint
- Some updates in the test/build system
- Update some dependencies
- Minor code cleanup
- New `resource.rendered` attribute to check if a page is rendered in the present site for this resource.
- Update class-template selection to be straightforward
- Update dependencies
- Remove some warnings
- Works with ruby 3

## [3.1.0] - 2018-11-27
### Added
- Allow building sites from a (remote) SPARQL endpoint by setting `remote:\n endpoint: <endpointuri>` in the `_config.yml`. (Currently only querying the default default-graph ;-). Specifying the default graph, with `FROM` resp. `default-graph-uri` will come in the future, https://github.com/white-gecko/jekyll-rdf/pull/220.)
- Specify the list of resources to be rendered, in a file by setting `restriction_file: <filename>` in the `_config.yml`.
- Add hooks for posts and documents to also use the RDF context there.

### Changed
- Show debug messages only if JEKYLL_ENV is set to development
- Reduce template mapping output

### Fixed
- Fix error if prefixes are requested before the page hook

## [3.0.0] - 2018-10-20
The major revision with a lot of changes as a [birthday present](https://twitter.com/jekyllrb/status/1053579886516936704) for [jekyll's](https://jekyllrb.com/).
For a full list of the changes check out the [pullrequest](https://github.com/white-gecko/jekyll-rdf/pull/140): [Commits (140)](https://github.com/white-gecko/jekyll-rdf/pull/140/commits), [Files changed (236)](https://github.com/white-gecko/jekyll-rdf/pull/140/files) and the [3.0.0 milestone](https://github.com/white-gecko/jekyll-rdf/milestone/5?closed=1).
If you have trouble transitioning from Jekyll RDF 2.x to 3.0 please check our documentation of the filters in the README.
If you think we made some mistakes please help us be sending [pull requests](https://github.com/white-gecko/jekyll-rdf/pulls) or filling an [issue](https://github.com/white-gecko/jekyll-rdf/issues).

### Added
- You can now omit `page.rdf` for some filters and just pass `nil`, which will default to the current pages RDF resource.
- The JekyllRDF filters can now also be used on standard Jekyll pages which are not created by JekyllRDF.
- Allow embedding of Jekyll pages into JekyllRDF pages which are mapped to the same URL. (This currently only works properly with HTML pages, MD is not rendered in this case.)
- New config parameter `baseiri` which defines the namespace from which the resources are interpreted independently from jekylls standard `baseurl` and `url` parameters.
- Support for gem based themes (https://jekyllrb.com/docs/themes/). The first one is (https://rubygems.org/gems/jekyll-theme-jod).

### Changed
- A lot under the hood.
- Improved documentation in the README.
- Make the URI mapping of RDF resources to Jekyll pages neat and more predictive, or logically (as you like to see it) this involves the mappings described in https://github.com/white-gecko/jekyll-rdf/issues/94, https://github.com/white-gecko/jekyll-rdf/issues/78, and https://github.com/white-gecko/jekyll-rdf/issues/82.
- `sparql_query` now accepts arrays, this allows to specify multiple variables to be replaced by the arrays content using the variables `?resourceUri_0`, `?resourceUri_1` and so on.
- Prefix paths don't need to be in the `rdf-data/` folder but can be anywhere. The `rdf_prefix_path` is no longer interpreted relative to `rdf-data/`. We rather recommend to place it in `_data`.
- All filters now also accept URI-strings as input e.g. `{{ <http://example.org/resource> | rdf_property: … }}`.
- `rdf_container` filter can now also be called using a property as it is possible for `rdf_collection`.

### Fixed
- Fix behavior of URI mapping when it was disturbed by the Jekyll permalink settings.
- Prefix definition files can now contain empty lines.
- Fix behavior in development mode, when the `site.url` is set to http://localhost:4000 (https://jekyllrb.com/news/#3-siteurl-is-set-by-the-development-server).
- Usage of math filters and some other standard liquid filters.
- Interpret graph path relative to source path and not the current working directory.

## [2.3.0] - 2017-10-23
### Added
- Add convenient method to parse collections starting with a blank node, using the `rdf_collection` filter.

### Fixed
- Fix Jekyll warning about config syntax change. Replace `gems` by `plugins` in test `_config.yml`.

## [2.2.0] - 2017-09-07
### Added
- Add new filter `rdf_get` to create new instances of `RdfResource` within liquid
- Add `.inspect` method for `RdfResource`
- Add support for equality operators on `RdfResource`

### Fixed
- Fix build process and don't fail if a class in the mapping doesn't exist in the RDF model
- Fix/Improve description for `jekyll build` vs `jeykll serve` in README

## [2.1.2] - 2017-08-18
### Fixed
- Fix `render_path` and `page_url` attributes of resources
- Fix release builds with travis for rubygems

## [2.1.1] - 2017-08-03
### Fixed
- Fix support for RDF Containers and Collections: subclasses of rdfs:Container can be used now and containers are ordered

## [2.1.0] - 2017-07-19
### Added
- Automated pre-release builds with travis and rubygems
- Support for RDF Containers and Collections with the `rdf_container` and `rdf_collection` filters
- Add `rdf_inverse_property` filter to follow incoming triples
- README Add documentation for `rdf_container` and `rdf_collection` filters
- README Add documentation for `rdf_inverse_property` filter

### Changed
- Dependencies: `linkeddata` ~>1.99 -> ~>2.0, `sparql` ~>1.99 -> ~>2.2, >=2.2.1
- Move some dependencies to development section
- README general improvements
- README: Adjust usage of the `rdf_property` filter
- README: Add documentation for prefix handling
- Naming conventions, use underscore instead of camel caps
- Always write resources and properties in `<…>` to distinguish them from prefixed qnames `rdf_property`
- A `default_template` in the configuration is not mandatory anymore, there will only be a warning if it is needed
- Improve prefix handling
- General code refactoring
- Some more tests
- `rdf.foafName` does not exist anymore

### Fixed
- README: Fix documentation for template mapping
- README: Fix doucmentation of fragment identifier support
- Support for umlauts in URLs
- Fix usage of jekyll `site.url` and `site.baseurl`
- Fix class and instance template mapping
- Fix handling of blank nodes for page generation
- Fix Cangelog formating for 2.0.0 ;-)

## [2.0.0] - 2017-03-29
### Added
- jekyll-rdf now distinguishes between instance resources and class resources
- jekyll-rdf can now host URIs which differ only in its fragment identifiers on one page
- RDF QName handling
- Show warning if jekyll-rdf is not configured but included
- Properly serving hash-URIs (`#`). All URIs differing only in the fragment are mapped to the same page.
- Define namespace prefixes in template header using `rdf_prefix_path`
- Add warning if multiple class template mappings exist and produce candidates for rendering a resource

### Changed
- `template_mapping` is now replaced by `class_template_mapping` and `instance_template_mapping`. An error is raised for old configuration format.
- just printing a resource will print its URI instead of its full name
- the app will tell the user if he uses an outdated configuration
- `rdf_property_list` is now integrated into `rdf_property`
- the `foaf:name` of each resource gets no longer printed automatically, use `rdf.foafName` to get the `foafName`
- remove unused code
- changed README.md to mirror new version and the API changes

### Fixed
- Tests will no longer fail, fix test coverage
- Serving resources under configured URL
- Fix URI and title handling by replacing `to_s` method by `iri` method. Titles have to be retrieved using property filter.
- Fix infinite loop for `name` method in combination with `foaf:name`
- Filter URI in `_config.yml` doesn't influence RDF-class hierarchy anymore
- Fix language handling for `rdf_property`
- (Serving Resources with ending with slash)

## [1.2.0] - ????-??-?? [YANKED]
### Changed
- URIs and their corresponding resources are now rendered bejective
- reduces the number of iterations for the rdf_property filter and fixed a bug that made it crash

## [1.1.0] - 2016-06-08
### Added
- jekyll-rdf can render URIs through a mapping in the _config.yml file under the use of template_mapping
- README.md that explains every step
