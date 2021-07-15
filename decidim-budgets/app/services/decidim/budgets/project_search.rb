# frozen_string_literal: true

module Decidim
  module Budgets
    # This class handles search and filtering of projects. Needs a
    # `current_component` param with a `Decidim::Component` in order to
    # find the projects.
    class ProjectSearch < ResourceSearch
      text_search_fields :title, :description

      # Public: Initializes the service.
      # component     - A Decidim::Component to get the projects from.
      def initialize(options = {})
        super(Project.all, options)
      end

      # Creates the SearchLight base query.
      def base_query
        raise "Missing budget" unless budget
        raise "Missing component" unless component

        @scope.where(budget: budget)
      end

      # Returns the random projects for the current page.
      def results
        Project.where(id: super.pluck(:id)).includes([:scope, :component, :attachments, :category])
      end

      def search_status
        return query if status.member?("all")

        apply_scopes(%w(selected not_selected), status)
      end

      private

      # Private: Since budget is not used by a search method we need
      # to define the method manually.
      def budget
        options[:budget]
      end
    end
  end
end
