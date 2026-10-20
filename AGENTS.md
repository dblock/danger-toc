# Working on danger-toc

Danger plugin for checking Markdown tables of contents. Requires Ruby 3.1 or newer.

## Structure

* `lib/toc/config.rb`: declared options, validated global defaults, and immutable per-check snapshots.
* `lib/toc/markdown_file.rb`: Markdown parsing, TOC extraction, normalization, and comparison.
* `lib/toc/constructors/`: heading extraction and GitHub or Kramdown anchor generation.
* `lib/toc/extractor.rb`: locates the existing TOC.
* `lib/toc/plugin.rb`: Danger configuration delegation and reports.
* `spec/`: RSpec examples and Markdown fixtures.

## Development

Install dependencies with `bundle install` when needed. Run `bundle exec rake spec` before committing; it runs RSpec, RuboCop, and `danger plugins lint`. For focused changes, use `bundle exec rspec PATH` and `bundle exec rubocop PATH`.

CI covers Ruby 3.1 through 4.0 with compatible ActiveSupport versions. Set `ACTIVESUPPORT_VERSION` when resolving a particular compatibility bundle. Load `logger` after Bundler setup and before Danger when using older ActiveSupport versions; loading it before Bundler can activate an incompatible default-gem version.

Preserve existing TOC output unless a behavior change is explicitly requested. Keep input parsing separate from anchor generation. Declare every option in Config::DEFAULTS and validate it in Config; global plugin accessors and per-check keywords must support the same options. Pass immutable snapshots through parsing and reporting; never read global defaults during a check. Add focused regression tests and reset global defaults after examples that change them.

Update README.md for public behavior and keep its TOC in sync. Add changelog entries under the next release with the PR number and contributor attribution; retain the contribution placeholder. Keep Markdown paragraphs on one line.

## Git and releases

Use feature branches and one commit per PR. Amend updates and push with `--force-with-lease`, never force-push master. Leave issues open until their implementation PR merges, using closing references in the PR.

Do not merge or publish without an explicit request. Follow RELEASING.md for authorized releases and next-version preparation directly on master. Never commit credentials or OTP codes.
