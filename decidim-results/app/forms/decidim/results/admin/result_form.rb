# frozen_string_literal: true
module Decidim
  module Results
    module Admin
      # This class holds a Form to create/update results from Decidim's admin panel.
      class ResultForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :short_description, String
        translatable_attribute :description, String
        attribute :decidim_scope_id, Integer
        attribute :decidim_category_id, Integer

        validates :title, translatable_presence: true
        validates :short_description, translatable_presence: true
        validates :description, translatable_presence: true

        validates :current_feature, presence: true
        validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }
        validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }

        def scope
          return unless current_feature
          @scope ||= current_feature.scopes.where(id: decidim_scope_id).first
        end

        def category
          return unless current_feature
          @category ||= current_feature.categories.where(id: decidim_category_id).first
        end
      end
    end
  end
end
