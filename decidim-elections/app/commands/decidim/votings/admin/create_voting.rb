# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A command with all the business logic when creating a new voting space
      class CreateVoting < Decidim::Command
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

          voting = create_voting!

          if voting.persisted?
            broadcast(:ok, voting)
          else
            form.errors.add(:banner_image, voting.errors[:banner_image]) if voting.errors.include? :banner_image
            form.errors.add(:introductory_image, voting.errors[:introductory_image]) if voting.errors.include? :introductory_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_voting!
          Decidim.traceability.create(
            Voting,
            form.current_user,
            organization: form.current_organization,
            title: form.title,
            slug: form.slug,
            description: form.description,
            scope: form.scope,
            start_time: form.start_time,
            end_time: form.end_time,
            promoted: form.promoted,
            banner_image: form.banner_image,
            introductory_image: form.introductory_image,
            voting_type: form.voting_type,
            census_contact_information: form.census_contact_information,
            show_check_census: form.show_check_census
          )
        end
      end
    end
  end
end
