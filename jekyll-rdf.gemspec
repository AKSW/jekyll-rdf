# coding: utf-8
VERSION = '3.2.0'
RELEASE_VERSION = case
    when ENV['TRAVIS'] && ENV['TRAVIS_BRANCH'].match(/^master$/i) then "#{VERSION}"
    when ENV['TRAVIS'] && ENV['TRAVIS_BRANCH'].match(/^develop$/i) then "#{VERSION}-#{ENV['TRAVIS_BRANCH']}.#{ENV['TRAVIS_BUILD_NUMBER']}"
    else "#{VERSION}-local"
end

Gem::Specification.new do |s|
  s.name        = 'jekyll-rdf'
  s.version     = RELEASE_VERSION.to_s
  s.summary     = 'Hypertext Publication System for Templated Resource Rendering'
  s.description = 'Generate static sites with Jekyll based on RDF data'
  s.authors     = ['Elias Saalmann', 'Christian Frommert', 'Simon Jakobi', 'Arne Jonas Präger', 'Maxi Bornmann', 'Georg Hackel', 'Eric Füg', 'Sebastian Zänker', 'Natanael Arndt', 'Simon Bin', 'Jan Beckert']
  s.email       = 'arndt@informatik.uni-leipzig.de'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/AKSW/jekyll-rdf'
  s.license     = 'MIT'
  s.add_runtime_dependency 'linkeddata',           '~> 3.2', '>= 3.2.0'
  s.add_runtime_dependency 'sparql-client',        '~> 3.2', '>= 3.2.0'
  s.add_runtime_dependency 'jekyll',               '>= 4.2', '>= 4.2.1'
  s.add_development_dependency 'rake',             '~> 13.0'
  s.add_development_dependency 'rest-client',      '~> 2.0', '>= 2.0.1'
  s.add_development_dependency 'coveralls',        '~> 0.8'
  s.add_development_dependency 'test-unit',        '~> 3.0'
  s.add_development_dependency 'shoulda-context',  '~> 1.1'
  s.add_development_dependency 'rspec',            '~> 3.0'
  s.add_development_dependency 'pry-byebug',       '~> 3.4'
  s.add_development_dependency 'rdoc',             '~> 6.2', '>= 6.2.1'
  #s.add_development_dependency 'jekyll-theme-jod', '~> 0.1.5'
  s.add_development_dependency 'kramdown-parser-gfm', '~> 1.1'
end
