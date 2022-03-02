# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when updating a participatory
      # process type in the system.
      class UpdateParticipatoryProcessType < Decidim::Command
        # Public: Initializes the command.
        #
        # participatory_process_type - A participatory_process_type object to
        # update
        # form - A form object with the params.
        def initialize(participatory_process_type, form)
          @participatory_process_type = participatory_process_type
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

          update_participatory_process_type!

          broadcast(:ok)
        end

        private

        attr_reader :form, :participatory_process_type

        def update_participatory_process_type!
          transaction do
            Decidim.traceability.update!(
              participatory_process_type,
              form.current_user,
              title: form.title
            )
          end
        end
      end
    end
  end
end
