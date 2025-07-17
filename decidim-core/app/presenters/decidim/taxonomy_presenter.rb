# frozen_string_literal: true

module Decidim
  #
  # Decorator for taxonomies.
  #
  class TaxonomyPresenter < ResourcePresenter
    include Decidim::TranslationsHelper

    def translated_name
      @translated_name ||= translated_attribute name
    end

    def title(html_escape: false, all_locales: false)
      super(name, html_escape, all_locales)
    end
  end
end
