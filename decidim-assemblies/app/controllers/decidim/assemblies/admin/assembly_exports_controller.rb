# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      class AssemblyExportsController < Decidim::Admin::ApplicationController
        include Concerns::AssemblyAdmin
        include Decidim::Admin::ParticipatorySpaceExport

        def exportable_space
          current_assembly
        end

        def manifest_name
          current_assembly.manifest.name.to_s
        end

        def after_export_path
          assembly_path(current_assembly.slug)
        end
      end
    end
  end
end
