# frozen_string_literal: true

module Decidim
  module Core
    # A very basic resolver for the GraphQL endpoint for a single participatory spaces
    # This can be easily overwritten by the participatory_space_manifest.query_finder
    class ParticipatorySpaceFinder < ParticipatorySpaceFinderBase
      argument :id, types.ID, "The ID of the participatory space"
    end
  end
end
