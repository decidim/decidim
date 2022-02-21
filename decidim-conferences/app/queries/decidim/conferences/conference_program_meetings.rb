# frozen_string_literal: true

module Decidim
  module Conferences
    # This query class filters meetings for component and day
    class ConferenceProgramMeetings < Decidim::Query
      def initialize(component, user = nil)
        @component = component
        @user = user
      end

      def query
        Decidim::Meetings::Meeting.where(component: @component).visible_for(@user)
      end
    end
  end
end
