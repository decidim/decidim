# frozen_string_literal: true

module Decidim
  # This class handles search and filtering of activities. Needs a
  # `current_component` param with a `Decidim::Component` in order to
  # find the activities.
  class ActivitySearch < ResourceSearch
    # Public: Initializes the service.
    # component     - A Decidim::Component to get the activities from.
    # page        - The page number to paginate the results.
    # per_page    - The number of proposals to return per page.
    def initialize(options = {})
      scope = options.fetch(:scope)
      super(scope, options)
    end

    def base_query
      @scope
    end

    def search_resource_type
      return query if options[:resource_type].blank? || options[:resource_type] == "all"
    end
  end
end
