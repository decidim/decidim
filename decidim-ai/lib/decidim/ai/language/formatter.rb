# frozen_string_literal: true

module Decidim
  module Ai
    module Language
      class Formatter
        include ActionView::Helpers::SanitizeHelper

        # for the moment, we just use strip_tags to clean-up the text. At a later stage, we may need to introduce
        # stemmers, ngrams or other kind of text normalization, as well any language specific criteria
        def cleanup(text)
          strip_tags(text)
        end
      end
    end
  end
end
