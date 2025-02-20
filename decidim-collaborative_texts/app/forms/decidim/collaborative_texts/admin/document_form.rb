# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This class holds a Form to create/update documents from Decidim's admin panel.
      class DocumentForm < Decidim::Form
        include Decidim::TranslatableAttributes
        include Decidim::ApplicationHelper

        mimic :document

        attribute :title, String
        attribute :accepting_suggestions, Boolean, default: false
        translatable_attribute :announcement, Decidim::Attributes::RichText

        validates :title, presence: true, etiquette: true, if: ->(form) { form.title.present? }
        validates :body, presence: true, if: ->(form) { form.body.present? }
      end
    end
  end
end
