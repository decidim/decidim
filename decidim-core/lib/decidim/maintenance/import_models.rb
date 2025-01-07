# frozen_string_literal: true

module Decidim
  # This class should not be imported automatically by the Decidim web app
  # It holds utilities for maintenance tasks (such as importing taxonomies)
  # and compatibility models that might not be longer present in the current Decidim version
  module Maintenance
    module ImportModels
      autoload :ApplicationRecord, "decidim/maintenance/import_models/application_record"
      autoload :ParticipatoryProcessType, "decidim/maintenance/import_models/participatory_process_type"
      autoload :AssemblyType, "decidim/maintenance/import_models/assembly_type"
      autoload :Scope, "decidim/maintenance/import_models/scope"
      autoload :Area, "decidim/maintenance/import_models/area"
      autoload :AreaType, "decidim/maintenance/import_models/area_type"
      autoload :Category, "decidim/maintenance/import_models/category"
      autoload :Categorization, "decidim/maintenance/import_models/categorization"
    end
  end
end
