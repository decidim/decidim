# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  describe UserGroupType, type: :graphql do
    include_context "with a graphql type"

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

    describe "isVerified" do
      let(:query) { "{ isVerified }" }

      context "when the user group is verified" do
        let(:model) { create(:user_group, :verified) }

        it "returns true" do
          expect(response).to include("isVerified" => true)
        end
      end

      context "when the user group is not verified" do
        let(:model) { create(:user_group, :rejected) }

        it "returns false" do
          expect(response).to include("isVerified" => false)
        end
      end
    end
  end
end
