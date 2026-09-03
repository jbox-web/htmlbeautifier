# frozen_string_literal: true

module HtmlBeautifier
  class Parser
    def initialize
      @maps = []
      yield self if block_given?
    end

    def map(pattern, method)
      @maps << [pattern, method]
    end

    def scan(subject, receiver)
      # Handlers are reached through __send__, so a mapping naming a method the
      # receiver does not have would only fail on the first document that
      # happens to contain the construct. Checking up front turns that into an
      # immediate, explicit error.
      missing = @maps.map(&:last).uniq.reject { |method| receiver.respond_to?(method, true) }
      raise ArgumentError, "receiver cannot handle: #{missing.join(', ')}" unless missing.empty?

      @scanner = StringScanner.new(subject)
      dispatch(receiver) until @scanner.eos?
    end

    def source_so_far
      @scanner.string[0...@scanner.pos]
    end

    def source_line_number
      [source_so_far.chomp.split(%r{\n}).count, 1].max
    end

    private

    def dispatch(receiver)
      _, method = @maps.find { |pattern, _| @scanner.scan(pattern) }
      raise "Unmatched sequence" unless method

      receiver.__send__(method, *extract_params(@scanner))
    rescue => e # rubocop:disable Style/RescueStandardError
      # The line number is added, but the class and the original backtrace are
      # kept: an ArgumentError coming from an option must not be reported as if
      # the document were malformed.
      raise e.class, "#{e.message} on line #{source_line_number}", e.backtrace
    end

    def extract_params(scanner)
      return [scanner[0]] unless scanner[1]

      params = []
      i = 1
      while scanner[i]
        params << scanner[i]
        i += 1
      end
      params
    end
  end
end
