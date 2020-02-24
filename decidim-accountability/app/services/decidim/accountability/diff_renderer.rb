# frozen_string_literal: true

module Decidim
  module Accountability
    class DiffRenderer < BaseDiffRenderer
      private

      # Lists which attributes will be diffable and how they should be rendered.
      def attribute_types
        {
          start_date: :date,
          end_date: :date,
          description: :i18n_html,
          title: :i18n,
          decidim_scope_id: :scope,
          progress: :percentage
        }
      end
    end
  end
end
