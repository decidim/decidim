# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that updates an
      # existing initiative type.
      class UpdateInitiativeType < Decidim::Command
        include ::Decidim::AttachmentAttributesMethods

        # Public: Initializes the command.
        #
        # initiative_type: Decidim::InitiativesType
        # form - A form object with the params.
        def initialize(initiative_type, form, user)
          @form = form
          @initiative_type = initiative_type
          @user = user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          Decidim.traceability.perform_action!("update", initiative_type, @user) do
            initiative_type.update(attributes)

            if initiative_type.valid?
              update_initiatives_signature_type
              broadcast(:ok, initiative_type)
            else
              broadcast(:invalid)
            end
          end
        end

        private

        attr_reader :form, :initiative_type

        def attributes
          {
            title: form.title,
            description: form.description,
            signature_type: form.signature_type,
            attachments_enabled: form.attachments_enabled,
            comments_enabled: form.comments_enabled,
            undo_online_signatures_enabled: form.undo_online_signatures_enabled,
            custom_signature_end_date_enabled: form.custom_signature_end_date_enabled,
            area_enabled: form.area_enabled,
            promoting_committee_enabled: form.promoting_committee_enabled,
            minimum_committee_members: form.minimum_committee_members,
            collect_user_extra_fields: form.collect_user_extra_fields,
            extra_fields_legal_information: form.extra_fields_legal_information,
            validate_sms_code_on_votes: form.validate_sms_code_on_votes,
            document_number_authorization_handler: form.document_number_authorization_handler,
            child_scope_threshold_enabled: form.child_scope_threshold_enabled,
            only_global_scope_enabled: form.only_global_scope_enabled
          }.merge(
            attachment_attributes(:banner_image)
          )
        end

        def update_initiatives_signature_type
          initiative_type.initiatives.signature_type_updatable.each do |initiative|
            initiative.update!(signature_type: initiative_type.signature_type)
          end
        end
      end
    end
  end
end
