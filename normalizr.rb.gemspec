Gem::Specification.new do |s|
  s.name        = 'normalizr.rb'
  s.version     = '0.4.0'
  s.summary     = "Normalize deeply nested hash based on a schema"
  s.description = "Normalize deeply nested hash based on a schema"
  s.authors     = ["Christopher Okhravi"]
  s.files       = [
    "lib/normalizr/array_of.rb",
    "lib/normalizr/bag.rb",
    "lib/normalizr/normalizr.rb",
    "lib/normalizr/schema.rb",
    "lib/normalizr.rb",
  ]
  s.homepage    = 'https://github.com/chrokh/normalizr'
  s.license     = 'MIT'

  s.add_development_dependency 'rspec', '~> 3.0'
end
