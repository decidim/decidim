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
        attribute :body, Decidim::Attributes::RichText
        attribute :accepting_suggestions, Boolean, default: false
        attribute :draft, Boolean, default: false
        translatable_attribute :announcement, Decidim::Attributes::RichText

        validates :title, presence: true, etiquette: true, unless: ->(form) { form.title.nil? }
        validates :body, presence: true, unless: ->(form) { form.body.nil? } # no etiquette validation for body as it might trigger false positives

        def coauthorships
          # ensures the first author is always the organization in case "official?" is ever used
          [Decidim::Coauthorship.new(author: current_organization)]
        end
      end
    end
  end
end
