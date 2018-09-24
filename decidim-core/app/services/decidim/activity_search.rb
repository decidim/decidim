# frozen_string_literal: true

module Decidim
  # This class handles search and filtering of activities. Needs a
  # `current_component` param with a `Decidim::Component` in order to
  # find the activities.
  class ActivitySearch < ResourceSearch
    # Public: Initializes the service.
    # component   - A Decidim::Component to get the activities from.
    # page        - The page number to paginate the results.
    # per_page    - The number of proposals to return per page.
    def initialize(options = {})
      scope = options[:scope]
      scope ||= ActionLog
                .public
                .where(organization: options.fetch(:organization))
                .where(action: "create")
                .order(created_at: :desc)

      super(scope, options)
    end

    def base_query
      @scope
    end

    def search_resource_type
      resource_type = options[:resource_type]
      return query.where(resource_type: resource_type) if resource_type.present? && resource_types.include?(resource_type)

      query.where(resource_type: resource_types)
    end

    def resource_types
      %w(
        Decidim::Proposals::Proposal
        Decidim::Meetings::Meeting
        Decidim::Accountability::Result
        Decidim::Debates::Debate
        Decidim::Initiative
        Decidim::ParticipatoryProcess
        Decidim::Assembly
        Decidim::Consultation
        Decidim::Comments::Comment
      )
    end
  end
end
