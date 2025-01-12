# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:clean:fix_blocked_user_notification", type: :task do
  context "when executing task" do
    it "does not throw exceptions keys" do
      expect do
        Rake::Task[:"decidim:upgrade:clean:fix_blocked_user_notification"].invoke
      end.not_to raise_exception
    end
  end

  context "when there are blocked users" do
    let!(:organization) { create(:organization) }
    let!(:users) { create_list(:user, 4, :blocked, organization:) }

    it "update all blocked users" do
      expect(Decidim::User.blocked.where.not(notifications_sending_frequency: :none).count).to eq(4)
      expect { task.execute }.not_to raise_error
      expect(Decidim::User.blocked.where.not(notifications_sending_frequency: :none).count).to eq(0)
    end
  end
end
