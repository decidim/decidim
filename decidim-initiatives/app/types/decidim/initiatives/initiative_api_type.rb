# frozen_string_literal: true

module Decidim
  module Initiatives
    class InitiativeApiType < Decidim::Api::Types::BaseObject
      graphql_name "InitiativeType"
      description "An initiative type"

      field :id, ID, "The internal ID for this initiative type", null: false
      field :title, Decidim::Core::TranslatedFieldType, "Initiative type name", null: true
      field :description, Decidim::Core::TranslatedFieldType, "This is the initiative type description", null: true
      field :created_at, Decidim::Core::DateTimeType, "The date this initiative type was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "The date this initiative type was updated", null: true
      field :banner_image, String, "Banner image", null: true
      field :collect_user_extra_fields, Boolean, "Collect participant personal data on signature", null: true
      field :extra_fields_legal_information, String, "Legal information about the collection of personal data", null: true
      field :minimum_committee_members, Integer, "Minimum of committee members", null: true
      field :validate_sms_code_on_votes, Boolean, "Add SMS code validation step to signature process", null: true
      field :undo_online_signatures_enabled, Boolean, "Enable participants to undo their online signatures", null: true
      field :promoting_comittee_enabled, Boolean, "If promoting committee is enabled", method: :promoting_committee_enabled, null: true
      field :signature_type, String, "Signature type of the initiative", null: true

      field :initiatives, [Decidim::Initiatives::InitiativeType, { null: true }], "The initiatives that have this type", null: false
    end
  end
end
