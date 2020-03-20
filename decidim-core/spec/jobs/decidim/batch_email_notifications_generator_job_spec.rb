# frozen_string_literal: true

require "spec_helper"

describe Decidim::BatchEmailNotificationsGeneratorJob do
  subject { described_class }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "scheduled"
    end
  end

  describe "perform" do
    let(:generator) { double :generator }

    it "doesn't delegates the work to the class" do
      expect(Decidim::BatchEmailNotificationsGenerator)
        .not_to receive(:new)

      expect(generator)
        .not_to receive(:generate)

      subject.perform_now
    end

    context "when batch email notifications enabled" do
      before do
        Decidim.config.batch_email_notifications_enabled = true
      end

      it "delegates the work to the class" do
        expect(Decidim::BatchEmailNotificationsGenerator)
          .to receive(:new)
          .and_return(generator)
        expect(generator)
          .to receive(:generate)

        subject.perform_now
      end
    end
  end
end
