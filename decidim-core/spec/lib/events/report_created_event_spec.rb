# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ReportCreatedEvent do
    include_context "when a simple event"

    let(:comment) { create :comment }
    let(:moderation) { create :moderation, reportable: comment }
    let(:report) { create :report, moderation: moderation }
    let(:resource) { comment }
    let(:event_name) { "decidim.events.reports.report_created" }
    let(:extra) { { report_reason: "spam" } }

    describe "notification_title" do
      it "includes the report reason" do
        expect(subject.notification_title).to include("spam")
      end

      it "includes the reportable link" do
        expect(subject.notification_title).to include(comment.reported_content_url)
      end
    end
  end
end
