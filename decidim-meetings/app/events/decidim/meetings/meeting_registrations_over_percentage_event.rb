# frozen-string_literal: true

module Decidim
  module Meetings
    class MeetingRegistrationsOverPercentageEvent < Decidim::Events::ExtendedEvent
      i18n_attributes :percentage

      def percentage
        extra["percentage"] * 100
      end
    end
  end
end
