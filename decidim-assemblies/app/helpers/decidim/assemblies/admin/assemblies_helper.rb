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
        def processes_selected
          if current_assembly.present?
            @processes_selected ||= current_assembly.linked_participatory_space_resources(:participatory_processes, "included_participatory_processes").pluck(:id)
          end
        end

        # Public: select options representing a collection of Assemblies that
        # can be selected as parent assemblies for another assembly; to be used in forms.
        def parent_assemblies_options
          options = []
          root_assemblies = ParentAssembliesForSelect.for(current_organization, current_assembly).where(parent_id: nil).sort_by(&:weight)

          root_assemblies.each do |assembly|
            build_assembly_options(assembly, options)
          end

          options
        end

        private

        # Recursively build the options for the assembly tree
        def build_assembly_options(assembly, options, level = 0)
          name = sanitize("#{"&nbsp;" * 4 * level} #{assembly.translated_title}")
          options << [name, assembly.id]

          # Skip the current assembly to avoid selecting a child as parent
          return if assembly == current_assembly

          assembly.children.each do |child|
            build_assembly_options(child, options, level + 1)
          end
        end
      end
    end
  end
end
