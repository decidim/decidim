# frozen_string_literal: true

module Decidim
  module Initiatives
    class DiffRenderer < BaseDiffRenderer
      private

      # Lists which attributes will be diffable and how they should be rendered.
      def attribute_types
        {
          description: :i18n_html,
          title: :i18n,
          state: :string
        }
      end
    end
  end
end
