# frozen_string_literal: true
module Decidim
  module Meetings
    # Command that gets called when the meeting of this component needs to be
    # destroyed. It usually happens as a callback when the component is removed.
    class DestroyMeeting < Rectify::Command
      def initialize(component)
        @component = component
      end

      def call
        Meeting.where(component: @component).destroy_all
        broadcast(:ok)
      end
    end
  end
end
