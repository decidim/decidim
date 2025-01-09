# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This class holds a Form to update questionnaires from Decidim's admin panel.
      class QuestionnaireForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, Decidim::Attributes::RichText
        translatable_attribute :tos, Decidim::Attributes::RichText

        validates :title, :tos, translatable_presence: true
      end
    end
  end
end
