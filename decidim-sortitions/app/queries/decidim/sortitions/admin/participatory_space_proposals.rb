# frozen_string_literal: true

module Decidim
  module Sortitions
    module Admin
      class ParticipatorySpaceProposals < Decidim::Query
        # Sugar syntax. Retrieve all proposals for the given sortition.
        def self.for(sortition)
          new(sortition).query
        end

        # Initializes the class.
        #
        # sortition - a sortition to select proposals
        def initialize(sortition)
          @sortition = sortition
          @category = sortition.category
          @request_timestamp = sortition.request_timestamp
        end

        # Given a particpiatory process retrieves its proposals
        #
        # Returns an ActiveRecord::Relation.
        def query
          if category.nil?
            return Decidim::Proposals::Proposal
                   .except_withdrawn
                   .published
                   .except_rejected
                   .not_hidden
                   .where("decidim_proposals_proposals.created_at < ?", request_timestamp)
                   .where(component: sortition.decidim_proposals_component)
                   .order(id: :asc)
          end

          # categorization -> category
          Decidim::Proposals::Proposal
            .joins(:categorization)
            .except_withdrawn
            .published
            .except_rejected
            .not_hidden
            .where(component: sortition.decidim_proposals_component)
            .where("decidim_proposals_proposals.created_at < ?", request_timestamp)
            .where(decidim_categorizations: { decidim_category_id: category.id })
            .order(id: :asc)
        end

        private

        attr_reader :sortition, :category, :request_timestamp
      end
    end
  end
end
