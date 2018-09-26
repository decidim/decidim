# frozen_string_literal: true

module Decidim
  class ActivitySearch < ResourceSearch
    def initialize(options = {})
      @organization = options.fetch(:organization)
      scope = options[:scope] || default_scope
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
        Decidim::Accountability::Result
        Decidim::Blogs::Post
        Decidim::Comments::Comment
        Decidim::Consultations::Question
        Decidim::Debates::Debate
        Decidim::Meetings::Meeting
        Decidim::Proposals::Proposal
        Decidim::Surveys::Survey
        Decidim::Assembly
        Decidim::Consultation
        Decidim::Initiative
        Decidim::ParticipatoryProcess
      )
    end

    def default_scope
      ActionLog
        .public
        .where(organization: @organization)
        .where(action: "create")
        .order(created_at: :desc)
    end
  end
end
