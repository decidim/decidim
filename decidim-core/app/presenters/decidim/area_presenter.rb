# frozen_string_literal: true

module Decidim
  #
  # Decorator for areas
  #
  class AreaPresenter < SimpleDelegator
    include Decidim::TranslationsHelper

    def translated_name
      @translated_name ||= translated_attribute name
    end

    def translated_name_with_type
      translated_type_name = area_type.presence && AreaTypePresenter.new(area_type).translated_name

      [translated_type_name, translated_name].compact_blank.join(" - ")
    end
  end
end
