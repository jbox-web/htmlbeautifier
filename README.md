# HTML Beautifier

[![GitHub license](https://img.shields.io/github/license/jbox-web/htmlbeautifier.svg)](https://github.com/jbox-web/htmlbeautifier/blob/master/LICENSE)
[![CI](https://github.com/jbox-web/htmlbeautifier/workflows/CI/badge.svg)](https://github.com/jbox-web/htmlbeautifier/actions)
[![Maintainability](https://qlty.sh/gh/jbox-web/projects/htmlbeautifier/maintainability.svg)](https://qlty.sh/gh/jbox-web/projects/htmlbeautifier)
[![Code Coverage](https://qlty.sh/gh/jbox-web/projects/htmlbeautifier/coverage.svg)](https://qlty.sh/gh/jbox-web/projects/htmlbeautifier)

A normaliser/beautifier for HTML that also understands embedded Ruby.
Ideal for tidying up Rails templates.

## What it does

* Normalises hard tabs to spaces (or vice versa)
* Removes trailing spaces
* Indents after opening HTML elements
* Outdents before closing elements
* Collapses multiple whitespace
* Indents after block-opening embedded Ruby (if, do etc.)
* Outdents before closing Ruby blocks
* Outdents elsif and then indents again
* Indents the left-hand margin of JavaScript and CSS blocks to match the
  indentation level of the code

## Usage

### From the command line

To update files in-place:

``` sh
$ htmlbeautifier file1.html.erb [file2.html.erb ...]
```

or to operate on standard input and output:

``` sh
$ htmlbeautifier < untidy.html.erb > formatted.html.erb
```

#### Options

| Option | Effect |
| ------ | ------ |
| `-t`, `--tab-stops NUMBER` | Number of spaces per indent (default 2) |
| `-T`, `--tab` | Indent using tabs |
| `-i`, `--indent-by NUMBER` | Indent the whole output by NUMBER steps (default 0) |
| `-b`, `--keep-blank-lines NUMBER` | Number of consecutive blank lines to keep (default 0) |
| `-e`, `--stop-on-errors` | Stop when invalid nesting is encountered, instead of carrying on |
| `-l`, `--lint-only` | Do not write anything; exit 1 listing the files that would be modified |
| `-v`, `--version` | Display the version and exit |
| `-h`, `--help` | Display the help message and exit |

`--lint-only` requires file arguments: it cannot report on standard input,
where there is no file to name. When files are given, each one is attempted
even if an earlier one fails, and the run exits 1 listing every failure.

Files are rewritten through a temporary file in the same directory, keeping
the mode, the ownership and the symlink identity of the original.

### In your code

```ruby
require 'htmlbeautifier'

beautiful = HtmlBeautifier.beautify(untify_html_string)
```

You can also specify how to indent (the default is two spaces):

```ruby
beautiful = HtmlBeautifier.beautify(untidy_html_string, indent: "\t")
```

The other options mirror the command-line flags. An unknown key raises
`ArgumentError` rather than being ignored:

| Option | Effect |
| ------ | ------ |
| `indent:` | String used for one indent level (default `"  "`) |
| `initial_level:` | Indent the whole output by this many steps (default 0) |
| `keep_blank_lines:` | Number of consecutive blank lines to keep (default 0) |
| `stop_on_errors:` | Raise on invalid nesting instead of carrying on (default false) |

Both the document and its formatted form are held in memory, so a very large
template needs roughly twice its own size.

## Installation

This is a Ruby gem.
To install the command-line tool (you may need `sudo`):

```sh
$ gem install htmlbeautifier
```

To use the gem with Bundler, add to your `Gemfile`:

```ruby
gem 'htmlbeautifier'
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for the list of changes in each release.

## Contributing

1. Follow [these guidelines][git-commit] when writing commit messages (briefly,
   the first line should begin with a capital letter, use the imperative mood,
   be no more than 50 characters, and not end with a period).
2. Include tests.

[git-commit]:http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
