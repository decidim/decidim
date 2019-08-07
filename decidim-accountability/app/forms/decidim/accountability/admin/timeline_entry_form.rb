# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This class holds a Form to create/update timeline_entries from Decidim's admin panel.
      class TimelineEntryForm < Decidim::Form
        include TranslatableAttributes
        include TranslationsHelper

        attribute :decidim_accountability_result_id, Integer
        attribute :entry_date, Decidim::Attributes::LocalizedDate
        translatable_attribute :description, String

        validates :entry_date, presence: true
        validates :description, translatable_presence: true
      end
    end
  end
end
