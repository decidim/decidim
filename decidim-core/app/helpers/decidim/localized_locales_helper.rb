# frozen_string_literal: true
module Decidim
  # Custom helpers, scoped to the admin panel.
  #
  module LocalizedLocalesHelper
    def localized_locales(collection = Decidim.available_locales)
      klass = Class.new do
        def initialize(locale)
          @locale = locale
        end

        def id
          @locale.to_s
        end

        def name
          I18n.t(id, scope: "locales")
        end
      end

      collection.map { |locale| klass.new(locale) }
    end
  end
end
