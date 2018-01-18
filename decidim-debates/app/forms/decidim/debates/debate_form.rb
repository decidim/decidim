# frozen_string_literal: true

module Decidim
  module Debates
    # This class holds a Form to create/update debates from Decidim's admin panel.
    class DebateForm < Decidim::Form
      include TranslatableAttributes

      attribute :title, String
      attribute :description, String
      attribute :instructions, String
      attribute :category_id, Integer

      validates :title, presence: true
      validates :description, presence: true
      validates :instructions, presence: true

      validates :category, presence: true, if: ->(form) { form.category_id.present? }

      def category
        return unless current_feature
        @category ||= current_feature.categories.where(id: category_id).first
      end
    end
  end
end
