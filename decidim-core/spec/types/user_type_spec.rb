# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  describe UserType, type: :graphql do
    include_context "with a graphql type"

    let(:model) { create(:user) }

    describe "name" do
      let(:query) { "{ name }" }

      it "returns all the required fields" do
        expect(response).to include("name" => model.name)
      end
    end

    describe "nickname" do
      let(:query) { "{ nickname }" }

      it "returns a presentable user's nickname" do
        expect(response).to include("nickname" => "@#{model.nickname}")
      end
    end

    describe "badge" do
      let(:query) { "{ badge }" }

      it "returns empty" do
        expect(response).to include("badge" => "")
      end
    end

    describe "avatarUrl" do
      let(:query) { "{ avatarUrl }" }

      it "returns the user avatar url (small version)" do
        expect(response).to include("avatarUrl" => model.avatar.url(:thumb))
      end
    end

    describe "organizationName" do
      let(:query) { "{ organizationName }" }

      it "returns the user's organization name" do
        expect(response).to include("organizationName" => model.organization.name)
      end
    end
  end
end
