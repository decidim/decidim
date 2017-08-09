# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationGenerator do
  let(:event) { "decidim.events.dummy.dummy_resource_updated" }
  let(:followable) { create(:dummy_resource) }
  let(:follow) { create(:follow, followable: followable, user: follower) }
  let(:follower) { followable.author }
  subject { described_class.new(event, followable) }

  describe "generate" do
    it "schedules a job for each follower" do
      expect(Decidim::NotificationGeneratorForFollowerJob)
        .to receive(:perform_later)
        .with(event, followable, follower)

      subject.generate
    end
  end
end
