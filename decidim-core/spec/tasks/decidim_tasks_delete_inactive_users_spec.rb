# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:participants:delete_inactive_participants", type: :task do
  let!(:organization1) { create(:organization) }
  let!(:organization2) { create(:organization) }

  before do
    allow(Decidim).to receive(:delete_inactive_users_after_days).and_return(300)
    allow(Decidim).to receive(:minimum_inactivity_period).and_return(30)
  end

  context "when the provided inactivity period is less than the minimum allowed" do
    it "raises an error" do
      expect do
        task.execute(days: 5)
      end.to raise_error(RuntimeError, /The number of days of inactivity period is too low/)
    end
  end

  context "when no days argument is provided" do
    it "uses the default inactivity period" do
      expect(Decidim::DeleteInactiveParticipantsJob).to receive(:perform_later).with(organization1)
      expect(Decidim::DeleteInactiveParticipantsJob).to receive(:perform_later).with(organization2)

      task.execute
    end
  end

  context "when a valid days argument is provided" do
    it "executes the job for each organization" do
      ActiveJob::Base.queue_adapter = :test

      expect do
        task.execute(days: 100)
      end
        .to have_enqueued_job(Decidim::DeleteInactiveParticipantsJob).with(organization1)
        .and have_enqueued_job(Decidim::DeleteInactiveParticipantsJob).with(organization2)
    end
  end
end
