module Danger
  # Check whether the TOC in .md file(s) has been updated.
  #
  # @example Run all checks on the default README.md.
  #
  #          toc.check
  #
  # @example Customize filenames and remind the requester to update TOCs when necessary.
  #
  #          toc.filenames = ['README.md']
  #          toc.is_toc_correct?
  #
  # @see  dblock/danger-toc
  # @tags toc

  class DangerToc < Plugin
    # The toc filenames, defaults to `[README.md]`.
    # @return [Array]
    attr_accessor :filenames

    def initialize(dangerfile)
      @filenames = ['README.md']
      super
    end

    # Run all checks.
    # @return [void]
    def check
      is_toc_correct?
    end

    # Has the README file been modified?
    # @return [boolean]
    def toc_changes?
      (git.modified_files & filenames).any? || (git.added_files & filenames).any?
    end

    # Is the TOC format correct?
    # @return [boolean]
    def is_toc_correct?
      filenames.all? do |filename|
        toc_file = Danger::Toc::MarkdownFile.new(filename)
        if !toc_file.exists?
          messaging.fail("The #{filename} file does not exist.", sticky: false)
          false
        elsif toc_file.good?
          true
        else
          markdown <<-MARKDOWN
Here's the expected TOC for #{filename}:

```markdown
# #{Danger::Toc.config.header}

#{toc_file.toc_from_headers.join("\n")}
```
MARKDOWN
          if toc_file.has_toc?
            messaging.fail("The TOC found in #{filename} doesn't match the sections of the file.", sticky: false)
          else
            messaging.fail("The #{filename} file is missing a TOC.", sticky: false)
          end
          false
        end
      end
    end
  end
end
