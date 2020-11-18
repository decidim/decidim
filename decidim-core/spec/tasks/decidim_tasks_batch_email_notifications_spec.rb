# frozen_string_literal: true

require "spec_helper"
require "support/tasks"

describe "rake decidim:batch_email_notifications:send", type: :task do
  let(:task_name) { :"decidim:batch_email_notifications:send" }
  let(:argument_error_output) { /Rake aborted !/ }

  context "when executing task" do
    it "raises an ArgumentError" do
      Rake::Task[task_name].reenable
      expect { Rake::Task[task_name].invoke }.to output(/ArgumentError : Rake aborted !/).to_stdout
    end

    context "when batch email notifications is enabled" do
      before do
        allow(Decidim.config).to receive(:batch_email_notifications_enabled).and_return(true)
      end

      it "has to be executed without failures" do
        expect(Decidim::BatchEmailNotificationsGeneratorJob).to receive(:perform_later)
        Rake::Task[task_name].execute
      end

      it "enqueues mailers" do
        expect(Decidim::BatchEmailNotificationsGeneratorJob.queue_name).to eq "scheduled"
      end
    end
  end
end
