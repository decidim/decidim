# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::HideAllCreatedByAuthorJob do
  subject { described_class }

  let(:organization) { create(:organization) }
  let(:author) { create(:user, organization:) }
  let(:current_user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:component, participatory_space: participatory_process) }
  let(:resource) { create(:dummy_resource, component:) }
  let!(:comment) { create(:comment, commentable: resource, author:) }
  let!(:comment2) { create(:comment, commentable: resource) }
  let(:justification) { "This is a spam comment" }
  let(:event_name) { "decidim.system.events.hide_user_created_content" }
  let(:arguments) { { author:, justification:, current_user: } }

  describe "queue" do
    it "is queued to user_report" do
      expect(subject.queue_name).to eq "user_report"
    end
  end

  describe "#perform" do
    it "hides all comments created by an author" do
      expect(comment).not_to be_hidden
      expect(comment2).not_to be_hidden
      described_class.perform_now(author:, justification:, current_user:)
      expect(comment2).not_to be_hidden
      expect(comment.reload).to be_hidden
    end
  end

  describe "is fired by event" do
    it "hides the resources when the event is broadcasted" do
      expect(described_class).to receive(:perform_later).with(**arguments)
      ActiveSupport::Notifications.publish(event_name, arguments)
    end
  end
end
