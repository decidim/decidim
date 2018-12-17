# frozen_string_literal: true

module Decidim
  module Assemblies
    # Helpers related to the Assemblies filter by type.
    module FilterAssembliesHelper
      def available_filters
        %w(all government executive consultative_advisory participatory working_group commission others)
      end

      def filter_link(filter)
        link_to t(filter, scope: "decidim.assemblies.filter"), url_for(params.to_unsafe_h.merge(page: nil, filter: filter)), data: { filter: filter }, remote: true
      end

      def label_text
        t("label", scope: "decidim.assemblies.filter")
      end

      def placeholder_text
        t("placeholder", scope: "decidim.assemblies.filter")
      end
    end
  end
end
