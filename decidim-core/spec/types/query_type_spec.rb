# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim::Api
  describe QueryType do
    include_context "with a graphql class type"

    describe "session" do
      let(:query) { "{ session { user { name } } }" }

      context "when the user is logged in" do
        it "return current user data" do
          expect(response["session"]).to include("user" => { "name" => current_user.name })
        end
      end

      context "when the user is not logged in" do
        let!(:current_user) { nil }

        it "return a nil object" do
          expect(response["session"]).to be_nil
        end
      end
    end

    describe "commentable" do
      let(:model) { create(:dummy_resource, :published) }
      let(:query) { %({ commentable(type: "#{model.commentable_type}", id: "#{id}", locale: "#{locale}", toggleTranslations: false) { id } }) }
      let(:id) { model.id }
      let(:locale) { "en" }

      it "returns the commentable response" do
        expect(response["commentable"]).to eq("id" => model.id.to_s)
      end

      context "with unknown locale" do
        let(:locale) { "tlh" }

        it "returns a proper GraphQL error" do
          expect { response }.to raise_error("#{locale} is not a valid locale")
        end
      end

      context "with unknown record id" do
        let(:id) { model.id + 1000 }

        it "returns nothing" do
          expect(response["commentable"]).to be_nil
        end
      end
    end

    describe "user" do
      let!(:user) { create(:user, :confirmed, organization: current_organization) }

      context "with ID" do
        let(:query) { %({ user(id: "#{user.id}") { id, name } }) }

        it "returns the correct user" do
          expect(response["user"]).to eq("id" => user.id.to_s, "name" => user.name)
        end
      end

      context "with nickname" do
        let(:query) { %({ user(nickname: "#{user.nickname}") { id, name } }) }

        it "returns the correct user" do
          expect(response["user"]).to eq("id" => user.id.to_s, "name" => user.name)
        end
      end

      context "with no argument" do
        let(:query) { %({ user { id, name } }) }

        it "returns nothing" do
          expect(response["user"]).to be_nil
        end
      end
    end

    describe "users" do
      let!(:confirmed_users) { create_list(:user, 3, :confirmed, organization: current_organization) }
      let!(:other_org_user) { create(:user, :confirmed) }
      let!(:api_user) { create(:api_user, organization: current_organization) }
      let!(:managed_user) { create(:user, :confirmed, :managed, organization: current_organization) }
      let!(:blocked_user) { create(:user, :confirmed, :blocked, organization: current_organization) }
      let!(:deleted_user) { create(:user, :confirmed, :deleted, organization: current_organization) }
      let!(:ephemeral_user) { create(:user, :ephemeral, organization: current_organization) }

      let(:expected_users) { [current_user, managed_user] + confirmed_users }

      context "with no arguments" do
        let(:query) { "{ users { id name } }" }

        it "returns the visible users" do
          expect(response["users"]).to match_array(expected_users.map { |u| { "id" => u.id.to_s, "name" => u.name } })
        end
      end
    end
  end
end
