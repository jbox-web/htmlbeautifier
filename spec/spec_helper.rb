# frozen_string_literal: true

require "simplecov"
require "simplecov_json_formatter"

# Start SimpleCov
SimpleCov.start do
  formatter SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::JSONFormatter])
  add_filter "spec/"
end

module HtmlBeautifierSpecUtilities
  def code(str)
    str = str.gsub(%r{\A\n|\n\s*\Z}, "")
    indentation = str[%r{\A +}]
    lines = str.split(%r{\n})
    lines.map { |line| line.sub(%r{^#{indentation}}, "") }.join("\n")
  end
end

# Configure RSpec
RSpec.configure do |config|
  config.include HtmlBeautifierSpecUtilities

  config.color = true
  config.fail_fast = false

  config.order = :random
  Kernel.srand config.seed

  config.raise_errors_for_deprecations!

  # disable monkey patching
  # see: https://relishapp.com/rspec/rspec-core/v/3-8/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!
end

require "htmlbeautifier"
