# frozen_string_literal: true

module Decidim
  module Core
    # A very basic resolver for the GraphQL endpoint for listing participatory spaces
    # This can be easily overwritten by the participatory_space_manifest.query_list
    # + info:
    # https://github.com/rmosolgo/graphql-ruby/blob/v1.6.8/guides/fields/function.md
    class ParticipatorySpaceList < ParticipatorySpaceListBase
      argument :filter, ParticipatorySpaceInputFilter, "This argument let's you filter the results"
      argument :order, ParticipatorySpaceInputSort, "This argument let's you order the results"
    end
  end
end
