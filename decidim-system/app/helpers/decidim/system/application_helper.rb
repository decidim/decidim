# frozen_string_literal: true
module Decidim
  module System
    # Custom helpers, scoped to the system panel.
    #
    module ApplicationHelper
      def title
        "Decidim"
      end

      def field_name(model, field)
        st "models.#{model}.fields.#{field}"
      end

      def st(key, options = {})
        options[:scope] ||= "decidim.system"
        I18n.t(key, options)
      end
    end
  end
end
