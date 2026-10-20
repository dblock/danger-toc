# danger-toc

A plugin for [danger.systems](https://danger.systems) that makes sure your project's `README.md` has a TOC. Requires Ruby 3.1 or newer.

[![Gem Version](https://badge.fury.io/rb/danger-toc.svg)](https://badge.fury.io/rb/danger-toc)
[![CI](https://github.com/dblock/danger-toc/actions/workflows/ci.yml/badge.svg)](https://github.com/dblock/danger-toc/actions/workflows/ci.yml)

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [toc.files](#tocfiles)
  - [toc.header](#tocheader)
  - [toc.check!](#toccheck)
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

Methods and settings from this plugin are available in your `Dangerfile` under the `toc` namespace.

### toc.files

List of files to ensure TOC in, default is `README.md`.

```ruby
toc.files = ['README.md', 'DEV.md']
```

### toc.header

The Table of Contents header, without `#`, default is `Table of Contents`.

```ruby
toc.header = 'Custom Table of Contents'
```

### toc.check!

Run all checks.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).

## Copyright

Copyright (c) Daniel Doubrovkine, 2017-2019

MIT License, see [LICENSE](LICENSE.txt) for details.
