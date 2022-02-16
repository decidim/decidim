# frozen_string_literal: true

module Decidim
  module Meetings
    # This service scopes the meeting searches with parameters that cannot be
    # passed from the user interface.
    class MeetingSearch < ResourceSearch
      attr_reader :activity

      def build(params)
        @activity = params[:activity]

        add_scope(:authored_by, user) if params[:activity] == "my_meetings" && user

        super
      end
    end
  end
end
