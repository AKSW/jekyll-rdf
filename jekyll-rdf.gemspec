VERSION = '2.3.0'
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
  s.authors     = ['Elias Saalmann', 'Christian Frommert', 'Simon Jakobi', 'Arne Jonas Präger', 'Maxi Bornmann', 'Georg Hackel', 'Eric Füg', 'Sebastian Zänker', 'Natanael Arndt', 'Simon Bin']
  s.email       = 'arndt@informatik.uni-leipzig.de'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/white-gecko/jekyll-rdf'
  s.license     = 'MIT'
  s.add_runtime_dependency 'linkeddata',          '~> 2.0'
  s.add_runtime_dependency 'sparql',              '~> 2.2', '>= 2.2.1'
  s.add_runtime_dependency 'jekyll',              '~> 3.1'
  s.add_development_dependency 'rake',            '~> 10.4'
  s.add_development_dependency 'coveralls',       '~> 0.8'
  s.add_development_dependency 'test-unit',       '~> 3.0'
  s.add_development_dependency 'shoulda-context', '~> 1.1'
  s.add_development_dependency 'rspec',           '~> 3.0'
  s.add_development_dependency 'pry-byebug',      '~> 3.4'
end
