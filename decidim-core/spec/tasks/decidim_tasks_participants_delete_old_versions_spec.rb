# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:participants:delete_old_versions", type: :task do
  let!(:organization1) { create(:organization) }
  let!(:organization2) { create(:organization) }

  before do
    allow(Decidim).to receive(:delete_old_personal_data_versions_days).and_return(300)
  end

  context "when no days argument is provided" do
    it "uses the default inactivity period" do
      expect(Decidim::DeleteOldUserVersionsJob).to receive(:perform_later).with(300)
      expect(Decidim::DeleteRevokedAuthorizationsVersionsJob).to receive(:perform_later).with(300)

      task.execute
    end
  end

  context "when invalid days argument is provided" do
    let(:args) { Rake::TaskArguments.new([:days], [cutoff_days]) }

    context "with a negative value" do
      let(:cutoff_days) { -1 }

      it "raises InvalidArgument" do
        expect { task.execute(args) }.to raise_error(RuntimeError, "The cutoff days must be a positive integer or zero.")
      end
    end
  end

  context "when a valid days argument is provided" do
    it "executes the job for each organization" do
      ActiveJob::Base.queue_adapter = :test

      expect do
        task.invoke(100)
      end
        .to have_enqueued_job(Decidim::DeleteOldUserVersionsJob).with(100)
        .and have_enqueued_job(Decidim::DeleteRevokedAuthorizationsVersionsJob).with(100)
    end
  end
end
