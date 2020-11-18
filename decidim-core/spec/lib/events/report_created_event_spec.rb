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

    describe "email_subject" do
      it "is generated correctly" do
        expect(subject.email_subject).to eq("Your comment has been reported")
      end
    end

    describe "email_outro" do
      it "is generated correctly" do
        expect(subject.email_outro).to eq("You have received this notification because you are an author of the reported content.")
      end
    end

    describe "email_intro" do
      it "is generated correctly" do
        expect(subject.email_intro).to eq("<a href=\"#{comment.reported_content_url}\">Your comment</a> has been reported as \"spam\". An administrator will review it shortly.")
      end
    end
  end
end
