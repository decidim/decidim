# frozen_string_literal: true

module Decidim
  module Initiatives
    class InitiativeApiType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface

      graphql_name "InitiativeType"
      description "An initiative type"

      field :attachments_enabled, GraphQL::Types::Boolean, "Enable attachments on initiative types", null: true
      field :banner_image, GraphQL::Types::String, "Banner image", null: true
      field :collect_user_extra_fields, GraphQL::Types::Boolean, "Collect participant personal data on signature", null: true
      field :comments_enabled, GraphQL::Types::Boolean, "Enable comments on initiative types", null: true
      field :custom_signature_end_date_enabled, GraphQL::Types::Boolean, "Enable participants to set custom signature end date", null: true
      field :description, Decidim::Core::TranslatedFieldType, "This is the initiative type description", null: true
      field :extra_fields_legal_information, GraphQL::Types::String, "Legal information about the collection of personal data", null: true
      field :id, GraphQL::Types::ID, "The internal ID for this initiative type", null: false
      field :initiatives, [Decidim::Initiatives::InitiativeType, { null: true }], "The initiatives that have this type", null: false
      field :minimum_committee_members, GraphQL::Types::Int, "Minimum of committee members", null: true
      field :promoting_committee_enabled, GraphQL::Types::Boolean, "If promoting committee is enabled", null: true
      field :signature_type, GraphQL::Types::String, "Signature type of the initiative", null: true
      field :title, Decidim::Core::TranslatedFieldType, "Initiative type name", null: true
      field :undo_online_signatures_enabled, GraphQL::Types::Boolean, "Enable participants to undo their online signatures", null: true
      field :validate_sms_code_on_votes, GraphQL::Types::Boolean, "Add SMS code validation step to signature process", null: true

      def banner_image
        object.attached_uploader(:banner_image).url
      end
    end
  end
end
