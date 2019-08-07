# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A form object used to create participatory process groups from the admin
      # dashboard.
      #
      class ParticipatoryProcessGroupForm < Form
        include TranslatableAttributes

        translatable_attribute :name, String
        translatable_attribute :description, String
        attribute :participatory_process_ids, Array[Integer]

        mimic :participatory_process_group

        attribute :hero_image
        attribute :remove_hero_image

        validates :name, :description, translatable_presence: true

        validates :hero_image, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } }, file_content_type: { allow: ["image/jpeg", "image/png"] }
      end
    end
  end
end
