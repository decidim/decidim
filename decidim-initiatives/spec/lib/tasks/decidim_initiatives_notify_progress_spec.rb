# frozen_string_literal: true

require "spec_helper"

describe "decidim_initiatives:notify_progress", type: :task do
  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "runs gracefully" do
    expect { task.execute }.not_to raise_error
  end

  context "when initiative without supports" do
    let(:initiative) { create(:initiative) }

    it "Keeps initiative unchanged" do
      expect(initiative.online_votes_count).to be_zero

      task.execute
      expect(initiative.first_progress_notification_at).to be_nil
      expect(initiative.second_progress_notification_at).to be_nil
    end

    it "do not invokes the mailer" do
      expect(Decidim::Initiatives::InitiativesMailer).not_to receive(:notify_progress)
      task.execute
    end
  end

  context "when initiative ready for first notification" do
    let(:initiative) do
      initiative = create(:initiative)

      votes_needed = (initiative.supports_required * (Decidim::Initiatives.first_notification_percentage / 100.0)) + 1
      initiative.online_votes["total"] = votes_needed
      initiative.save!

      initiative
    end

    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(message_delivery).to receive(:deliver_later)
    end

    it "updates notification time" do
      expect(initiative.percentage).to be >= Decidim::Initiatives.first_notification_percentage
      expect(initiative.percentage).to be < Decidim::Initiatives.second_notification_percentage

      task.execute

      initiative.reload
      expect(initiative.first_progress_notification_at).not_to be_nil
      expect(initiative.second_progress_notification_at).to be_nil
    end

    it "invokes the mailer" do
      expect(initiative.percentage).to be >= Decidim::Initiatives.first_notification_percentage
      expect(initiative.percentage).to be < Decidim::Initiatives.second_notification_percentage

      expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_progress)
        .at_least(:once)
        .and_return(message_delivery)
      task.execute
    end
  end

  context "when initiative ready for second notification" do
    let(:initiative) do
      initiative = create(:initiative, first_progress_notification_at: Time.current)

      votes_needed = (initiative.supports_required * (Decidim::Initiatives.second_notification_percentage / 100.0)) + 1

      initiative.online_votes["total"] = votes_needed
      initiative.save!

      initiative
    end

    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(message_delivery).to receive(:deliver_later)
    end

    it "updates notification time" do
      expect(initiative.percentage).to be >= Decidim::Initiatives.second_notification_percentage

      task.execute

      initiative.reload
      expect(initiative.second_progress_notification_at).not_to be_nil
    end

    it "invokes the mailer" do
      expect(initiative.percentage).to be >= Decidim::Initiatives.second_notification_percentage
      expect(Decidim::Initiatives::InitiativesMailer).to receive(:notify_progress)
        .at_least(:once)
        .and_return(message_delivery)
      task.execute
    end
  end

  context "when initiative with both notifications sent" do
    let(:initiative) do
      create(:initiative,
             first_progress_notification_at: Time.current,
             second_progress_notification_at: Time.current)
    end

    it "do not invokes the mailer" do
      expect(Decidim::Initiatives::InitiativesMailer).not_to receive(:notify_progress)
      task.execute
    end
  end
end
