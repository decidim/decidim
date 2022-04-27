# frozen_string_literal: true

module Decidim
  # Helper that provides methods to render the notifications settings form
  module NotificationsSettingsHelper
    def frequencies_collection
      {
        none: t(".notifications_sending_frequencies.none"),
        real_time: t(".notifications_sending_frequencies.real_time"),
        daily: t(".notifications_sending_frequencies.daily"),
        weekly: t(".notifications_sending_frequencies.weekly")
      }
    end
  end
end
