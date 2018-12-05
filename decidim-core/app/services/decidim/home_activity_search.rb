# frozen_string_literal: true

module Decidim
  # A class to search for recent activity performed in a Decidim Organization.
  # It will only return the `Decidim::ActionLog` rows that have an action as
  # `created` or `published`.
  #
  # This class is thought to be used in the `LastActivityCell` uniquely.
  class HomeActivitySearch < Searchlight::Search
    # Needed by Searchlight, this is the base query that will be used to
    # append other criteria to the search.
    def base_query
      ActionLog
        .where(visibility: %w(public-only all))
        .where(organization: options.fetch(:organization))
    end

    # Overwrites the default Searchlight run method since we want to return
    # activities in an specific order but we need to set it at the end of the chain.
    def run
      super.order(created_at: :desc)
    end

    # Adds a constrain to filter by resource type(s).
    def search_resource_type
      if resource_types.include?(resource_type)
        scope_for(resource_type)
      else
        all_resources_scope
      end
    end

    # All the resource types that are eligible to be included as an activity.
    def resource_types
      @resource_types ||= %w(
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
      ).select do |klass|
        klass.safe_constantize.present?
      end
    end

    private

    def publicable_resource_types
      @publicable_resource_types ||= resource_types.select { |klass| klass.constantize.column_names.include?("published_at") }
    end

    def scope_for(resource_type)
      action = if publicable_resource_types.include?(resource_type)
                 "publish"
               else
                 "create"
               end

      query.where(resource_type: resource_type, action: action)
    end

    def all_resources_scope
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
end
