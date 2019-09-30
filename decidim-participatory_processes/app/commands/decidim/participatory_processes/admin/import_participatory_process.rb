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
            # copy_participatory_process_steps if @form.copy_steps?
            # copy_participatory_process_categories if @form.copy_categories?
            # copy_participatory_process_components if @form.copy_components?
          end

          broadcast(:ok, @imported_process)
        end

        private

        attr_reader :form

        def import_participatory_process
          text = document_parsed(form.document_text).first
          
          @imported_process = ParticipatoryProcess.create!(
            organization: form.current_organization,
            title: form.title,
            slug: form.slug,
            subtitle: text["subtitle"],
            hashtag: text["hashtag"],
            description: text["description"],
            short_description: text["short_description"],
            # hero_image: text["hero_image"],
            # banner_image: text["banner_image"],
            promoted: text["promoted"],
            # scope: @participatory_process.scope,
            developer_group: text["developer_group"],
            local_area: text["local_area"],
            # area: @participatory_process.area,
            target: text["target"],
            participatory_scope: text["participatory_scope"],
            participatory_structure: text["participatory_structure"],
            meta_scope: text["meta_scope"],
            start_date: text["start_date"],
            end_date: text["end_date"],
            # participatory_process_group: @participatory_process.participatory_process_group
          )
        end

        def document_parsed document_text
          JSON.parse(document_text)
        end
      end
    end
  end
end
