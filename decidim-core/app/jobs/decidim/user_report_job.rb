# frozen_string_literal: true

module Decidim
  class UserReportJob < ApplicationJob
    queue_as :user_report

    def perform(admin, report)
      UserReportMailer.notify(admin, report).deliver_later
    end
  end
end
