# frozen_string_literal: true

module Decidim
  module Assemblies
    # Helpers related to the Assemblies filter by type.
    module FilterAssembliesHelper
      def available_filters
        %w(all government executive consultative_advisory participatory working_group commission others)
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

      def current_filter
        params[:filter].try(:[], :assembly_type) || "all"
      end

      def filter_name(filter)
        t(filter, scope: "decidim.assemblies.filter")
      end

      def current_filter_name
        filter_name(current_filter)
      end
    end
  end
end
