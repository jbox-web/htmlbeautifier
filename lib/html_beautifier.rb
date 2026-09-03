# frozen_string_literal: true

# require ruby dependencies
require "strscan"

# require external dependencies
require "zeitwerk"

# load zeitwerk
Zeitwerk::Loader.for_gem.tap do |loader|
  loader.ignore("#{__dir__}/htmlbeautifier.rb")
  loader.setup
end

module HtmlBeautifier
  #
  # Returns a beautified HTML/HTML+ERB document as a String.
  # html must be an object that responds to +#to_s+.
  #
  # Available options are:
  # tab_stops - an integer for the number of spaces to indent, default 2.
  # Deprecated: see indent.
  # indent - what to indent with ("  ", "\t" etc.), default "  "
  # stop_on_errors - raise an exception on a badly-formed document. Default
  # is false, i.e. continue to process the rest of the document.
  # initial_level - The entire output will be indented by this number of steps.
  # Default is 0.
  # keep_blank_lines - an integer for the number of consecutive empty lines
  # to keep in output.
  #
  def self.beautify(html, options = {})
    options = options.dup
    tab_stops = options.delete(:tab_stops)
    options[:indent] = " " * tab_stops if tab_stops
    # Leading and trailing whitespace is dropped up front rather than carried
    # through the builder, where it would survive one pass and disappear on the
    # next: the output of beautify must be a fixed point of beautify.
    (+"").tap do |output|
      HtmlParser.new.scan(html.to_s.strip, Builder.new(output, options))
    end
  end
end
