# frozen_string_literal: true

module Decidim
  module Meetings
    include ActiveSupport::Configurable

    # Public Setting that defines whether proposals can be linked to meetings
    config_accessor :enable_proposal_linking do
      Decidim.const_defined?("Proposals")
    end

    # Settings to define close meeting notifications for users

    # Period of time (nb of days) after which to send the initial notification
    config_accessor :close_meeting_notification do
      3
    end

    # Period of time (nb of days) after which to send the reminder notification
    config_accessor :close_meeting_reminder_notification do
      7
    end
  end
end
