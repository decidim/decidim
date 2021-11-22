# frozen_string_literal: true

module Decidim
  module Meetings
    include ActiveSupport::Configurable

    # Public Setting that defines whether proposals can be linked to meetings
    config_accessor :enable_proposal_linking do
      Decidim.const_defined?("Proposals")
    end

    # Admin settings to define close meeting notifications for users

    # Period of time (nb of days) after which to send the initial notification
    config_accessor :close_report_notifications do
      1
    end

    # Period of time (nb of days) after which to send the reminder notification
    config_accessor :close_report_reminder_notifications do
      7
    end

    # Enable initial notifications
    config_accessor :enable_cr_initial_notifications do
      true
    end

    # Enable reminder notifications
    config_accessor :enable_cr_reminder_notifications do
      true
    end
  end
end
