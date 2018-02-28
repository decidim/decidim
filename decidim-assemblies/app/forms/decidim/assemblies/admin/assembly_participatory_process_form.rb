# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A form object used to create assemblies from the admin
      # dashboard.
      #
      class AssemblyParticipatoryProcessForm < Form
        attribute :participatory_process_id, Integer
        attribute :assembly_id, Integer

        mimic :assembly_participatory_process

        def participatory_process
          @participatory_process ||= Decidim::ParticipatoryProcess.where(id: participatory_process_id).first
        end

        def assembly
          @assembly ||= Decidim::Assembly.where(id: assembly_id).first
        end

        validates :participatory_process, :assembly, presence: true

        validate :assembly_and_participatory_process_same_organization
        validate :participatory_process_uniqueness_for_assembly

        private

        # Private: check if the process and the assembly have the same organization
        def assembly_and_participatory_process_same_organization
          return if !assembly || !participatory_process
          errors.add(:participatory_process, :invalid) unless assembly.organization == participatory_process.organization
        end

        # Private: check if the assembly process relation exists for this assembly
        def participatory_process_uniqueness_for_assembly
          return unless AssemblyParticipatoryProcess.where(assembly: assembly).where(participatory_process: participatory_process).any?
          errors.add(:participatory_process_id, :taken)
        end
      end
    end
  end
end
