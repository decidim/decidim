# frozen_string_literal: true

shared_examples_for "has hideable resource" do
  let(:organization) { create(:organization) }
  let(:author) { create(:user, organization:) }
  let(:current_user) { create(:user, :admin, :confirmed, organization:) }
  let(:justification) { "This is a spam content" }
  let(:event) { "decidim.admin.block_user:after" }

  let(:arguments) do
    {
      resource: author,
      extra: {
        justification:,
        hide: true,
        event_author: current_user
      }
    }
  end

  describe "queue" do
    it "is queued to user_report" do
      expect(subject.queue_name).to eq "user_report"
    end
  end

  describe "is fired by event" do
    it "hides the resources when the event is broadcasted" do
      expect(described_class).to receive(:perform_later).with(**arguments)
      ActiveSupport::Notifications.publish(event, arguments)
    end
  end

  describe "#perform" do
    it "hides all comments created by an author" do
      expect(hideable).not_to be_hidden
      expect(not_hideable).not_to be_hidden
      described_class.perform_now(**arguments)
      expect(not_hideable.reload).not_to be_hidden
      expect(hideable.reload).to be_hidden
    end
  end
end
