# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).


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
