# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:clean:clean_deleted_users", type: :task do
  context "when executing task" do
    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, organization:, about: "This is my description", personal_url: "http://example.com") }
    let!(:deleted_user) { create(:user, :deleted, organization:, about: "This is my description", personal_url: "http://example.com") }

    it "updates the correct user" do
      task.execute

      expect(user.reload.about).to eq("This is my description")
      expect(user.reload.personal_url).to eq("http://example.com")
      expect(deleted_user.reload.about).to eq("")
      expect(deleted_user.reload.personal_url).to eq("")
      expect(deleted_user.reload.notifications_sending_frequency).to eq("none")
    end

    it "avoid removing entries" do
      expect { task.execute }.not_to change(Decidim::User, :count)
    end
  end
end
