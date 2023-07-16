# frozen_string_literal: true

module Decidim
  module Ai
    module SpamContent
      class BaseStrategy
        def initialize(options = {})
          @options = options
        end

        def classify!(content); end

        def train!(classification, content); end
      end
    end
  end
end
