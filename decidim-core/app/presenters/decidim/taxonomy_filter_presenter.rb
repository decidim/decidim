# frozen_string_literal: true

module Decidim
  #
  # Decorator for taxonomies.
  #
  class TaxonomyFilterPresenter < SimpleDelegator
    include Decidim::TranslationsHelper
    include Decidim::SanitizeHelper

    def translated_name
      @translated_name ||= decidim_sanitize_translated(name)
    end

    def translated_internal_name
      @translated_internal_name ||= decidim_sanitize_translated(internal_name)
    end
  end
end
