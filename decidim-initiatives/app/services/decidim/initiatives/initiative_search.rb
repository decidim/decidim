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
        ids = []
        ids += state.member?("accepted") ? query.accepted.ids : []
        ids += state.member?("rejected") ? query.rejected.ids : []
        ids += state.member?("answered") ? query.answered.ids : []
        ids += state.member?("open") ? query.open.ids : []
        ids += state.member?("closed") ? query.closed.ids : []

        query.where(id: ids)
      end

      def search_type_id
        return query if type_ids.include?("all")

        types = InitiativesTypeScope.where(decidim_initiatives_types_id: type_ids).pluck(:id)

        query.where(scoped_type: types)
      end

      def search_author
        if author == "myself" && options[:current_user]
          co_authoring_initiative_ids = Decidim::InitiativesCommitteeMember.where(
            decidim_users_id: options[:current_user].id
          ).pluck(:decidim_initiatives_id)

          query.where(decidim_author_id: options[:current_user].id, decidim_author_type: Decidim::UserBaseEntity.name)
               .or(query.where(id: co_authoring_initiative_ids))
               .unscope(where: :published_at)
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

      def search_area_id
        return query if area_ids.include?("all")

        query.where(decidim_area_id: area_ids)
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

      # Private: Returns an array with checked area ids, handling area_types which are coded as its
      # areas ids joined by _.
      def area_ids
        area_id.map { |id| id.split("_") }.flatten.uniq
      end
    end
  end
end
