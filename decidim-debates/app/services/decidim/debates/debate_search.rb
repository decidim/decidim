# frozen_string_literal: true

module Decidim
  module Debates
    # This class handles search and filtering of debates. Needs a
    # `current_component` param with a `Decidim::Component` in order to
    # find the debates.
    class DebateSearch < ResourceSearch
      text_search_fields :title, :description

      # Public: Initializes the service.
      # component     - A Decidim::Component to get the debates from.
      # page        - The page number to paginate the results.
      # per_page    - The number of debates to return per page.
      def initialize(options = {})
        super(Debate.not_hidden, options)
      end

      # Handle the activity filter
      def search_activity
        case activity
        when "commented"
          query.commented_by(user)
        when "my_debates"
          query.authored_by(user)
        else # Assume 'all'
          query
        end
      end

      # Handle the state filter
      def search_state
        apply_scopes(%w(open closed), state)
      end
    end
  end
end
