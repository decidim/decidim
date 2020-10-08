# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A form object used to create participatory process groups from the admin
      # dashboard.
      #
      class ParticipatoryProcessGroupForm < Form
        include TranslatableAttributes
        include Decidim::HasUploadValidations

        translatable_attribute :name, String
        translatable_attribute :description, String
        attribute :hashtag, String
        attribute :participatory_process_ids, Array[Integer]

        mimic :participatory_process_group

        attribute :hero_image
        attribute :remove_hero_image

        validates :name, :description, translatable_presence: true

        validates :hero_image, passthru: { to: Decidim::ParticipatoryProcessGroup }

        alias organization current_organization
      end
    end
  end
end
