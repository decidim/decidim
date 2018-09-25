# frozen_string_literal: true

module Decidim
  class ActivitySearch < ResourceSearch
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
