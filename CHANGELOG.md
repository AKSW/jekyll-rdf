# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

##[2.0.0] - 2017-03-29
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
