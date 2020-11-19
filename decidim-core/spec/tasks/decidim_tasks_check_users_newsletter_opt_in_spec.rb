# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:check_users_newsletter_opt_in", type: :task do
  let!(:user_wo) { create(:user, :confirmed, newsletter_notifications_at: nil) }
  let!(:user_w_optin) { create(:user, :confirmed, newsletter_notifications_at: Time.zone.parse("2018-05-26 00:00 +02:00")) }
  let!(:users) { create_list(:user, 4, :confirmed, newsletter_notifications_at: Time.zone.parse("2018-05-24 00:00 +02:00")) }

  context "when executing task" do
    it "have to be executed without failures" do
      allow($stdin).to receive(:gets).and_return("N")
      expect { task.execute }.not_to raise_error
    end

    it "have to show a confirmation message" do
      allow($stdin).to receive(:gets).and_return("N")
      task.execute
      expect($stdout.string).to include("https://github.com/decidim/decidim/releases/tag/v0.12")
    end

    it "have to cancels execution in a negative answer" do
      allow($stdin).to receive(:gets).and_return("N")
      task.execute
      expect($stdout.string).to include("Execution cancelled")
    end

    it "have to create a job for each user" do
      ActiveJob::Base.queue_adapter = :test
      allow($stdin).to receive(:gets).and_return("Y")
      expect { task.execute }.to have_enqueued_job.exactly(4)
    end

    it "updates users Opt-in fields" do
      allow($stdin).to receive(:gets).and_return("Y")
      task.execute
      users = Decidim::User.where.not(newsletter_token: "")
      expect(users.size).to eq(4)
      expect(users.collect(&:newsletter_notifications_at?).any?).to be false
      expect(users.collect(&:newsletter_token?).all?).to be true
    end
  end
end
