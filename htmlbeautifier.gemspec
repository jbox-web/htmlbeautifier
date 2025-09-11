# frozen_string_literal: true

require_relative "lib/html_beautifier/version"

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

  s.required_ruby_version = ">= 3.2.0"

  s.files = Dir["README.md", "LICENSE", "lib/**/*.rb", "exe/*"]

  s.bindir      = "exe"
  s.executables = ["htmlbeautifier"]

  s.add_dependency "zeitwerk"
end
