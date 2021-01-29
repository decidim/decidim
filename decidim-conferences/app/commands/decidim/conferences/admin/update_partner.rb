# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when updating a conference
      # partner in the system.
      class UpdatePartner < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # conference_partner - The ConferencePartner to update
        def initialize(form, conference_partner)
          form.logo = conference_partner.logo if form.logo.blank?

          @form = form
          @conference_partner = conference_partner
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless conference_partner

          # We are going to assign the attributes only to handle the validation of the avatar before accessing
          # `update_conference_partner!` which uses `update!`. Without this step, the image validation may render
          # an ActiveRecord::RecordInvalid error
          # After we assign and check if the object is valid, we reload the model to let it be handled the old way
          # If there is an error we add the error to the form
          conference_partner.assign_attributes(attributes)
          if conference_partner.valid?
            conference_partner.reload

            update_conference_partner!
            broadcast(:ok)
          else
            form.errors.add(:logo, conference_partner.errors[:logo]) if conference_partner.errors.include? :logo

            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :conference_partner

        def attributes
          form.attributes.slice(
            :name,
            :weight,
            :partner_type,
            :link,
            :logo,
            :remove_logo
          )
        end

        def update_conference_partner!
          log_info = {
            resource: {
              title: conference_partner.name
            },
            participatory_space: {
              title: conference_partner.conference.title
            }
          }

          Decidim.traceability.update!(
            conference_partner,
            form.current_user,
            attributes,
            log_info
          )
        end
      end
    end
  end
end
