# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe UserType, type: :graphql do
      include_context "with a graphql type"

      let(:model) { create(:user) }

      describe "name" do
        let(:query) { "{ name }" }

        it "returns the user's name" do
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

        context "when the user is officialized" do
          let(:model) { create(:user, :officialized) }

          it "returns the icon to use for the verification badge" do
            expect(response).to include("badge" => "verified-badge")
          end
        end

        context "when the user is not officialized" do
          let(:model) { create(:user) }

          it "returns empty" do
            expect(response).to include("badge" => "")
          end
        end
      end

      describe "avatarUrl" do
        let(:query) { "{ avatarUrl }" }

        it "returns the user avatar url (small version)" do
          expect(response).to include("avatarUrl" => model.avatar.url(:thumb))
        end
      end

      describe "profilePath" do
        let(:query) { "{ profilePath }" }

        it "returns the user profile path" do
          expect(response).to include("profilePath" => "/profiles/#{model.nickname}")
        end

        context "when user is deleted" do
          let(:model) { create(:user, :deleted) }

          it "returns empty" do
            expect(response).to include("profilePath" => "")
          end
        end
      end

      describe "directMessagesEnabled" do
        let(:query) { "{ ...on User { directMessagesEnabled } }" }

        it "returns the direct messages status" do
          expect(response).to include("directMessagesEnabled" => "true")
        end

        context "when user direct messages disabled" do
          let(:model) { create(:user, direct_message_types: "followed-only") }

          it "returns the direct_messages status" do
            expect(response).to include("directMessagesEnabled" => "false")
          end
        end
      end

      describe "organizationName" do
        let(:query) { "{ organizationName }" }

        it "returns the user's organization name" do
          expect(response).to include("organizationName" => model.organization.name)
        end
      end

      describe "groups" do
        let(:query) { "{ ...on User { groups { id nickname } } }" }
        let(:model) { membership.user }
        let(:user_group) { membership.user_group }

        context "when user accepted in the group" do
          let(:membership) { create :user_group_membership, role: "member" }

          it "returns the user's groups" do
            groups = response["groups"]
            expect(groups).to include("id" => user_group.id.to_s, "nickname" => "@#{user_group.nickname}")
          end
        end

        context "when user is not accepted yet in the group" do
          let(:membership) { create :user_group_membership, role: "requested" }

          it "returns no groups" do
            groups = response["groups"]
            expect(groups).to eq([])
          end
        end
      end
    end
  end
end
