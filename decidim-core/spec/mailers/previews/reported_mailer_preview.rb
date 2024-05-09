# frozen_string_literal: true

module Decidim
  class ReportedMailerPreview < ActionMailer::Preview
    def report = ReportedMailer.report(user, reported_resource)

    def hide = ReportedMailer.hide(user, reported_resource)

    private

    def user = User.last

    def reported_resource = Decidim::Report.last
  end
end
