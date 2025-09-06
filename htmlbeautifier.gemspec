# frozen_string_literal: true

require_relative "lib/htmlbeautifier/version"

Gem::Specification.new do |s|
  s.name        = "htmlbeautifier"
  s.version     = HtmlBeautifier::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.author      = "Paul Battley"
  s.email       = "pbattley@gmail.com"
  s.homepage    = "http://github.com/threedaymonk/htmlbeautifier"
  s.summary     = "HTML/ERB beautifier"
  s.description = "A normaliser/beautifier for HTML that also understands embedded Ruby."
  s.license     = "MIT"

  s.required_ruby_version = '>= 2.6.0'

  s.files = Dir['README.md', 'lib/**/*.rb', 'exe/*']

  s.bindir      = 'exe'
  s.executables = ['htmlbeautifier']

  s.add_development_dependency "rake", "~> 13"
  s.add_development_dependency "rspec", "~> 3"
  s.add_development_dependency "standard", "~> 1.33"
  s.add_development_dependency "rubocop-rspec", "~> 2"
  s.add_development_dependency "rubocop-rake", "~> 0.6"
end
