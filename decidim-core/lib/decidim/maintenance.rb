# frozen_string_literal: true

module Decidim
  # This class should not be imported automatically by the Decidim web app
  # It holds utilitites for maintenance tasks (such as importing taxonomies)
  # and compatibility models that might not be longer present in the current Decidim version
  module Maintenance
    autoload :TaxonomyImporter, "decidim/maintenance/taxonomy_importer"
    autoload :TaxonomyPlan, "decidim/maintenance/taxonomy_plan"
    autoload :ParticipatoryProcessType, "decidim/maintenance/participatory_process_type"
  end
end
