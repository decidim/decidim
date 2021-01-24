# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"
require "decidim/core/test/shared_examples/input_sort_examples"

module Decidim
  module Core
    describe UserEntityInputSort, type: :graphql do
      include_context "with a graphql class type"
      let(:type_class) { Decidim::Api::QueryType }

      let(:user) { create(:user, :confirmed, organization: current_organization) }
      let(:user_group) { create(:user_group, :confirmed, organization: current_organization) }
      let!(:models) { [user, user_group] }

      context "when sorting by user id" do
        include_examples "collection has input sort", "users", "id"
      end

      context "when sorting by user name" do
        include_examples "collection has input sort", "users", "name"
      end

      context "when sorting by user nickname" do
        include_examples "collection has input sort", "users", "nickname"
      end

      context "when sorting by user type" do
        describe "ASC" do
          let(:query) { %[{ users(order: { type: "ASC" }) { id } }] }

          it "returns alphabetical order" do
            expect(response["users"].first["id"]).to eq(user.id.to_s)
            expect(response["users"].last["id"]).to eq(user_group.id.to_s)
          end
        end

        describe "DESC" do
          let(:query) { %[{ users(order: { type: "DESC" }) { id } }] }

          it "returns revered alphabetical order" do
            expect(response["users"].first["id"]).to eq(user_group.id.to_s)
            expect(response["users"].last["id"]).to eq(user.id.to_s)
          end
        end
      end
    end
  end
end
