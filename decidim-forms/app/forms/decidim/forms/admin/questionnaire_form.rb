# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This class holds a Form to update questionnaires from Decidim's admin panel.
      class QuestionnaireForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :tos, String
        translatable_attribute :announcement, String

        attribute :allow_answers, Boolean
        attribute :allow_unregistered, Boolean
        attribute :clean_after_publish, Boolean
        attribute :starts_at, Decidim::Attributes::TimeWithZone
        attribute :ends_at, Decidim::Attributes::TimeWithZone

        validates :title, :tos, translatable_presence: true
      end
    end
  end
end
