# frozen_string_literal: true
module Decidim
  module Budgets
    # This class handles search and filtering of projects. Needs a
    # `current_feature` param with a `Decidim::Feature` in order to
    # find the projects.
    class ProjectSearch < ResourceSearch
      # Public: Initializes the service.
      # feature     - A Decidim::Feature to get the projects from.
      def initialize(options = {})
        super(Project.all, options)
        @random_seed = options[:random_seed].to_f
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where(localized_search_text_in(:title), text: "%#{search_text}%")
          .or(query.where(localized_search_text_in(:description), text: "%#{search_text}%"))
      end

      # Handle the scope_id filter
      def search_scope_id
        query.where(decidim_scope_id: scope_id)
      end

      # Returns the random projects for the current page.
      def results
        @projects ||= Project.transaction do
          Project.connection.execute("SELECT setseed(#{Project.connection.quote(random_seed)})")
          super.reorder("RANDOM()").load
        end
      end

      # Returns the random seed used to randomize the proposals.
      def random_seed
        @random_seed = (rand * 2 - 1) if @random_seed == 0.0 || @random_seed > 1 || @random_seed < -1
        @random_seed
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
