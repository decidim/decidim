# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A form object used to create participatory process types from the admin
      # dashboard.
      #
      class ParticipatoryProcessTypeForm < Form
        include TranslatableAttributes

        mimic :participatory_process_type

        translatable_attribute :title, String

        validates :title, translatable_presence: true
      end
    end
  end
end
