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
    end
  end
end
