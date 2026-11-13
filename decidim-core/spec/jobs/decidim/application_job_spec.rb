# frozen_string_literal: true

require "spec_helper"

describe Decidim::ApplicationJob do
  subject { described_class }

  describe "enqueue_after_transaction_commit" do
    it "is enabled" do
      expect(subject.enqueue_after_transaction_commit).to be true
    end

    context "when the job is enqueued inside a transaction" do
      include_context "with concurrency"

      it "does not enqueue the job before the transaction is committed" do
        ActiveRecord::Base.transaction do
          subject.perform_later

          expect(ActiveJob::Base.queue_adapter.enqueued_jobs).to be_empty
        end

        expect(ActiveJob::Base.queue_adapter.enqueued_jobs.size).to eq 1
      end

      it "enqueues the job after the transaction is committed" do
        expect do
          ActiveRecord::Base.transaction do
            subject.perform_later
          end
        end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :count).by(1)
      end

      it "does not enqueue the job when the transaction is rolled back" do
        expect do
          ActiveRecord::Base.transaction do
            subject.perform_later
            raise "Rollback"
          end
        end.to raise_error(RuntimeError, "Rollback")

        expect(ActiveJob::Base.queue_adapter.enqueued_jobs).to be_empty
      end
    end
  end
end
