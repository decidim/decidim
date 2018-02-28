# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new assembly
      # participatory process
      class CreateAssemblyParticipatoryProcess < Rectify::Command
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

          create_assembly_participatory_process
          broadcast(:ok)
        end

        private

        attr_reader :form

        def create_assembly_participatory_process
          assembly_participatory_process = AssemblyParticipatoryProcess.new(
            assembly: form.assembly,
            participatory_process: form.participatory_process
          )

          return assembly_participatory_process unless assembly_participatory_process.valid?
          assembly_participatory_process.save!
          assembly_participatory_process
        end
      end
    end
  end
end
