# frozen_string_literal: true

module Decidim
  module Core
    # A very basic resolver for the GraphQL endpoint for listing participatory spaces
    # This can be easily overwritten by the participatory_space_manifest.query_list
    # + info:
    # https://github.com/rmosolgo/graphql-ruby/blob/v1.6.8/guides/fields/function.md
    class ParticipatorySpaceList < ParticipatorySpaceListBase
      argument :filter, ParticipatorySpaceInputFilter, "Provides several methods to filter the results"
      argument :order, ParticipatorySpaceInputSort, "Provides several methods to order the results"
    end
  end
end
