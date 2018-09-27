# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to import a collection of proposals
      # from a participatory text.
      class ImportParticipatoryTextForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :document

        validates :document, presence: true
        validates :title, translatable_presence: true

        def default_locale
          current_participatory_space.organization.default_locale
        end
      end
    end
  end
end
