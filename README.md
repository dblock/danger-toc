# danger-toc

A plugin for [danger.systems](https://danger.systems) that makes sure your project's `README.md` has a TOC. Requires Ruby 3.1 or newer.

[![Gem Version](https://badge.fury.io/rb/danger-toc.svg)](https://badge.fury.io/rb/danger-toc)
[![CI](https://github.com/dblock/danger-toc/actions/workflows/ci.yml/badge.svg)](https://github.com/dblock/danger-toc/actions/workflows/ci.yml)

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [toc.check!](#toccheck)
  - [Options](#options)
    - [files](#files)
    - [header](#header)
    - [parser](#parser)
    - [format](#format)
    - [bullet](#bullet)
    - [indent](#indent)
    - [max_depth](#max_depth)
    - [report](#report)
  - [Global Defaults](#global-defaults)
- [Contributing](#contributing)
- [Copyright](#copyright)

## Installation

Add `danger-toc` to your Gemfile.

```
gem 'danger-toc'
```

Add `toc.check!` to your Dangerfile. Make a pull request and see this plugin in action.

<img src='images/toc-missing.png'>

## Usage

Methods from this plugin are available in your `Dangerfile` under the `toc` namespace. Every option can be set globally or passed to a check. Per-check options override global defaults without changing them.

### toc.check!

Check README.md with default options, or pass options for a particular set of files:

```ruby
toc.check!
toc.check!(files: ['README.md', 'DEV.md'], header: 'Contents')
```

The method returns whether all checked TOCs are correct and reports every failing file. Use `toc.toc_changes?(files: ['README.md'])` to detect modified or added files before running a check.

### Options

```ruby
toc.check!(files: ['README.md'], max_depth: 3)
toc.check!(files: ['docs/guide.md'], parser: 'Kramdown', format: :kramdown, bullet: '*', indent: 4)
```

#### files

File paths to check. Default: `['README.md']`.

```ruby
toc.check!(files: ['README.md', 'DEV.md'])
```

#### header

TOC heading text, without `#`. Default: `'Table of Contents'`.

```ruby
toc.check!(header: 'Contents')
```

When a TOC is missing, a leading `# Title` is excluded if every subsequent heading is nested below it. A lone heading or multiple top-level sections are retained. When a TOC exists, headings before it are excluded.

#### parser

Kramdown input parser name. Default: `'GFM'`. GFM and Kramdown input are available out of the box; install and require additional Kramdown parsers before selecting them.

```ruby
toc.check!(parser: 'Kramdown')
```

#### format

Anchor ID format: `:github` (default) or `:kramdown`. This is independent of the input parser.

```ruby
toc.check!(parser: 'Kramdown', format: :kramdown)
```

#### bullet

List marker: `'-'` (default), `'*'`, or `'+'`.

```ruby
toc.check!(bullet: '*')
```

#### indent

Non-negative number of spaces per nesting level. Default: `2`.

```ruby
toc.check!(indent: 4)
```

#### max_depth

Maximum absolute Markdown heading level (1–6). Default: `nil`, including all levels. For example, `2` includes `#` and `##` headings but not `###`.

```ruby
toc.check!(max_depth: 2)
```

#### report

Report style: `:full` (default) shows the complete expected TOC. Use `:diff` to show mismatched entries with two surrounding entries of context. Removed lines are prefixed with `-`, additions with `+`. Missing TOCs always show the full suggestion.

```ruby
toc.check!(report: :diff)
```

### Global Defaults

Set shared defaults on `toc`, then override individual settings for a particular check:

```ruby
toc.files = ['README.md', 'DEV.md']
toc.header = 'Contents'
toc.check!
toc.check!(files: ['docs/guide.md'], header: 'Guide Contents', parser: 'Kramdown')
toc.check! # still checks README.md and DEV.md using the Contents header
```

The same global/per-check choice applies to every option in the table, including `report`, `format`, and `max_depth`. Global settings are shared across plugin instances; each check captures its own immutable configuration snapshot.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).

## Copyright

Copyright (c) Daniel Doubrovkine, 2017-2019

MIT License, see [LICENSE](LICENSE.txt) for details.
