# frozen_string_literal: true

module Decidim
  class UserReportJob < ApplicationJob
    queue_as :user_report

    def perform(admin, token, reason, user)
      UserReportMailer.notify(admin, token, reason, user).deliver_now
    end
  end
end
