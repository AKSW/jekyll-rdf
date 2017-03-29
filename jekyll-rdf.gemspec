Gem::Specification.new do |s|
  s.name        = 'jekyll-rdf'
  s.version     = '2.0.0'
  s.date        = '2017-03-29'
  s.summary     = 'Hypertext Publication System for Templates Resource Rendering'
  s.description = 'Generate static sites with Jekyll based on RDF data'
  s.authors     = ['Elias Saalmann', 'Christian Frommert', 'Simon Jakobi', 'Arne Jonas Präger', 'Maxi Bornmann', 'Georg Hackel', 'Eric Füg', 'Sebastian Zänker', 'Natanael Arndt']
  s.email       = 'arndt@informatik.uni-leipzig.de'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/white-gecko/jekyll-rdf'
  s.license     = 'MIT'
  s.add_runtime_dependency 'linkeddata',          '~> 1.99'
  s.add_runtime_dependency 'sparql',              '~> 1.99'
  s.add_runtime_dependency 'jekyll',              '~> 3.1'
  s.add_runtime_dependency 'rake',                '~> 10.4'
  s.add_runtime_dependency 'coveralls',           '~> 0.8'
  s.add_runtime_dependency 'test-unit',           '~> 3.0'
  s.add_runtime_dependency 'shoulda-context',     '~> 1.1'
  s.add_development_dependency 'rspec',           '~> 3.0'
  s.add_development_dependency 'pry-byebug',      '~> 3.4'
end
