# frozen_string_literal: true

module Decidim
  module Meetings
    # This class handles search and filtering of meetings. Needs a
    # `current_component` param with a `Decidim::Component` in order to
    # find the meetings.
    class MeetingSearch < ResourceSearch
      text_search_fields :title, :description

      # Public: Initializes the service.
      # component     - A Decidim::Component to get the meetings from.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        scope = options.fetch(:scope, Meeting.all)
        super(scope, options)
      end

      # Handle the date filter
      def search_date
        apply_scopes(%w(upcoming past), date)
      end

      def search_space
        return query if options[:space].blank? || options[:space] == "all"

        query.joins(:component).where(decidim_components: { participatory_space_type: options[:space].classify })
      end

      def search_type
        fields = Decidim::Meetings::Meeting::TYPE_OF_MEETING
        temp_query = Decidim::Meetings::Meeting.where("1=2")
        options[:type].each do |inquiry|
          temp_query = temp_query.or(Decidim::Meetings::Meeting.send(inquiry.to_sym)) if fields.include?(inquiry)
        end
        query.merge(temp_query)
      end

      # Handle the activity filter
      def search_activity
        case activity
        when "my_meetings"
          query
            .where(decidim_author_id: user.id)
        else
          query
        end
      end
    end
  end
end
