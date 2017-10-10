# frozen_string_literal: true

module Decidim
  module Proposals
    # A service to encapsualte all the logic when searching and filtering
    # proposals in a participatory process.
    class ProposalSearch < ResourceSearch
      # Public: Initializes the service.
      # feature     - A Decidim::Feature to get the proposals from.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        super(Proposal.all, options)
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where("title ILIKE ?", "%#{search_text}%")
          .or(query.where("body ILIKE ?", "%#{search_text}%"))
      end

      # Handle the origin filter
      # The 'official' proposals doesn't have an author id
      def search_origin
        if origin == "official"
          query.where(decidim_author_id: nil)
        elsif origin == "citizens"
          query.where.not(decidim_author_id: nil)
        else # Assume 'all'
          query
        end
      end

      # Handle the activity filter
      def search_activity
        if activity.include? "voted"
          query
            .includes(:votes)
            .where(decidim_proposals_proposal_votes: {
                     decidim_author_id: options[:current_user]
                   })
        else
          query
        end
      end

      # Handle the state filter
      def search_state
        case state
        when "accepted"
          query.accepted
        when "rejected"
          query.rejected
        when "evaluating"
          query.evaluating
        else # Assume 'all'
          query
        end
      end

      # Filters Proposals by the name of the classes they are linked to. By default,
      # returns all Proposals. When a `related_to` param is given, then it camelcases item
      # to find the real class name and checks the links for the Proposals.
      #
      # The `related_to` param is expected to be in this form:
      #
      #   "decidim/meetings/meeting"
      #
      # This can be achieved by performing `klass.name.underscore`.
      #
      # Returns only those proposals that are linked to the given class name.
      def search_related_to
        from = query
               .joins(:resource_links_from)
               .where(decidim_resource_links: { to_type: related_to.camelcase })

        to = query
             .joins(:resource_links_to)
             .where(decidim_resource_links: { from_type: related_to.camelcase })

        query.where(id: from).or(query.where(id: to))
      end
    end
  end
end
