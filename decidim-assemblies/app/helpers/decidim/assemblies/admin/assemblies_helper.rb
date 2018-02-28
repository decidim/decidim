# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # This class contains helpers needed to format ParticipatoryProcesses
      # in order to use them in select forms for AssemblyParticipatoryProcess.
      #
      module AssembliesHelper
        # Public: A formatted collection of ParticipatoryProcesses to be used
        # in forms.
        #
        # Returns an Array.
        def processes_for_select
          @processes_for_select ||= Decidim::ParticipatoryProcess.where(organization: current_assembly.organization).map do |process|
            [
              translated_attribute(process.title),
              process.id
            ]
          end
        end

        # Public: A formatted collection of ParticipatoryProcesses selected on
        # Assemblies to be used in forms.
        #
        # Returns an Array.
        def processes_selected
          @processes_selected ||= current_assembly.linked_participatory_space_resources(:participatory_processes, "included_participatory_processes").pluck(:id)
        end
      end
    end
  end
end
