# frozen_string_literal: true

module Decidim
  module Proposals
    # A service to encapsualte all the logic when searching and filtering
    # proposals in a participatory process.
    class ProposalSearch < ResourceSearch
      # Public: Initializes the service.
      # component     - A Decidim::Component to get the proposals from.
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
      def search_origin
        case origin
        when "official"
          query
            .where.not(coauthorships_count: 0)
            .joins(:coauthorships)
            .where(decidim_coauthorships: { decidim_author_type: "Decidim::Organization" })
        when "citizens"
          query
            .where.not(coauthorships_count: 0)
            .joins(:coauthorships)
            .where.not(decidim_coauthorships: { decidim_author_type: "Decidim::Organization" })
        when "user_group"
          query
            .where.not(coauthorships_count: 0)
            .joins(:coauthorships)
            .where(decidim_coauthorships: { decidim_author_type: "Decidim::UserBaseEntity" })
            .where.not(decidim_coauthorships: { decidim_user_group_id: nil })
        when "meeting"
          query
            .where.not(coauthorships_count: 0)
            .joins(:coauthorships)
            .where(decidim_coauthorships: { decidim_author_type: "Decidim::Meetings::Meeting" })
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
        when "withdrawn"
          query.withdrawn
        when "except_rejected"
          query.except_rejected.except_withdrawn
        else # Assume 'not_withdrawn'
          query.except_withdrawn
        end
      end

      # Handle the amendment type filter
      def search_type
        case type
        when "proposals"
          query.where.not(id: query.joins(:amendable).pluck(:id))
        when "amendments"
          query.where(id: query.joins(:amendable).pluck(:id))
        else
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

      # We overwrite the `results` method to ensure we only return unique
      # results. We can't use `#uniq` because it returns an Array and we're
      # adding scopes in the controller, and `#distinct` doesn't work here
      # because in the later scopes we're ordering by `RANDOM()` in a DB level,
      # and `SELECT DISTINCT` doesn't work with `RANDOM()` sorting, so we need
      # to perform two queries.
      #
      # The correct behaviour is backed by tests.
      def results
        Proposal.where(id: super.pluck(:id))
      end
    end
  end
end
