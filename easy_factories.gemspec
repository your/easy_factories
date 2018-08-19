lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_factories/version'

Gem::Specification.new do |spec|
  spec.name          = 'easy_factories'
  spec.version       = EasyFactories::VERSION
  spec.authors       = ['Giuseppe Lobraico']
  spec.email         = ['g.lobraico@gmail.com']

  spec.summary       = 'Easy Factories for ActiveModel and Dry::Struct objects.'
  spec.description   = spec.description
  spec.homepage      = 'https://github.com/your/easy_factories'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.58.2'

  spec.add_development_dependency 'activemodel', '~> 5.2.1'
  spec.add_development_dependency 'dry-struct', '~> 0.5.1'
end
