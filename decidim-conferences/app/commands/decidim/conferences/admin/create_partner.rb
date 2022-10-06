# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new partner
      # in the system.
      class CreatePartner < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # conference - The Conference that will hold the speaker
        def initialize(form, current_user, conference)
          @form = form
          @current_user = current_user
          @conference = conference
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          if conference_partner.valid?
            transaction do
              create_partner!
            end

            broadcast(:ok)
          else
            form.errors.add(:logo, conference_partner.errors[:logo]) if conference_partner.errors.include? :logo

            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :conference, :current_user

        def create_partner!
          log_info = {
            resource: {
              title: form.name
            },
            participatory_space: {
              title: conference.title
            }
          }

          @partner = Decidim.traceability.create!(
            Decidim::Conferences::Partner,
            form.current_user,
            attributes,
            log_info
          )
        end

        def conference_partner
          return @conference_partner if defined?(@conference_partner)

          @conference_partner = conference.partners.build
          @conference_partner.conference = conference
          @conference_partner.assign_attributes(attributes)
          @conference_partner
        end

        def attributes
          { conference: }.merge(
            form.attributes.slice(
              "name",
              "weight",
              "link",
              "partner_type",
              "logo",
              "remove_avatar"
            ).symbolize_keys
          )
        end
      end
    end
  end
end
