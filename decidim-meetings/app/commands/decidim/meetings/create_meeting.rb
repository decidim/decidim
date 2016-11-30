# frozen_string_literal: true
module Decidim
  module Meetings
    # Command that gets called whenever a component's meeting has to be created. It
    # usually happens as a callback when the component itself is created.
    class CreateMeeting < Rectify::Command
      def initialize(component)
        @component = component
      end

      def call
        @meeting = Meeting.new(
          title: @component.name,
          component: @component
        )

        @meeting.save ? broadcast(:ok) : broadcast(:error)
      end
    end
  end
end
