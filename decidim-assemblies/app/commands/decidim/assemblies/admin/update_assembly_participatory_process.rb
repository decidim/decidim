# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      class UpdateAssemblyParticipatoryProcess < Rectify::Command
        def initialize(assembly_participatory_process, form)
          @assembly_participatory_process = assembly_participatory_process
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
          update_assembly_participatory_process

          broadcast(:ok, @assembly_participatory_process)
        end

        private

        attr_reader :form, :assembly_participatory_process

        def update_assembly_participatory_process
          @assembly_participatory_process.assign_attributes(attributes)
          @assembly_participatory_process.save! if @assembly_participatory_process.valid?
        end

        def attributes
          {
            participatory_process: form.participatory_process
          }
        end
      end
    end
  end
end
