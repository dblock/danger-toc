require_relative 'constructors/kramdown_constructor'
require_relative 'constructors/github_constructor'

module Danger
  module Toc
    module Constructors
      def self.get(name)
        const_get "#{name.to_s.camelize}Constructor"
      end
    end
  end
end
