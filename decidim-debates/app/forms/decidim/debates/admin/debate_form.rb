# frozen_string_literal: true
module Decidim
  module Debates
    module Admin
      # This class holds a Form to create/update debates from Decidim's admin panel.
      class DebateForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :instructions, String
        attribute :start_time, DateTime
        attribute :end_time, DateTime
        attribute :decidim_category_id, Integer

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :instructions, translatable_presence: true
        validates :start_time, presence: true, date: { before: :end_time }
        validates :end_time, presence: true, date: { after: :start_time }

        validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }

        def category
          return unless current_feature
          @category ||= current_feature.categories.where(id: decidim_category_id).first
        end
      end
    end
  end
end
