# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to be used when admin users want to import categories
    # from a participatory space into another one.
    class ImportCategoriesForm < Decidim::Form
      mimic :categories_import

      attribute :origin_participatory_space_slug, Integer

      validates :origin_participatory_space_slug, :origin_participatory_space, :current_participatory_space, presence: true

      def origin_participatory_space
        @origin_participatory_space ||= origin_participatory_spaces.find { |space| space.slug == origin_participatory_space_slug }
      end

      def origin_participatory_spaces
        @origin_participatory_spaces ||= participatory_spaces_with_categories
        @origin_participatory_spaces.delete(current_participatory_space)
        return @origin_participatory_spaces
      end

      def participatory_spaces_with_categories
        current_organization.public_participatory_spaces.select { |space|  space.try(:categories) and space.categories.any?  }
      end

      def origin_participatory_spaces_collection
        origin_participatory_spaces.map do |participatory_space|
          [participatory_space.title[I18n.locale.to_s], participatory_space.slug]
        end
      end
    end
  end
end
