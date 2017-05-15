# frozen_string_literal: true
require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  describe UserGroupType, type: :graphql do
    include_context "graphql type"

    let(:model) { create(:user_group) }

    describe "id" do
      let(:query) { "{ id }" }

      it "returns all the required fields" do
        expect(response).to include("id" => model.id.to_s)
      end
    end

    describe "name" do
      let(:query) { "{ name }" }

      it "returns all the required fields" do
        expect(response).to include("name" => model.name)
      end
    end

    describe "avatarUrl" do
      let(:query) { "{ avatarUrl }" }

      it "returns the user avatar url" do
        expect(response).to include("avatarUrl" => model.avatar.url)
      end
    end
  end
end
