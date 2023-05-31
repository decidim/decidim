# frozen_string_literal: true

module Decidim
  module Sortitions
    module Admin
      # Query that retrieves a list of proposal components
      class ParticipatorySpaceProposalComponents < Decidim::Query
        attr_reader :participatory_space

        # Sugar syntax. Allow retrieving all proposal components for the
        # given participatory space.
        def self.for(participatory_space)
          new(participatory_space).query
        end

        # Initializes the query
        def initialize(participatory_space)
          @participatory_space = participatory_space
        end

        def query
          Component
            .where(participatory_space:, manifest_name: "proposals")
            .published
        end
      end
    end
  end
end
