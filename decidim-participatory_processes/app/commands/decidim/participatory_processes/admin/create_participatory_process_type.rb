# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process type in the system.
      class CreateParticipatoryProcessType < Decidim::Command
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

          create_participatory_process_type!

          broadcast(:ok)
        end

        private

        attr_reader :form

        def create_participatory_process_type!
          transaction do
            Decidim.traceability.create!(
              Decidim::ParticipatoryProcessType,
              form.current_user,
              organization: form.current_organization,
              title: form.title
            )
          end
        end
      end
    end
  end
end
