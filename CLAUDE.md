# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Always use the project binstubs (`bin/rspec`, `bin/rubocop`, `bin/rake`); `bundle exec` is not used here.

```sh
bundle install                    # install dependencies
bin/rspec                         # full suite (also the default rake task)
bin/rspec spec/html_beautifier/parser_spec.rb          # one file
bin/rspec spec/html_beautifier_spec.rb:7               # one example, by line
bin/rspec -e "correctly indents mixed document"        # one example, by name
bin/rubocop                       # lint (CI runs it on Ruby 3.2)
bin/rake                          # == bin/rspec
```

`.rspec` passes `--warnings`, so Ruby warnings surface during specs. Specs run in random order
and `simplecov` writes `coverage/` on every run.

CI matrix: RuboCop on 3.2, RSpec on 3.2 / 3.3 / 3.4 / head / truffleruby. Minimum supported
Ruby is 3.2 (`required_ruby_version` in the gemspec, `TargetRubyVersion` in `.rubocop.yml`).

## Architecture

The gem is a single-pass, streaming beautifier: a regexp-driven scanner emits *events*, and a
stateful builder turns those events into indented output. There is no DOM and no AST — an
ill-formed document still produces output unless `stop_on_errors` is set.

The pipeline, from `HtmlBeautifier.beautify` (`lib/html_beautifier.rb`):

1. **`Parser`** (`parser.rb`) — generic `StringScanner` dispatcher. It holds an ordered list of
   `[regexp, method_name]` pairs; on each iteration it takes the **first** pattern that matches at
   the current position and calls that method on the receiver, passing the capture groups (or the
   whole match if there are no groups). Any exception is re-raised with the source line number
   appended. An unmatched position raises `"Unmatched sequence"`.
2. **`HtmlParser`** (`html_parser.rb`) — the pattern table (`MAPPINGS`). **Order is
   significant**: earlier entries win, so ERB tags, IE conditional comments, `<o:…>` Office tags,
   `<script>`/`<style>`, `<pre>`/`<textarea>`, void elements and block elements are matched before
   the generic open/close element patterns, and the catch-all text pattern comes last. Adding a
   construct means inserting a row at the right position in this table plus a matching handler
   method on `Builder`.
3. **`Builder`** (`builder.rb`) — the event receiver and the only place holding state: current
   indent `@level`, whether a newline is pending (`@new_line`), and the saved level stack for IE
   conditional comments (`@ie_cc_levels`). The `Parser` calls its methods by name, so every symbol
   in `MAPPINGS` must exist here — note they are `private` and reached via `__send__`. Indentation
   is materialised lazily in `emit`: newlines and leading indent are written only when the next
   non-blank content arrives.
4. **`RubyIndenter`** (`ruby_indenter.rb`) — decides, from the *text* of an ERB fragment, whether
   it opens a block (`if`, `do`, `{ |x|` …) or closes one (`end`, `else`, `}` …). `Builder#embed`
   outdents before emitting and indents after.

Special output rules worth knowing before touching `Builder`: `foreign_block` (script/style)
re-indents the block's content by stripping its original common leading whitespace and re-applying
the current level; `preformatted_block` (pre/textarea) emits the content verbatim.

`lib/html_beautifier.rb` sets up a Zeitwerk loader for the gem and explicitly ignores
`lib/htmlbeautifier.rb`, which exists only so `require "htmlbeautifier"` (the gem's name, no
underscore) works.

## CLI

`exe/htmlbeautifier` is a plain OptionParser script and holds behaviour that lives nowhere else:
in-place file rewriting via a `.tmp` file plus `FileUtils.mv`, stdin/stdout mode when no path is
given, and `--lint-only` (`-l`), which beautifies into a `StringIO`, compares with the input and
exits 1 listing the files that would change. Its options map onto the `beautify` options hash
(`indent`, `initial_level`, `stop_on_errors`, `keep_blank_lines`). `spec/executable_spec.rb`
exercises it as a real subprocess (`ruby -Ilib exe/htmlbeautifier`) and writes scratch files to
`tmp/`.

`tab_stops` is a deprecated alias for `indent` and is translated in `beautify` before the options
reach `Builder`.

## Conventions

- Double-quoted strings, `%r{}` for regexps, semantic block delimiters, `frozen_string_literal`
  on every file — enforced by `.rubocop.yml`.
- Specs use the `code` helper from `spec/spec_helper.rb` to write heredoc fixtures with the
  leading indentation stripped; expected output is compared as an exact string.
- Commit messages: imperative mood, capitalised, ≤ 50 chars, no trailing period (see README).
