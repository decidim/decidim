# frozen_string_literal: true

module Decidim
  #
  # Decorator for categories
  #
  class CategoryPresenter < SimpleDelegator
    include Decidim::TranslationsHelper

    def translated_name
      @translated_name ||= translated_attribute name
    end
  end
end
