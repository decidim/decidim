# frozen_string_literal: true

module Decidim
  class UserReportJob < ApplicationJob
    queue_as :user_report

    def perform(admin, reporting_user, report)
      UserReportMailer.notify(admin, reporting_user, report).deliver_now
    end
  end
end
