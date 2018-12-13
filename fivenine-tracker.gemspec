$: << File.expand_path('../lib', __FILE__)
require 'fivenine-tracker'

Gem::Specification.new do |s|
  s.name        = 'fivenine-tracker'
  s.version     = FiveNine::Tracker::VERSION
  s.date        = '2018-12-13'
  s.summary     = "SDK for 5x9 collection"
  s.description = "SDK for 5x9 collection"
  s.authors     = ["Bjorn Ramberg"]
  s.email       = 'bjorn@burtcorp.com'
  s.files       = ["lib/fivenine-tracker.rb", "lib/fivenine/tracker.rb"]
  s.homepage    = 'https://github.com/burtcorp/fivenine-tracker-rb'
  s.license       = 'MIT'
end
