# Releasing Danger-Toc

Start from clean, current master. Choose a version following [Semantic Versioning](https://semver.org/), update `lib/toc/gem_version.rb`, date its changelog section (`YYYY-MM-DD`), and remove the contribution placeholder. Run `bundle exec rake spec` immediately before committing. Commit and push the release preparation directly to master and confirm GitHub Actions passes.

Build and inspect the package before publishing:

```sh
bundle exec rake build
tar -xOf pkg/danger-toc-VERSION.gem data.tar.gz | tar -tzf -
```

Only library files and published documentation belong in the package. Ask the maintainer for a fresh RubyGems OTP immediately before publishing, or complete MFA locally when prompted. Never store or commit credentials.

```sh
gem push pkg/danger-toc-VERSION.gem
git tag -a vVERSION -m "Version VERSION"
git push origin vVERSION
gh release create vVERSION --verify-tag --title VERSION --notes-file RELEASE_NOTES
```

Replace VERSION with the release version; RELEASE_NOTES should contain only that version's changelog entries. Verify RubyGems publication with `https://rubygems.org/api/v2/rubygems/danger-toc/versions/VERSION.json`, the tag's commit, and the GitHub release. If a step fails, check publication state and complete only missing steps; never overwrite a published version or move a pushed tag.

Complete the release by incrementing the patch version and prepending a matching `(Next)` changelog section with `* Your contribution here.`. Validate, commit, and push directly to master without a PR or new tag. Leave feature PRs for maintainer review; do not merge or publish unless requested.
