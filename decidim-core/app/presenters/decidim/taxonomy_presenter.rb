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

    def title(links: false, html_escape: false, all_locales: false)
      super(name, links, html_escape, all_locales)
    end
  end
end
