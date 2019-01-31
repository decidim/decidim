# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that updates an
      # existing initiative type.
      class UpdateInitiativeType < Rectify::Command
        # Public: Initializes the command.
        #
        # initiative_type: Decidim::InitiativesType
        # form - A form object with the params.
        def initialize(initiative_type, form)
          @form = form
          @initiative_type = initiative_type
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          initiative_type.update(attributes)

          if initiative_type.valid?
            upate_initiatives_signature_type
            broadcast(:ok, initiative_type)
          else
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :initiative_type

        def attributes
          result = {
            title: form.title,
            description: form.description,
            online_signature_enabled: form.online_signature_enabled,
            minimum_committee_members: form.minimum_committee_members,
            collect_user_extra_fields: form.collect_user_extra_fields,
            extra_fields_legal_information: form.extra_fields_legal_information,
            validate_sms_code_on_votes: form.validate_sms_code_on_votes
          }

          result[:banner_image] = form.banner_image unless form.banner_image.nil?
          result
        end

        def upate_initiatives_signature_type
          unless initiative_type.online_signature_enabled
            initiative_type.initiatives.signature_type_updatable.each do |initiative|
              initiative.update!(signature_type: Initiative.signature_types["offline"])
            end
          end
        end
      end
    end
  end
end
