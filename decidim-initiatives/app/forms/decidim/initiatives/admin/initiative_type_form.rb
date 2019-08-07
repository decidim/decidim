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
        attribute :undo_online_signatures_enabled, Boolean
        attribute :minimum_committee_members, Integer
        attribute :collect_user_extra_fields, Boolean
        translatable_attribute :extra_fields_legal_information, String
        attribute :validate_sms_code_on_votes, Boolean
        attribute :document_number_authorization_handler, String

        validates :title, :description, translatable_presence: true
        validates :online_signature_enabled, inclusion: { in: [true, false] }
        validates :undo_online_signatures_enabled, inclusion: { in: [true, false] }
        validates :minimum_committee_members, numericality: { only_integer: true }, allow_nil: true
        validates :banner_image, presence: true, if: lambda { |form|
          form.context.initiative_type.nil?
        }

        def minimum_committee_members=(value)
          super(value.presence)
        end
      end
    end
  end
end
