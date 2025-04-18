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
    let(:notification_title) { "A comment you have created was hidden because its parent resource was also hidden</br>\n#{resource_text}" }
    let(:email_subject) { "Your comment is no longer visible" }
    let(:email_outro) { "You have received this notification because you are an author of the affected comment." }
    let(:email_intro) { "A comment you have created was hidden because its parent resource was also hidden." }

    it_behaves_like "a simple event email"
    it_behaves_like "a simple event notification"

    describe "resource_text" do
      it "is generated correctly" do
        expect(subject.resource_text).to include(resource_text)
      end
    end
  end
end
