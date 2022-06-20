# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when copying a new participatory
      # process in the system.
      class ImportParticipatoryProcess < Decidim::Command
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
            add_admins_as_followers(@imported_process)
          end

          broadcast(:ok, @imported_process)
        end

        private

        attr_reader :form

        def import_participatory_process
          importer = Decidim::ParticipatoryProcesses::ParticipatoryProcessImporter.new(form.current_organization, form.current_user)
          participatory_processes.each do |original_process|
            Decidim.traceability.perform_action!("import", Decidim::ParticipatoryProcess, form.current_user) do
              @imported_process = importer.import(original_process, form.current_user, title: form.title, slug: form.slug)
              importer.import_participatory_process_steps(original_process["participatory_process_steps"]) if form.import_steps?
              importer.import_categories(original_process["participatory_process_categories"]) if form.import_categories?
              importer.import_folders_and_attachments(original_process["attachments"]) if form.import_attachments?
              importer.import_components(original_process["components"]) if form.import_components?
              @imported_process
            end
          end
        end

        def participatory_processes
          document_parsed(form.document_text)
        end

        def document_parsed(document_text)
          JSON.parse(document_text)
        end

        def add_admins_as_followers(process)
          process.organization.admins.each do |admin|
            form = Decidim::FollowForm
                   .from_params(followable_gid: process.to_signed_global_id.to_s)
                   .with_context(
                     current_organization: process.organization,
                     current_user: admin
                   )

            Decidim::CreateFollow.new(form, admin).call
          end
        end
      end
    end
  end
end
