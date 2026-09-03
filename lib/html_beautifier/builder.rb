# frozen_string_literal: true

module HtmlBeautifier
  class Builder # rubocop:disable Metrics/ClassLength
    DEFAULT_OPTIONS = {
      indent: "  ",
      initial_level: 0,
      stop_on_errors: false,
      keep_blank_lines: 0
    }.freeze

    def initialize(output, options = {})
      options = DEFAULT_OPTIONS.merge(validated(options))
      @tab = options[:indent]
      @stop_on_errors = options[:stop_on_errors]
      @level = options[:initial_level]
      @keep_blank_lines = options[:keep_blank_lines]
      # An indented document must have its very first line indented too, which
      # only happens if a new line is considered pending from the start.
      @new_line = @level > 0
      @empty = true
      @ie_cc_levels = []
      @output = output
      @embedded_indenter = RubyIndenter.new
    end

    private

    # A misspelled key would otherwise be merged away in silence, and the
    # option it was meant to set would look like a bug in the formatter.
    def validated(options)
      unknown = options.keys - DEFAULT_OPTIONS.keys
      raise ArgumentError, "unknown option(s): #{unknown.join(', ')}" unless unknown.empty?

      options
    end

    def error(text)
      return unless @stop_on_errors

      raise text
    end

    def indent
      @level += 1
    end

    def outdent
      error "Extraneous closing tag" if @level == 0
      @level = [@level - 1, 0].max
    end

    def emit(*strings)
      strings_join = strings.join
      # Trailing blanks would sit at the end of a line on this pass and be
      # absorbed by new_lines on the next one, which is what made the output
      # non-idempotent. @output is the string built by HtmlBeautifier.beautify.
      @output.sub!(%r{[ \t]+\z}, "") if @new_line && !@empty
      @output << "\n" if @new_line && !@empty
      @output << (@tab * @level) if @new_line && !strings_join.strip.empty?
      @output << strings_join
      @new_line = false
      @empty = false
    end

    def new_line
      @new_line = true
    end

    def embed(opening, code, closing)
      lines = code.split(%r{\n}).map(&:strip)
      outdent if @embedded_indenter.outdent?(lines)
      emit opening, code, closing
      indent if @embedded_indenter.indent?(lines)
    end

    def foreign_block(opening, code, closing)
      emit opening
      emit_reindented_block_content code unless code.strip.empty?
      emit closing
    end

    def emit_reindented_block_content(code)
      lines = code.strip.split(%r{\n})
      # The pattern is invariant in the loop, so it is compiled once rather
      # than on every line of the block.
      indentation = %r{^#{foreign_block_indentation(code)}}

      indent
      new_line
      lines.each do |line|
        emit line.rstrip.sub(indentation, "")
        new_line
      end
      outdent
    end

    def foreign_block_indentation(code)
      code.split(%r{\n}).find { |ln| !ln.strip.empty? }[%r{^\s+}]
    end

    def preformatted_block(opening, content, closing)
      new_line
      emit opening, content, closing
      new_line
    end

    def standalone_element(elem)
      emit elem
      new_line if %r{^<br[^\w]}i.match?(elem)
    end

    def close_element(elem)
      outdent
      emit elem
    end

    def close_block_element(elem)
      close_element elem
      new_line
    end

    def open_element(elem)
      emit elem
      indent
    end

    def open_block_element(elem)
      new_line
      open_element elem
    end

    def close_ie_cc(elem)
      if @ie_cc_levels.empty?
        error "Unclosed conditional comment"
      else
        @level = @ie_cc_levels.pop
      end
      emit elem
    end

    def open_ie_cc(elem)
      emit elem
      @ie_cc_levels.push @level
      indent
    end

    def new_lines(*content)
      blank_lines = content.first.scan(%r{\n}).count - 1
      blank_lines = [blank_lines, @keep_blank_lines].min
      @output << ("\n" * blank_lines)
      new_line
    end

    # Source text may start with whitespace that new_lines would absorb on the
    # next pass; dropping it here keeps the output a fixed point. Text that is
    # nothing but whitespace at the start of a line is dropped entirely rather
    # than emitted empty, which would consume the pending new line and leave
    # the element that follows unindented. Foreign and preformatted blocks do
    # not go through here, so their own indentation is left untouched.
    def text(content)
      return emit(content) unless @new_line

      content = content.lstrip
      emit(content) unless content.empty?
    end
  end
end
