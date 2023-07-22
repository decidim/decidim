# frozen_string_literal: true

module Decidim
  module Ai
    module SpamContent
      class BaseStrategy
        attr_reader :name

        def initialize(options = {})
          @name = options.delete(:name)
          @options = options
        end

        def classify(_content); end

        def train(_classification, _content); end

        def untrain(_classification, _content); end

        def log; end

        def score; end
      end
    end
  end
end
