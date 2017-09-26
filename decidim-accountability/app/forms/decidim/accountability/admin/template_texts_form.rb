# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This class holds a Form to create/update template texts from Decidim's admin panel.
      class TemplateTextsForm < Decidim::Form
        include TranslatableAttributes
        include TranslationsHelper

        translatable_attribute :intro, String
        translatable_attribute :categories_label, String
        translatable_attribute :subcategories_label, String
        translatable_attribute :heading_parent_level_results, String
        translatable_attribute :heading_leaf_level_results, String
      end
    end
  end
end
