# frozen_string_literal: true

module Decidim
  module Initiatives
    class InitiativeApiType < GraphQL::Schema::Object
      graphql_name "InitiativeType"
      description "An initiative type"
      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false, description: "The internal ID for this initiative type"
      field :title, Decidim::Core::TranslatedFieldType, null: true, description: "Initiative type name"
      field :description, Decidim::Core::TranslatedFieldType, null: true, description: "This is the initiative type description"
      field :bannerImage, String, null: true, description: "Banner image" do
        def resolve(object:, _args:, context:)
          object.banner_image
        end
      end
      field :collectUserExtraFields, Boolean, null: true, description: "Collect participant personal data on signature" do
        def resolve(object:, _args:, context:)
          object.collect_user_extra_fields
        end
      end
      field :extraFieldsLegalInformation, String, null: true, description: "Legal information about the collection of personal data" do
        def resolve(object:, _args:, context:)
          object.extra_fields_legal_information
        end
      end
      field :minimumCommitteeMembers, Int, null: true, description: "Minimum of committee members" do
        def resolve(object:, _args:, context:)
          object.minimum_committee_members
        end
      end
      field :validateSmsCodeOnVotes, Boolean, null: true, description: "Add SMS code validation step to signature process" do
        def resolve(object:, _args:, context:)
          object.validate_sms_code_on_votes
        end
      end
      field :undoOnlineSignaturesEnabled, Boolean, null: true, description: "Enable participants to undo their online signatures" do
        def resolve(object:, _args:, context:)
          object.undo_online_signatures_enabled
        end
      end
      field :promotingComitteeEnabled, Boolean, null: true, description: "If promoting committee is enabled" do
        def resolve(object:, _args:, context:)
          object.promoting_committee_enabled
        end
      end
      field :signatureType, String, null: true, description: "Signature type of the initiative" do
        def resolve(object:, _args:, context:)
          object.signature_type
        end
      end

      field :initiatives, [Decidim::Initiatives::InitiativeType], null: false, description: "The initiatives that have this type"
    end
  end
end
