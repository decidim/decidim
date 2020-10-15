# frozen_string_literal: true

module Decidim
  module Proposals
    # A service to encapsualte all the logic when searching and filtering
    # proposals in a participatory process.
    class ProposalSearch < ResourceSearch
      text_search_fields :title, :body

      # Public: Initializes the service.
      # component     - A Decidim::Component to get the proposals from.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        base = options[:state]&.member?("withdrawn") ? Proposal.withdrawn : Proposal.except_withdrawn
        super(base, options)
      end

      # Handle the activity filter
      def search_activity
        case activity
        when "voted"
          query
            .includes(:votes)
            .where(decidim_proposals_proposal_votes: { decidim_author_id: user })
        when "my_proposals"
          query
            .where.not(coauthorships_count: 0)
            .joins(:coauthorships)
            .where(decidim_coauthorships: { decidim_author_type: "Decidim::UserBaseEntity" })
            .where(decidim_coauthorships: { decidim_author_id: user })
        else # Assume 'all'
          query
        end
      end

      # Handle the state filter
      def search_state
        return query if state.member? "withdrawn"

        apply_scopes(%w(accepted rejected evaluating state_not_published), state)
      end

      # Handle the amendment type filter
      def search_type
        case type
        when "proposals"
          query.only_amendables
        when "amendments"
          query.only_visible_emendations_for(user, component)
        else # Assume 'all'
          query.amendables_and_visible_emendations_for(user, component)
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
