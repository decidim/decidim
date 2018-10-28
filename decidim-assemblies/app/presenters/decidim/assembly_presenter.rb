# frozen_string_literal: true

module Decidim
  #
  # Decorator for areas
  #
  class AssemblyPresenter < SimpleDelegator
    include Decidim::TranslationsHelper

    def translated_title
      @translated_title ||= translated_attribute title
    end
  end
end
