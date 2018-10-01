# frozen_string_literal: true

module Decidim
  class ActivitySearch < Searchlight::Search
    def base_query
      ActionLog
        .public
        .where(organization: options.fetch(:organization))
    end

    def run
      super.order(created_at: :desc)
    end

    def search_resource_type
      if resource_types.include?(resource_type)
        action = if publicable_resource_types.include?(resource_type)
                   "publish"
                 else
                   "create"
                 end

        query.where(resource_type: resource_type, action: action)
      else
        query
          .where(
            "(action = ? AND resource_type IN (?)) OR (action = ? AND resource_type IN (?))",
            "publish",
            publicable_resource_types,
            "create",
            (resource_types - publicable_resource_types)
          )
      end
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

    def publicable_resource_types
      @publicable_resource_types ||= resource_types.select { |klass| klass.constantize.column_names.include?("published_at") }
    end
  end
end
