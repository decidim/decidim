# frozen_string_literal: true

module Decidim
  module Initiatives
    InitiativeApiType = GraphQL::ObjectType.define do
      name "InitiativeType"
      description "An initiative type"

      field :id, !types.ID, "The internal ID for this initiative type"
      field :title, Decidim::Core::TranslatedFieldType, "Initiative type name"
      field :description, Decidim::Core::TranslatedFieldType, "This is the initiative type description"
      field :createdAt, Decidim::Core::DateTimeType, "The date this initiative type was created", property: :created_at
      field :updatedAt, Decidim::Core::DateTimeType, "The date this initiative type was updated", property: :updated_at
      field :bannerImage, types.String, "Banner image", property: :banner_image
      field :collectUserExtraFields, types.Boolean, "Collect participant personal data on signature", property: :collect_user_extra_fields
      field :extraFieldsLegalInformation, types.String, "Legal information about the collection of personal data", property: :extra_fields_legal_information
      field :minimumCommitteeMembers, types.Int, "Minimum of committee members", property: :minimum_committee_members
      field :validateSmsCodeOnVotes, types.Boolean, "Add SMS code validation step to signature process", property: :validate_sms_code_on_votes
      field :undoOnlineSignaturesEnabled, types.Boolean, "Enable participants to undo their online signatures", property: :undo_online_signatures_enabled
      field :promotingComitteeEnabled, types.Boolean, "If promoting committee is enabled", property: :promoting_committee_enabled
      field :signatureType, types.String, "Signature type of the initiative", property: :signature_type

      field :initiatives, !types[Decidim::Initiatives::InitiativeType], "The initiatives that have this type"
    end
  end
end
