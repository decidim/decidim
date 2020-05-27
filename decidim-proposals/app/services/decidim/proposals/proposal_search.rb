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
        @component = options[:component]
        @current_user = options[:current_user]

        base = options[:state]&.member?("withdrawn") ? Proposal.withdrawn : Proposal.except_withdrawn
        super(base, options)
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where("title ILIKE ?", "%#{search_text}%")
          .or(query.where("body ILIKE ?", "%#{search_text}%"))
      end

      # Handle the origin filter
      def search_origin
        official = origin.member?("official") ? query.official_origin : nil
        citizens = origin.member?("citizens") ? query.citizens_origin : nil
        user_group = origin.member?("user_group") ? query.user_group_origin : nil
        meeting = origin.member?("meeting") ? query.meeting_origin : nil

        query
          .where(id: official)
          .or(query.where(id: citizens))
          .or(query.where(id: user_group))
          .or(query.where(id: meeting))
      end

      # Handle the activity filter
      def search_activity
        case activity
        when "voted"
          query
            .includes(:votes)
            .where(decidim_proposals_proposal_votes: { decidim_author_id: @current_user })
        when "my_proposals"
          query
            .where.not(coauthorships_count: 0)
            .joins(:coauthorships)
            .where(decidim_coauthorships: { decidim_author_type: "Decidim::UserBaseEntity" })
            .where(decidim_coauthorships: { decidim_author_id: @current_user })
        else # Assume 'all'
          query
        end
      end

      # Handle the state filter
      def search_state
        return query if state.member? "withdrawn"

        accepted = state.member?("accepted") ? query.accepted : nil
        rejected = state.member?("rejected") ? query.rejected : nil
        evaluating = state.member?("evaluating") ? query.evaluating : nil
        not_answered = state.member?("not_answered") ? query.state_not_published : nil

        query
          .where(id: accepted)
          .or(query.where(id: rejected))
          .or(query.where(id: evaluating))
          .or(query.where(id: not_answered))
      end

      # Handle the amendment type filter
      def search_type
        case type
        when "proposals"
          query.only_amendables
        when "amendments"
          query.only_visible_emendations_for(@current_user, @component)
        else # Assume 'all'
          query.amendables_and_visible_emendations_for(@current_user, @component)
        end
      end

      def search_category_id
        super
      end

      def search_scope_id
        super
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
