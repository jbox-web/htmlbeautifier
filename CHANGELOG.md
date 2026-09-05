# CHANGELOG

## 1.5.0 (unreleased)

* Fix a crash on tags split over several lines: `<input\n class="x"\n/>` no
  longer raises "Unmatched sequence".
* Keep a > inside a quoted attribute value from ending the tag, which fixes
  Stimulus descriptors such as data-action="click->hello#greet".
* Treat a `<` that opens no tag as text instead of failing to parse.
* Recognise dialog, hgroup, main, nav, search and summary as block elements.
* Add a newline after `<BR>` as well as after `<br>`.
* Apply initial_level to a document that starts with text.
* Make the output a fixed point: beautifying twice now yields the same result,
  including for documents with stray whitespace or an unclosed block.
* Preserve the mode, ownership and symlink identity of a file rewritten in
  place, and write through an unpredictable temporary file.
* Leave no temporary file behind when parsing fails.
* Carry on with the remaining files when one fails, and report every failure
  at the end with a non-zero exit status.
* Report an unreadable file with a message instead of a backtrace.
* Fail instead of silently ignoring --lint-only when reading standard input.
* Read input as UTF-8 whatever the locale says.
* Exit quietly when the downstream pipe is closed.
* Reject negative values for --tab-stops, --indent-by and --keep-blank-lines.
* Reject unknown option keys instead of ignoring them, and stop modifying the
  options hash passed by the caller.
* Constrain the zeitwerk dependency to ~> 2.6.

## 1.4.3 (2024-02-13)

* Indent case statements.
* Make README input and output clearer.

## 1.4.2 (2022-04-05)

* Add support for `<details>` with a Boolean attribute handled by ERB.
* Remove relative_path_from call.

## 1.4.1 (2021-12-05)

* Add hyphen to the standalone element pattern.

## 1.4.0 (2021-11-26)

* Add --lint-only option, writing lint errors to stderr.
* Add --version option.
* Fix foreign block indentation issue.
* Fix self-closing tags regex problems.
* Drop support for unmaintained Ruby versions.

## 1.3.1 (2017-05-04)

* Fix erroneous additional indentation being applied to code in `<script>` and
  `<style>` sections.

## 1.3.0 (2017-03-20)

* Allow blank lines (up to a maximum) to be preserved in output.
* Fix bug with excess indentation in some circumstances.

## 1.2.1 (2016-11-22)

* Support arbitrary self-closing tags.

## 1.2.0 (2016-09-06)

* Support indentation via tabs.
* Allow the whole output to be indented by a number of steps.
* Indentation is now handled by the indent option: tab_stops still works but
  is deprecated.

## 1.1.1 (2015-07-27)

* Indent after 'until' and 'for'.
* Do not modify the content of `<textarea>`.
* Improve documentation.
* Make coding style consistent (and enforced by Robocop).

## 1.1.0 (2015-03-07)

* Remove whitespace in an otherwise-empty `<script></script>` node.

## 1.0.2 (2015-02-23)

* Allow `<` in attributes in order to support AngularJS.

## 1.0.1 (2015-02-22)

* Improve help output of command-line tool.

## 1.0.0 (2015-01-19)

* Improve and document the API.
* Specify Ruby support: >= 1.9.2.
* Move tests to RSpec.
* Stop breaking on excessive outdenting by default.

## 0.0.12 (2014-12-30)

* Add new lines after `<br>` and around `<pre>`.
* Add HTML5 block elements and remove those deprecated in HTML 4.0.
* Fix breakage in command-line tool.
* Command-line tool is now tested.
* No longer hangs on certain large files.

## 0.0.11 (2014-12-29)

* Preserve formatting inside `<pre>`.
* Add new lines after block-like elements.

## 0.0.10 (2014-09-28)

* Set tab width via CLI option.

## 0.0.9 (2013-12-29)

* Support `<br>` etc. without /.
* Make element names case-insensitive.

## 0.0.8 (2013-08-27)

* Avoid wiping output file on error when working in place.
* Report filename when an error occurs.
* Clarify licence (with contributor permission): MIT.

## 0.0.7 (2012-07-10)

* Modernise gem structure.
* Document Beautifier.
* Improve outdent reporting.

## 0.0.6 (2010-07-01)

* Fix new line at end of output when modifying file.

## 0.0.5 (2010-07-01)

* Add option to modify file in place.
* Report source line when outdenting too far.

## 0.0.4 (2009-10-13)

* Outdent 'else' correctly.

## 0.0.3 (2009-10-13)

* Support `<%- ... -%>`
* Eliminated dependency on hoe.

## 0.0.2 (2009-10-11)

* Move from a single file to multiple files.
* Fix parsing of standalone element immediately after closing element.
* Don't break on empty script elements.
* Emit new line at end of output.
* Parse IE conditional comments.
* Release as a gem.
