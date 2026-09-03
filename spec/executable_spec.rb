# frozen_string_literal: true

require "shellwords"
require "fileutils"
require "open3"

RSpec.describe "exe/htmlbeautifier" do # rubocop:disable RSpec/DescribeClass
  before do
    FileUtils.mkdir_p path_to("tmp")
  end

  def write(path, content)
    File.write(path, content)
  end

  def read(path)
    File.read(path)
  end

  def path_to(*partial)
    File.join(File.expand_path("..", __dir__), *partial)
  end

  def command
    "ruby -I%s %s" % [
      escape(path_to("lib")),
      escape(path_to("exe", "htmlbeautifier")),
    ]
  end

  def escape(str)
    Shellwords.escape(str)
  end

  it "beautifies a file in place" do
    input = "<p>\nfoo\n</p>"
    expected = "<p>\n  foo\n</p>\n"
    path = path_to("tmp", "in-place.html")
    write path, input

    system "%s %s" % [command, escape(path)]

    expect(read(path)).to eq(expected)
  end

  it "beautifies a file from stdin to stdout" do
    input = "<p>\nfoo\n</p>"
    expected = "<p>\n  foo\n</p>\n"
    in_path = path_to("tmp", "input.html")
    out_path = path_to("tmp", "output.html")
    write in_path, input

    system "%s < %s > %s" % [command, escape(in_path), escape(out_path)]

    expect(read(out_path)).to eq(expected)
  end

  it "displays which files would fail with --lint-only flag" do
    good_input = "<p></p>\n"
    good_path = path_to("tmp", "good.html")
    write(good_path, good_input)

    bad_input = "<div><p></p></div>\n"
    bad_path = path_to("tmp", "bad.html")
    write(bad_path, bad_input)

    expected_message = "Lint failed - files would be modified:\n<redacted>/tmp/bad.html\n"

    _stdout, stderr, status = Open3.capture3(
      "%s %s %s --lint-only" % [command, escape(good_path), escape(bad_path)]
    )

    stderr.sub!(%r{/.*tmp/}, "<redacted>/tmp/")

    expect(status.exitstatus).to eq(1)
    expect(stderr).to eq(expected_message)
  end

  it "does not modify files with --lint-only flag" do
    good_input = "<p></p>\n"
    good_path = path_to("tmp", "good.html")
    write(good_path, good_input)

    bad_input = "<div><p></p></div>\n"
    bad_path = path_to("tmp", "bad.html")
    write(bad_path, bad_input)

    Open3.capture3(
      "%s %s %s --lint-only" % [command, escape(good_path), escape(bad_path)]
    )

    expect(read(good_path)).to eq(good_input)
    expect(read(bad_path)).to eq(bad_input)
  end

  it "allows a configurable number of tab stops" do
    input = "<p>\nfoo\n</p>"
    expected = "<p>\n   foo\n</p>\n"
    path = path_to("tmp", "in-place.html")
    write path, input

    system "%s --tab-stops=3 %s" % [command, escape(path)]

    expect(read(path)).to eq(expected)
  end

  it "allows indentation with tab instead of spaces" do
    input = "<p>\nfoo\n</p>"
    expected = "<p>\n\tfoo\n</p>\n"
    path = path_to("tmp", "in-place.html")
    write path, input

    system "%s --tab %s" % [command, escape(path)]

    expect(read(path)).to eq(expected)
  end

  it "allows an initial indentation level" do
    input = "<p>\nfoo\n</p>"
    expected = "      <p>\n        foo\n      </p>\n"
    path = path_to("tmp", "in-place.html")
    write path, input

    system "%s --indent-by 3 %s" % [command, escape(path)]

    expect(read(path)).to eq(expected)
  end

  it "ignores closing tag errors by default" do
    input = "</p>\n"
    expected = "</p>\n"
    path = path_to("tmp", "in-place.html")
    write path, input

    status = system("%s %s" % [command, escape(path)])

    expect(read(path)).to eq(expected)
    expect(status).to be_truthy
  end

  it "raises an exception on closing tag errors with --stop-on-errors" do
    input = "</p>\n"
    path = path_to("tmp", "in-place.html")
    write path, input

    status = system("%s --stop-on-errors %s 2>/dev/null" % [command, escape(path)])

    expect(status).to be_falsey
  end

  it "allows a configurable number of consecutive blank lines" do
    input = "<h1>foo</h1>\n\n\n\n\n<p>bar</p>\n"
    expected = "<h1>foo</h1>\n\n\n<p>bar</p>\n"
    path = path_to("tmp", "in-place.html")
    write path, input

    system "%s --keep-blank-lines=2 %s" % [command, escape(path)]

    expect(read(path)).to eq(expected)
  end

  describe "in-place rewriting" do
    it "preserves the file mode" do
      path = path_to("tmp", "mode.html")
      write path, "<p>\nfoo\n</p>"
      File.chmod 0o600, path

      system "%s %s" % [command, escape(path)]

      expect(File.stat(path).mode & 0o777).to eq(0o600)
    end

    it "writes through a symlink instead of replacing it" do
      target = path_to("tmp", "target.html")
      link = path_to("tmp", "link.html")
      write target, "<p>\nfoo\n</p>"
      FileUtils.rm_f link
      File.symlink target, link

      system "%s %s" % [command, escape(link)]

      expect(File.symlink?(link)).to be(true)
      expect(read(target)).to eq("<p>\n  foo\n</p>\n")
    end

    it "leaves no temporary file behind when parsing fails" do
      path = path_to("tmp", "leftover.html")
      FileUtils.rm_f Dir[path_to("tmp", "leftover.html*")]
      write path, "</p>"

      Open3.capture3("%s --stop-on-errors %s" % [command, escape(path)])

      expect(Dir[path_to("tmp", "leftover.html*")]).to eq([path])
    end
  end

  describe "error reporting" do
    it "processes the remaining files after one fails" do
      first = path_to("tmp", "first.html")
      bad = path_to("tmp", "bad-nesting.html")
      last = path_to("tmp", "last.html")
      write first, "<div>\n<p>x</p>\n</div>"
      write bad, "</p>"
      write last, "<div>\n<p>y</p>\n</div>"

      _stdout, stderr, status = Open3.capture3(
        "%s --stop-on-errors %s %s %s" %
          [command, escape(first), escape(bad), escape(last)]
      )

      expect(read(last)).to eq("<div>\n  <p>y</p>\n</div>\n")
      expect(status.exitstatus).to eq(1)
      expect(stderr).to include("bad-nesting.html")
    end

    it "reports a missing file without a backtrace" do
      _stdout, stderr, status = Open3.capture3(
        "%s %s" % [command, escape(path_to("tmp", "no-such-file.html"))]
      )

      expect(status.exitstatus).to eq(1)
      expect(stderr).to include("no-such-file.html")
      expect(stderr).not_to match(%r{:\d+:in })
    end

    it "rejects a negative number of tab stops" do
      path = path_to("tmp", "negative.html")
      write path, "<p>\nfoo\n</p>"

      _stdout, stderr, status = Open3.capture3(
        "%s --tab-stops=-2 %s" % [command, escape(path)]
      )

      expect(status.exitstatus).to eq(1)
      expect(stderr).to include("must be zero or greater")
    end
  end

  describe "standard input" do
    it "fails rather than ignoring --lint-only" do
      _stdout, stderr, status = Open3.capture3(
        "%s --lint-only" % command, stdin_data: "<div><p></p></div>\n"
      )

      expect(status.exitstatus).to eq(1)
      expect(stderr).to include("--lint-only")
    end

    it "exits quietly when the downstream pipe is closed" do
      path = path_to("tmp", "large.html")
      write path, "<p>x</p>\n" * 20_000

      _stdout, stderr, _status = Open3.capture3(
        "%s < %s | head -2" % [command, escape(path)]
      )

      expect(stderr).to eq("")
    end

    it "reads UTF-8 regardless of the locale" do
      path = path_to("tmp", "utf8.html")
      write path, "<p>\ncafé\n</p>"

      _stdout, _stderr, status = Open3.capture3(
        { "LANG" => "C", "LC_ALL" => "C" }, "%s %s" % [command, escape(path)]
      )

      expect(status.exitstatus).to eq(0)
      expect(read(path)).to eq("<p>\n  café\n</p>\n")
    end
  end

  it "displays the default number of tab stops in its help" do
    stdout, _stderr, _status = Open3.capture3("%s --help" % command)

    expect(stdout).to include("(default 2)")
  end
end
