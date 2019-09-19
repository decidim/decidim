# frozen_string_literal: true

module Decidim
  module Proposals
    class DiffRenderer < BaseDiffRenderer
      private

      # Lists which attributes will be diffable and how they should be rendered.
      def attribute_types
        {
          title: :string,
          body: :string,
          decidim_category_id: :category,
          decidim_scope_id: :scope,
          address: :string,
          latitude: :string,
          longitude: :string,
          state: :string
        }
      end
    end
  end
end
