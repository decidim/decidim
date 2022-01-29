# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query filters participatory process groups so only promoted ones are returned.
    class PromotedParticipatoryProcessGroups < Decidim::Query
      def query
        Decidim::ParticipatoryProcessGroup.promoted
      end
    end
  end
end
