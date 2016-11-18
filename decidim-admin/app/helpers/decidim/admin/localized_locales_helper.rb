# frozen_string_literal: true
module Decidim
  module Admin
    # Custom helpers, scoped to the admin panel.
    #
    module LocalizedLocalesHelper
      def localized_locales
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

        Decidim.available_locales
          .map{ |locale| klass.new(locale) }
      end
    end
  end
end
