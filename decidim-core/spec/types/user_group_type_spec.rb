# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
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

      describe "nickname" do
        let(:query) { "{ nickname }" }

        it "returns a presentable user group's nickname" do
          expect(response).to include("nickname" => "@#{model.nickname}")
        end
      end

      describe "avatarUrl" do
        let(:query) { "{ avatarUrl }" }

        it "returns the user avatar url" do
          expect(response).to include("avatarUrl" => model.avatar.url)
        end
      end

      describe "profilePath" do
        let(:query) { "{ profilePath }" }

        it "returns the user group profile path" do
          expect(response).to include("profilePath" => "/profiles/#{model.nickname}")
        end
      end

      describe "badge" do
        let(:query) { "{ badge }" }

        context "when the user group is verified" do
          let(:model) { create(:user_group, :verified) }

          it "returns the icon to use for the verification badge" do
            expect(response).to include("badge" => "verified-badge")
          end
        end

        context "when the user group is not verified" do
          let(:model) { create(:user_group, :rejected) }

          it "returns empty" do
            expect(response).to include("badge" => "")
          end
        end
      end
    end
  end
end
