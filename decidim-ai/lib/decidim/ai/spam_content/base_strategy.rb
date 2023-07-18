# frozen_string_literal: true

module Decidim
  module Ai
    module SpamContent
      class BaseStrategy
        def initialize(options = {})
          @options = options
        end

        def classify(_content); end

        def train(_classification, _content); end

        def untrain(_classification, _content); end
      end
    end
  end
end
