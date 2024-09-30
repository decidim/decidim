# frozen_string_literal: true

module Decidim
  module Surveys
    # Custom helpers, scoped to the surveys engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::SanitizeHelper
      include Decidim::CheckBoxesTreeHelper
      include Decidim::RichTextEditorHelper

      def filter_date_values
        flat_filter_values(:all, :open, :closed, scope: "decidim.surveys.surveys.filters.date_values")
      end
    end
  end
end
