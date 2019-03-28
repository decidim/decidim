# frozen_string_literal: true

module Decidim
  module Assemblies
    # Helpers related to the Assemblies filter by type.
    #
    # `filter` returns a Filter object from Decidim::FilterResource
    module FilterAssembliesHelper
      def available_filters
        %w(all) + Assembly::ASSEMBLY_TYPES
      end

      def filter_link(filter_name)
        Decidim::Assemblies::Engine
          .routes
          .url_helpers
          .assemblies_path(
            filter: {
              scope_id: filter.scope_id,
              area_id: filter.area_id,
              assembly_type: filter_name
            }
          )
      end

      def help_text
        t("help", scope: "decidim.assemblies.filter")
      end

      def filter_name(filter_key)
        t(filter_key, scope: "decidim.assemblies.filter")
      end

      def current_filter_name
        filter_name(filter.assembly_type)
      end
    end
  end
end
