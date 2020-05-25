# frozen_string_literal: true

module Decidim
  module Initiatives
    # Service that encapsulates all logic related to filtering initiatives.
    class InitiativeSearch < Searchlight::Search
      include CurrentLocale

      # Public: Initializes the service.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        super(options)
      end

      def base_query
        Decidim::Initiative
          .includes(scoped_type: [:scope])
          .joins("JOIN decidim_users ON decidim_users.id = decidim_initiatives.decidim_author_id")
          .where(organization: options[:organization])
          .published
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where("title->>'#{current_locale}' ILIKE ?", "%#{search_text}%")
          .or(
            query.where(
              "description->>'#{current_locale}' ILIKE ?",
              "%#{search_text}%"
            )
          )
          .or(
            query.where(
              "cast(decidim_initiatives.id as text) ILIKE ?", "%#{search_text}%"
            )
          )
          .or(
            query.where(
              "decidim_users.name ILIKE ? OR decidim_users.nickname ILIKE ?", "%#{search_text}%", "%#{search_text}%"
            )
          )
      end

      # Handle the state filter
      def search_state
        accepted = state.member?("accepted") ? query.accepted : nil
        rejected = state.member?("rejected") ? query.rejected : nil
        answered = state.member?("answered") ? query.answered : nil
        open = state.member?("open") ? query.open : nil
        closed = state.member?("closed") ? query.closed : nil

        query
          .where(id: accepted)
          .or(query.where(id: rejected))
          .or(query.where(id: answered))
          .or(query.where(id: open))
          .or(query.where(id: closed))
      end

      def search_type_id
        return query if type_ids.include?("all")

        types = InitiativesTypeScope.where(decidim_initiatives_types_id: type_ids).pluck(:id)

        query.where(scoped_type: types)
      end

      def search_author
        if author == "myself" && options[:current_user]
          query.where(decidim_author_id: options[:current_user].id)
        else
          query
        end
      end

      def search_scope_id
        return query if scope_ids.include?("all")

        clean_scope_ids = scope_ids

        conditions = []
        conditions << "decidim_initiatives_type_scopes.decidim_scopes_id IS NULL" if clean_scope_ids.delete("global")
        conditions.concat(["? = ANY(decidim_scopes.part_of)"] * clean_scope_ids.count) if clean_scope_ids.any?

        query.joins(:scoped_type).references(:decidim_scopes).where(conditions.join(" OR "), *clean_scope_ids.map(&:to_i))
      end

      private

      # Private: Returns an array with checked type ids.
      def type_ids
        [type_id].flatten
      end

      # Private: Returns an array with checked scope ids.
      def scope_ids
        [scope_id].flatten
      end
    end
  end
end
