# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gtfs/realtime/version'

Gem::Specification.new do |spec|
  spec.name          = "gtfs-realtime"
  spec.version       = GTFS::Realtime::VERSION
  spec.authors       = ["Ryan Laughlin"]
  spec.email         = ["me@rofreg.com"]

  spec.summary       = %q{GTFS Realtime wrapper}
  spec.description   = %q{A gem to interact with realtime transit data presented in the GTFS Realtime format (https://developers.google.com/transit/gtfs-realtime/).}
  spec.homepage      = "https://github.com/rofreg/gtfs-realtime"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock"

  spec.add_dependency "gtfs-realtime-bindings"
  spec.add_dependency "gtfs"
  spec.add_dependency "sequel"
end
