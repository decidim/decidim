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

        validates :title, :tos, translatable_presence: true
      end
    end
  end
end
