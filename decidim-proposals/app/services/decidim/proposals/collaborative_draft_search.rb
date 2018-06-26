# frozen_string_literal: true

module Decidim
  module Proposals
    # A service to encapsualte all the logic when searching and filtering
    # collaborative drafts in a participatory process.
    class CollaborativeDraftSearch < ResourceSearch
      # Public: Initializes the service.
      # component     - A Decidim::Component to get the drafts from.
      # page        - The page number to paginate the results.
      # per_page    - The number of drafts to return per page.
      def initialize(options = {})
        super(CollaborativeDraft.all, options)
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where("title ILIKE ?", "%#{search_text}%")
          .or(query.where("body ILIKE ?", "%#{search_text}%"))
      end

      # Handle the state filter
      def search_state
        case state
        when "open"
          query.open
        when "withdrawn"
          query.withdrawn
        when "published"
          query.published
        else
          query
        end
      end

      # Filters drafts by the name of the classes they are linked to. By default,
      # returns all drafts. When a `related_to` param is given, then it camelcases item
      # to find the real class name and checks the links for the Collaborative Draft.
      #
      # The `related_to` param is expected to be in this form:
      #
      #   "decidim/meetings/meeting"
      #
      # This can be achieved by performing `klass.name.underscore`.
      #
      # Returns only those drafts that are linked to the given class name.
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
