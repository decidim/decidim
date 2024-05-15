# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that creates a new initiative type
      class CreateInitiativeType < Decidim::Commands::CreateResource
        fetch_file_attributes :banner_image

        fetch_form_attributes :title, :description, :signature_type, :comments_enabled, :attachments_enabled,
                              :undo_online_signatures_enabled, :custom_signature_end_date_enabled, :area_enabled,
                              :promoting_committee_enabled, :minimum_committee_members, :collect_user_extra_fields,
                              :extra_fields_legal_information, :validate_sms_code_on_votes, :document_number_authorization_handler,
                              :child_scope_threshold_enabled, :only_global_scope_enabled, :organization

        protected

        def resource_class = Decidim::InitiativesType
      end
    end
  end
end
