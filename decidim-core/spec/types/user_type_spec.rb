# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe UserType, type: :graphql do
      include_context "with a graphql class type"

      include_examples "timestamps interface"

      let(:model) { create(:user, :confirmed) }

      describe "unconfirmed user" do
        let(:model) { create(:user) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      describe "deleted user" do
        let(:model) { create(:user, :deleted) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      describe "moderated user" do
        let(:model) { create(:user, :blocked) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

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
          let(:model) { create(:user, :confirmed, :officialized) }

          it "returns the icon to use for the verification badge" do
            expect(response).to include("badge" => "verified-badge")
          end
        end

        context "when the user is not officialized" do
          let(:model) { create(:user, :confirmed) }

          it "returns empty" do
            expect(response).to include("badge" => "")
          end
        end
      end

      describe "avatarUrl" do
        let(:query) { "{ avatarUrl }" }

        it "returns the user avatar url (small version)" do
          expect(response).to include("avatarUrl" => model.attached_uploader(:avatar).variant_url(:thumb))
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
            expect(response).to be_nil
          end
        end
      end

      describe "directMessagesEnabled" do
        let(:query) { "{ ...on User { directMessagesEnabled } }" }

        it "returns the direct messages status" do
          expect(response).to include("directMessagesEnabled" => "true")
        end

        context "when user direct messages disabled" do
          let(:model) { create(:user, :confirmed, direct_message_types: "followed-only") }

          it "returns the direct_messages status" do
            expect(response).to include("directMessagesEnabled" => "false")
          end
        end
      end

      describe "organizationName" do
        let(:query) { '{ organizationName { translation(locale: "en") } } ' }

        it "returns the user's organization name" do
          expect(response["organizationName"]["translation"]).to eq(translated(model.organization.name))
        end
      end

      describe "followersCount" do
        let(:query) { "{ followersCount }" }

        it "returns the user's followers count" do
          expect(response).to include("followersCount" => model.followers.count)
        end
      end

      describe "followingCount" do
        let(:query) { "{ followingCount }" }

        it "returns the user's following count" do
          expect(response).to include("followingCount" => model.following_count)
        end
      end

      describe "followsCount" do
        let(:query) { "{ followsCount }" }

        it "returns the user's follows count" do
          expect(response).to include("followsCount" => model.follows.count)
        end
      end

      describe "officialized" do
        let(:query) { "{ officialized }" }

        it "returns the user's officialized status" do
          expect(response).to include("officialized" => model.officialized?)
        end
      end

      describe "about" do
        let(:query) { "{ about }" }

        it "returns the user's about" do
          expect(response).to include("about" => model.about)
        end
      end

      describe "personalUrl" do
        let(:query) { "{ personalUrl }" }

        it "returns the user's personal url" do
          expect(response).to include("personalUrl" => model.personal_url)
        end
      end
    end
  end
end
