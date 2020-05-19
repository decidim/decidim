# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This class holds a Form to create/update elections from Decidim's admin panel.
      class ElectionForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :subtitle, String
        translatable_attribute :description, String
        attribute :start_time, Decidim::Attributes::TimeWithZone
        attribute :end_time, Decidim::Attributes::TimeWithZone

        validates :title, translatable_presence: true
        validates :subtitle, translatable_presence: true
        validates :description, translatable_presence: true
        validates :start_time, presence: true, date: { before: :end_time }
        validates :end_time, presence: true, date: { after: :start_time }
      end
    end
  end
end
