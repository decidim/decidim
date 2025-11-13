# frozen_string_literal: true

require "spec_helper"
require "decidim/proposals/test/factories"

describe "rake decidim_comments:upgrade:update_user_group_references", type: :task do
  let!(:comment) { create(:comment, body:) }

  describe "with a normal body" do
    let(:body) { { "en" => "This is a normal body" } }
    let(:result) { { "en" => "This is a normal body" } }

    it "does not do anything" do
      expect(comment.reload.body).to eq(body)
      task.execute
      expect(comment.reload.body).to eq(result)
    end
  end

  describe "with a User reference in the body" do
    let(:body) { { "en" => "This is a body mentioning gid://decidim-test/Decidim::User/9" } }
    let(:result) { { "en" => "This is a body mentioning gid://decidim-test/Decidim::User/9" } }

    it "does not do anything" do
      expect(comment.reload.body).to eq(body)
      task.execute
      expect(comment.reload.body).to eq(result)
    end
  end

  describe "with a UserGroup reference in the body" do
    let(:body) { { "en" => "This is a body mentioning gid://decidim-development-app/Decidim::UserGroup/5" } }
    let(:result) { { "en" => "This is a body mentioning gid://decidim-development-app/Decidim::User/5" } }

    it "changes the reference to User" do
      expect(comment.reload.body).to eq(body)
      task.execute
      expect(comment.reload.body).to eq(result)
    end
  end
end
