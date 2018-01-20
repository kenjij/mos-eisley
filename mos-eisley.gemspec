$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'mos-eisley/version'


Gem::Specification.new do |s|
  s.name          = 'mos-eisley'
  s.version       = MosEisley::VERSION
  s.authors       = ['Ken J.']
  s.email         = ['kenjij@gmail.com']
  s.summary       = %q{A Ruby based multi-purpose Slack app server}
  s.description   = %q{A Ruby based HTTP server for Slack app actions, commands, events, and making web API calls.}
  s.homepage      = 'https://github.com/kenjij/mos-eisley'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.1'
  s.add_runtime_dependency 'em-http-request', '~> 1.1'
  s.add_runtime_dependency 'kajiki', '~> 1.1'
  s.add_runtime_dependency 'sinatra', '~> 2.0'
  s.add_runtime_dependency 'thin', '~> 1.7'
end
