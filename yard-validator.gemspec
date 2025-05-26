# frozen_string_literal: true

require_relative 'lib/yard/validator/version'

Gem::Specification.new do |spec|
  spec.name = 'yard-validator'
  spec.version = Yard::Validator::VERSION
  spec.authors = ['Tesorion']
  spec.email = ['QmanageDevelopment@tesorion.nl']

  spec.summary = 'Validate YARD signatures'
  spec.homepage = 'https://github.com/tesorion/typeguard'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dry-configurable'
  spec.add_dependency 'rbs'
  spec.add_dependency 'sqlite3'
  spec.add_dependency 'yard'
  spec.add_dependency 'zeitwerk', '~> 2.6.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
