# frozen_string_literal: true
require "spec_helper"
require "decidim/api/test/type_context"

describe Decidim::Api::QueryType do
  include_context "graphql type"

  describe "currentUser" do
    let(:query) { "{ currentUser { name } } " }

    context "When the user is logged in" do
      it "return current user data" do
        expect(response["currentUser"]).to include("name" => current_user.name)
      end
    end

    context "When the user is not logged in" do
      let!(:current_user) { nil }

      it "return a nil object" do
        expect(response["currentUser"]).to be_nil
      end
    end
  end

  describe "comments" do
    let!(:participatory_process_1) { create(:participatory_process, organization: current_organization) }
    let!(:comment_1) { create(:comment, commentable: participatory_process_1) }
    let!(:comment_2) { create(:comment, commentable: participatory_process_1) }
    let!(:participatory_process_2) { create(:participatory_process, organization: current_organization) }
    let!(:comment_3) { create(:comment, commentable: participatory_process_2) }

    let(:query) { "{ comments(commentableId: \"#{participatory_process_1.id}\", commentableType: \"Decidim::ParticipatoryProcess\") { id } }" }

    it "returns comments from a commentable resource" do
      expect(response["comments"]).to     include("id" => comment_1.id.to_s)
      expect(response["comments"]).to     include("id" => comment_2.id.to_s)
      expect(response["comments"]).to_not include("id" => comment_3.id.to_s)
    end

    it "returns comments ordered by creation date" do
      comment_2.update_attribute(:created_at, 2.days.ago)
      comment_1.update_attribute(:created_at, 1.days.ago)

      expect(response["comments"][0]["id"]).to eq comment_2.id.to_s
      expect(response["comments"][1]["id"]).to eq comment_1.id.to_s
    end
  end
end
