# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A command with all the business logic when creating a new voting space
      class CreateVoting < Rectify::Command
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

          transaction do
            create_voting!
          end && broadcast(:ok)
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
            end_time: form.end_time
          )
        end
      end
    end
  end
end
