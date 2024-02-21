# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # This class holds a Form to update templates.
      class TemplateForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :name, String
        translatable_attribute :description, String

        validates :name, translatable_presence: true, unless: :skip_name_validation

        def skip_name_validation = false
      end
    end
  end
end
