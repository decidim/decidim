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

    def title(links: nil, html_escape: false, all_locales: false)
      raise "Links have been set" unless links.nil?

      super(name, html_escape, all_locales)
    end
  end
end
