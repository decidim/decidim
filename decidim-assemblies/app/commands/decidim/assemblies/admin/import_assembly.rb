# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic to import a new assembly
      # in the system.
      class ImportAssembly < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # assembly - An assembly we want to duplicate
        def initialize(form, user)
          @form = form
          @user = user
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
            import_assembly
            add_admins_as_followers(@imported_assembly)
          end

          broadcast(:ok, @imported_assembly)
        end

        private

        attr_reader :form

        def import_assembly
          importer = Decidim::Assemblies::AssemblyImporter.new(form.current_organization, form.current_user)
          assemblies.each do |original_assembly|
            Decidim.traceability.perform_action!("import", Assembly, @user) do
              @imported_assembly = importer.import(original_assembly, form.current_user, title: form.title, slug: form.slug)
              importer.import_assemblies_type(original_assembly["decidim_assemblies_type_id"])
              importer.import_categories(original_assembly["assembly_categories"]) if form.import_categories?
              importer.import_folders_and_attachments(original_assembly["attachments"]) if form.import_attachments?
              importer.import_components(original_assembly["components"]) if form.import_components?
              @imported_assembly
            end
          end
        end

        def assemblies
          document_parsed(form.document_text)
        end

        def document_parsed(document_text)
          JSON.parse(document_text)
        end

        def add_admins_as_followers(assembly)
          assembly.organization.admins.each do |admin|
            form = Decidim::FollowForm
                   .from_params(followable_gid: assembly.to_signed_global_id.to_s)
                   .with_context(
                     current_organization: assembly.organization,
                     current_user: admin
                   )

            Decidim::CreateFollow.new(form, admin).call
          end
        end
      end
    end
  end
end
