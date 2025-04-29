# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParentHiddenEvent do
    include_context "when a simple event"

    let(:comment) { create(:comment, body: generate_localized_description(:comment_body)) }
    let(:moderation) { create(:moderation, reportable: comment) }
    let(:report) { create(:report, moderation:) }
    let(:resource) { comment }
    let(:resource_text) { "<i>#{decidim_sanitize(translated(resource.body), strip_tags: true)}</i>" }
    let(:event_name) { "decidim.events.reports.parent_hidden" }
    let(:extra) { { report_reasons: ["spam"] } }
    let(:email_subject) { "Your comment is no longer visible" }
    let(:email_outro) { "You have received this notification because you are an author of the affected comment." }
    let(:email_intro) { "#{email_subject}.<br>\nThis happened because the proposal, meeting, debate or comment you replied to has been moderated. If it becomes available again, your comment will be automatically restored." }

    it_behaves_like "a simple event email"

    describe "resource_text" do
      it "is generated correctly" do
        expect(subject.resource_text).to include(resource_text)
      end
    end
  end
end
