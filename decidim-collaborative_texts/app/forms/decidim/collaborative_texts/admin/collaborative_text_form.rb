# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This class holds a Form to create/update collaborative texts from Decidim's admin panel.
      class CollaborativeTextForm < Decidim::Form
        mimic :document

        attribute :title, String

        validates :title, presence: true
      end
    end
  end
end
