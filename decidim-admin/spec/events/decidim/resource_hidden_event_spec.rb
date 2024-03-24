# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ResourceHiddenEvent do
    include_context "when a simple event"

    let(:comment) { create(:comment, body: generate_localized_description(:comment_body)) }
    let(:moderation) { create(:moderation, reportable: comment) }
    let(:report) { create(:report, moderation:) }
    let(:resource) { comment }
    let(:resource_text) { "<i>#{decidim_sanitize(translated(resource.body), strip_tags: true)}</i>" }
    let(:event_name) { "decidim.events.reports.resource_hidden" }
    let(:extra) { { report_reasons: ["spam"] } }
    let(:notification_title) { "An administrator removed your comment because it has been reported as spam.</br>\n#{resource_text}" }
    let(:email_subject) { "Your comment has been removed" }
    let(:email_outro) { "You have received this notification because you are an author of the removed content." }
    let(:email_intro) { "An administrator removed your comment because it has been reported as spam." }

    it_behaves_like "a simple event email"
    it_behaves_like "a simple event notification"

    describe "resource_text" do
      it "is generated correctly" do
        expect(subject.resource_text).to include(resource_text)
      end
    end
  end
end
