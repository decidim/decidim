# frozen_string_literal: true

module Decidim
  #
  # Decorator for taxonomies.
  #
  class TaxonomyPresenter < SimpleDelegator
    include Decidim::TranslationsHelper

    def translated_name
      @translated_name ||= translated_attribute name
    end
  end
end
