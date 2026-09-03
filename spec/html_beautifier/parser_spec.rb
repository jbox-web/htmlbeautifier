# frozen_string_literal: true

require "spec_helper"

RSpec.describe HtmlBeautifier::Parser do
  let(:receiver_class) {
    Class.new do
      attr_reader :sequence

      def initialize
        @sequence = []
      end

      def method_missing(method, *params)
        @sequence << [method, params]
      end

      def respond_to_missing?(*)
        true
      end
    end
  }

  it "dispatches matching sequence" do
    receiver = receiver_class.new
    parser = described_class.new { |p|
      p.map %r{foo}, :foo
      p.map %r{bar\s*}, :bar
      p.map %r{\s+}, :whitespace
    }
    parser.scan("foo bar ", receiver)
    expected = [[:foo, ["foo"]], [:whitespace, [" "]], [:bar, ["bar "]]]
    expect(receiver.sequence).to eq(expected)
  end

  it "sends parenthesized components as separate parameters" do
    receiver = receiver_class.new
    parser = described_class.new { |p|
      p.map %r{(foo)\((.*?)\)}, :foo
    }
    parser.scan("foo(bar)", receiver)
    expected = [[:foo, %w[foo bar]]]
    expect(receiver.sequence).to eq(expected)
  end

  it "rejects a mapping the receiver cannot handle" do
    parser = described_class.new { |p| p.map %r{foo}, :no_such_handler }

    expect { parser.scan("foo", Object.new) }
      .to raise_error(ArgumentError, %r{no_such_handler})
  end

  it "keeps the class of an error raised by the receiver" do
    receiver = Class.new do
      def boom(*)
        raise ArgumentError, "negative argument"
      end
    end.new
    parser = described_class.new { |p| p.map %r{foo}, :boom }

    expect { parser.scan("foo", receiver) }
      .to raise_error(ArgumentError, "negative argument on line 1")
  end

  context "when tracking source lines" do
    let(:source_tracking_receiver_class) {
      Class.new(receiver_class) do
        attr_reader :sources_so_far
        attr_reader :source_line_numbers

        def initialize(parser)
          @sources_so_far = []
          @source_line_numbers = []
          @parser = parser
          super()
        end

        def append_new_source_so_far(*)
          @sources_so_far << @parser.source_so_far
        end

        def append_new_source_line_number(*)
          @source_line_numbers << @parser.source_line_number
        end
      end
    }

    it "gives source so far" do
      parser = described_class.new { |p|
        p.map %r{(M+)}m, :append_new_source_so_far
        p.map %r{(\s+)}m, :space_or_newline
      }
      receiver = source_tracking_receiver_class.new(parser)
      parser.scan("M MM MMM", receiver)
      expect(receiver.sources_so_far).to eq(["M", "M MM", "M MM MMM"])
    end

    it "gives source line number" do
      parser = described_class.new { |p|
        p.map %r{(M+)}m, :append_new_source_line_number
        p.map %r{(\s+)}m, :space_or_newline
      }
      receiver = source_tracking_receiver_class.new(parser)
      parser.scan("M \n\nMM\nMMM", receiver)
      expect(receiver.source_line_numbers).to eq([1, 3, 4])
    end
  end
end
