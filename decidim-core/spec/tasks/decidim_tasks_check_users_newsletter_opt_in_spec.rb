# frozen_string_literal: true

require "spec_helper"
require "support/tasks"

# rubocop:disable RSpec/DescribeClass
describe "rake decidim:check_users_newsletter_opt_in", type: :task do
  # rubocop:enable RSpec/DescribeClass
  let!(:user_wo) { create(:user, :confirmed, newsletter_notifications: false) }
  let!(:user_w_optin) { create(:user, :confirmed, newsletter_notifications: true, newsletter_opt_in_at: DateTime.current) }
  let!(:users) { create_list(:user, 4, :confirmed, newsletter_notifications: true) }

  context "when executing task" do
    it "have to be executed without failures" do
      expect { task.execute }.not_to raise_error
    end

    it "have to create a job for each user" do
      ActiveJob::Base.queue_adapter = :test
      expect { task.execute }.to have_enqueued_job.exactly(4)
    end

    it "updates users Opt-in fields" do
      task.execute
      users = Decidim::User.where.not(newsletter_token: "")
      expect(users.size).to eq(4)
      expect(users.collect(&:newsletter_notifications).any?).to be false
      expect(users.collect(&:newsletter_token?).all?).to be true
    end
  end
end
