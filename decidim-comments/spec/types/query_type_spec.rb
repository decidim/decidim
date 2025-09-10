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
  end
end
