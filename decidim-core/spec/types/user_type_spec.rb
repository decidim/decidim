# frozen_string_literal: true
require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  describe UserType, type: :graphql do
    include_context "graphql type"

    let(:model) { create(:user) }

    describe "name" do
      let(:query) { "{ name }" }

      it "returns all the required fields" do
        expect(response).to include("name" => model.name)
      end
    end

    describe "avatarUrl" do
      let (:query) { "{ avatarUrl }" }

      it "returns the user avatar url" do
        expect(response).to include("avatarUrl" => model.avatar.url)
      end
    end

    describe "verifiedUserGroups" do
      let (:query) { "{ verifiedUserGroups { id } }" }
      let (:user_group) { create(:user_group, :verified) }
      let! (:membership) { create(:user_group_membership, user: model, user_group: user_group)}

      it "returns the user verified user groups" do
        expect(response).to include("verifiedUserGroups" => [{"id" => user_group.id.to_s}] )
      end
    end
  end
end