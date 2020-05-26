# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that creates a new initiative type
      class CreateInitiativeType < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          initiative_type = create_initiative_type

          if initiative_type.persisted?
            broadcast(:ok, initiative_type)
          else
            form.errors.add(:banner_image, initiative_type.errors[:banner_image]) if initiative_type.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_initiative_type
          initiative_type = InitiativesType.new(
            organization: form.current_organization,
            title: form.title,
            description: form.description,
            signature_type: form.signature_type,
            attachments_enabled: form.attachments_enabled,
            undo_online_signatures_enabled: form.undo_online_signatures_enabled,
            custom_signature_end_date_enabled: form.custom_signature_end_date_enabled,
            promoting_committee_enabled: form.promoting_committee_enabled,
            minimum_committee_members: form.minimum_committee_members,
            banner_image: form.banner_image,
            collect_user_extra_fields: form.collect_user_extra_fields,
            extra_fields_legal_information: form.extra_fields_legal_information,
            validate_sms_code_on_votes: form.validate_sms_code_on_votes,
            document_number_authorization_handler: form.document_number_authorization_handler
          )

          return initiative_type unless initiative_type.valid?

          initiative_type.save
          initiative_type
        end
      end
    end
  end
end
