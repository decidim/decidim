# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This class holds a Form to create/update milestone_entries from Decidim's admin panel.
      class MilestoneEntryForm < Decidim::Form
        include TranslatableAttributes
        include TranslationsHelper

        attribute :decidim_accountability_result_id, Integer
        attribute :entry_date, Decidim::Attributes::LocalizedDate
        translatable_attribute :title, String
        translatable_attribute :description, Decidim::Attributes::RichText

        validates :entry_date, presence: true
        validates :title, translatable_presence: true
      end
    end
  end
end
