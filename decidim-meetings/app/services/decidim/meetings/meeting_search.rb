# frozen_string_literal: true

module Decidim
  module Meetings
    # This class handles search and filtering of meetings. Needs a
    # `current_component` param with a `Decidim::Component` in order to
    # find the meetings.
    class MeetingSearch < ResourceSearch
      # Public: Initializes the service.
      # component     - A Decidim::Component to get the meetings from.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        scope = options.fetch(:scope, Meeting.all)
        super(scope, options)
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where(localized_search_text_in(:title), text: "%#{search_text}%")
          .or(query.where(localized_search_text_in(:description), text: "%#{search_text}%"))
      end

      # Handle the date filter
      def search_date
        upcoming = [date].flatten.member?("upcoming") ? query.upcoming : nil
        past = [date].flatten.member?("past") ? query.past : nil

        query
          .where(id: upcoming)
          .or(query.where(id: past))
      end

      def search_space
        return query if options[:space].blank? || options[:space] == "all"

        query.joins(:component).where(decidim_components: { participatory_space_type: options[:space].classify })
      end

      # Handle the origin filter
      def search_origin
        organizer_types = []

        organizer_types << "Decidim::Organization" if origin.member?("official")
        organizer_types << "Decidim::User" if origin.member?("citizens")
        organizer_types << "Decidim::UserGroup" if origin.member?("user_group")

        query.where(organizer_type: organizer_types)
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
        options[:organization].available_locales.map { |l| "#{field} ->> '#{l}' ILIKE :text" }.join(" OR ")
      end
    end
  end
end
