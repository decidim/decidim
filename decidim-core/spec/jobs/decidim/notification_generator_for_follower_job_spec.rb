# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationGeneratorForFollowerJob do
  subject { described_class }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "decidim_events"
    end
  end

  describe "perform" do
    let(:event) { double :event }
    let(:followable) { double :followable }
    let(:follower) { double :follower }
    let(:generator) { double :generator }

    it "delegates the work to the class" do
      expect(Decidim::NotificationGeneratorForFollower)
        .to receive(:new)
        .with(event, followable, follower)
        .and_return(generator)
      expect(generator)
        .to receive(:generate)

      subject.perform_now(event, followable, follower)
    end
  end
end
