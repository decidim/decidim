# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to create categories from the admin dashboard.
    #
    class CategoryForm < Form
      include TranslatableAttributes

      translatable_attribute :name, String
      translatable_attribute :description, String
      attribute :parent_id, Integer

      mimic :category

      validates :name, :description, translatable_presence: true
      validates :parent_id, inclusion: { in: :parent_categories_ids }, allow_blank: true

      delegate :current_participatory_space, to: :context, prefix: false

      def parent_categories
        @parent_categories ||= current_participatory_space.categories.first_class.where.not(id: id)
      end

      private

      def parent_categories_ids
        @parent_categories_ids ||= parent_categories.pluck(:id)
      end
    end
  end
end
