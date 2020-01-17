# frozen_string_literal: true

module Decidim
  module Core
    # A very basic resolver for the GraphQL endpoint for listing participatory spaces
    class ParticipatorySpaceList < ParticipatorySpaceListBase
      argument :filter, ParticipatorySpaceInputFilter, "Provides several methods to filter the results"
      argument :order, ParticipatorySpaceInputSort, "Provides several methods to order the results"
    end
  end
end
