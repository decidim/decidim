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

    describe "isVerified" do
      let(:query) { "{ isVerified }" }

      it "returns false" do
        expect(response).to include("isVerified" => false)
      end
    end

    describe "avatarUrl" do
      let(:query) { "{ avatarUrl }" }

      it "returns the user avatar url" do
        expect(response).to include("avatarUrl" => model.avatar.url)
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
