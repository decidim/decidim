# frozen_string_literal: true

module Decidim
  module Budgets
    # This class handles search and filtering of projects. Needs a
    # `current_component` param with a `Decidim::Component` in order to
    # find the projects.
    class ProjectSearch < ResourceSearch
      # Public: Initializes the service.
      # component     - A Decidim::Component to get the projects from.
      def initialize(options = {})
        super(Project.all, options)
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where(localized_search_text_in(:title), text: "%#{search_text}%")
          .or(query.where(localized_search_text_in(:description), text: "%#{search_text}%"))
      end

      def search_category_id
        super
      end

      def search_scope_id
        super
      end

      # Returns the random projects for the current page.
      def results
        Project.where(id: super.pluck(:id)).includes([:scope, :component, :attachments, :category])
      end

      private

      # Internal: builds the needed query to search for a text in the organization's
      # available locales. Note that it is intended to be used as follows:
      #
      # Example:
      #   Resource.where(localized_search_text_for(:title, text: "my_query"))
      #
      # The Hash with the `:text` key is required or it won't work.
      def localized_search_text_in(field)
        options[:organization].available_locales.map do |l|
          "#{field} ->> '#{l}' ILIKE :text"
        end.join(" OR ")
      end
    end
  end
end
