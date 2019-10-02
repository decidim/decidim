# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when copying a new participatory
      # process in the system.
      class ImportParticipatoryProcess < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # participatory_process - A participatory_process we want to duplicate
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
            import_participatory_process
          end

          broadcast(:ok, @imported_process)
        end

        private

        attr_reader :form

        def import_participatory_process
          participatory_processes.map do |original_process|
            Decidim::ParticipatoryProcesses::ParticipatoryProcessImporter.import(original_process, form)
            if form.import_steps?
              Decidim::ParticipatoryProcesses::ParticipatoryProcessImporter.import_participatory_process_steps(
                original_process["participatory_process_steps"], form
              )
            end
            Decidim::ParticipatoryProcesses::ParticipatoryProcessImporter.import_categories(original_process["participatory_process_categories"], form) if form.import_categories?
            Decidim::ParticipatoryProcesses::ParticipatoryProcessImporter.import_folders_and_attachments(original_process["attachments"], form) if form.import_attachments?
          end.compact
        end

        def participatory_processes
          document_parsed(form.document_text)
        end

        def document_parsed(document_text)
          JSON.parse(document_text)
        end
      end
    end
  end
end
