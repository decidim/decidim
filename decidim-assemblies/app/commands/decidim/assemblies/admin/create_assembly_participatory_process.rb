# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      class CreateAssemblyParticipatoryProcess < Rectify::Command
        def initialize(form, assembly)
          @form = form
          @assembly = assembly
        end

        def call
          return broadcast(:invalid) if form.invalid?

          create_assembly_participatory_process
          broadcast(:ok)
        end

        private

        attr_reader :form

        def create_assembly_participatory_process
          assembly_participatory_process = AssemblyParticipatoryProcess.new(
            assembly: @assembly,
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
