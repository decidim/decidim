# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A form object used to collect the all the initiative type attributes.
      class InitiativeTypeForm < Decidim::Form
        include TranslatableAttributes

        mimic :initiatives_type

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :banner_image, String
        attribute :online_signature_enabled, Boolean

        validates :title, :description, translatable_presence: true
        validates :online_signature_enabled, inclusion: { in: [true, false] }
        validates :banner_image, presence: true, if: lambda { |form|
          form.context.initiative_type.nil?
        }
      end
    end
  end
end
