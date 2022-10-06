# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ResourceHiddenEvent do
    include_context "when a simple event"

    let(:comment) { create :comment, body: { "en" => "a reported comment" } }
    let(:moderation) { create :moderation, reportable: comment }
    let(:report) { create :report, moderation: }
    let(:resource) { comment }
    let(:event_name) { "decidim.events.reports.resource_hidden" }
    let(:extra) { { report_reasons: ["spam"] } }

    describe "notification_title" do
      it "includes the report reason" do
        expect(subject.notification_title).to include("spam")
      end
    end

    describe "email_subject" do
      it "is generated correctly" do
        expect(subject.email_subject).to eq("Your comment has been removed")
      end
    end

    describe "email_outro" do
      it "is generated correctly" do
        expect(subject.email_outro).to eq("You have received this notification because you are an author of the removed content.")
      end
    end

    describe "email_intro" do
      it "is generated correctly" do
        expect(subject.email_intro).to include("An administrator removed your comment because it has been reported as spam.")
      end
    end

    describe "resource_text" do
      it "is generated correctly" do
        expect(subject.resource_text).to include("<i>#{comment.body["en"]}</i>")
      end
    end
  end
end
