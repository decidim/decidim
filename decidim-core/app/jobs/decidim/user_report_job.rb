# frozen_string_literal: true

module Decidim
  class UserReportJob < ApplicationJob
    queue_as :user_report

    def perform(user, token, reason, admin)
      UserReportMailer.notify(user, token, reason, admin).deliver_now
    end
  end
end
