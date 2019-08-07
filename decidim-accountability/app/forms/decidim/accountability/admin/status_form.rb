# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This class holds a Form to create/update statuses from Decidim's admin panel.
      class StatusForm < Decidim::Form
        include TranslatableAttributes
        include TranslationsHelper

        attribute :key, String
        translatable_attribute :name, String
        translatable_attribute :description, String
        attribute :progress, Integer

        validates :key, presence: true
        validates :name, translatable_presence: true
      end
    end
  end
end
