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
    end
  end
end
