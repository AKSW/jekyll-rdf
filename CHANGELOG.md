# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

##[2.0.0] - ????-??-?? [COMING]
### Added
- jekyll-rdf now distingishes between instance resources and class resources
- jekyll-rdf can now host uris which differ only in its fragment identifiers on one page

### Changed
- template_mapping is now replaced by class_template_mapping and instance_template_mapping
- just printing a resource will print its URI instead of its full name
- changed README.md to mirror the API changes
- the app will tell the user if he uses an outdated configuration
- rdf_property_list is now integrated into rdf_property
- the foaf:Name of each resource gets no longer printed automatically, use rdf.foafName to get the foafName

### Fixed
- Tests will no longer fail

## [1.2.0] - ????-??-?? [YANKED]
### Changed
- URIs and their corresponding resources are now rendered bejective
- reduces the number of iterations for the rdf_property filter and fixed a bug that made it crash

## [1.1.0] - 2016-06-08
### Added
- jekyll-rdf can render URIs through a mapping in the _config.yml file under the use of template_mapping
- README.md that explains every step
