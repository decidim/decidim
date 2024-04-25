# frozen_string_literal: true

module Decidim
  class ReportedMailerPreview < ActionMailer::Preview
    def report
      ReportedMailer.report(user, reported_resource)
    end

    def hide
      ReportedMailer.hide(user, reported_resource)
    end

    private

    def user
      User.last
    end

    def reported_resource
      Decidim::Report.last
    end
  end
end
