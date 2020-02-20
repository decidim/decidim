# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A form object used to create assembly type from the admin dashboard.
      class AssembliesTypeForm < Form
        include TranslatableAttributes

        mimic :assemblies_type

        translatable_attribute :title, String
        validates :title, translatable_presence: true
      end
    end
  end
end
