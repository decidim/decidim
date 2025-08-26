# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe ReportableUserType do
      include_context "with a graphql class type"
      let!(:model) { create(:user_report, details: "Testing reason") }

      include_examples "timestamps interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the moderation's id" do
          expect(response).to eq("id" => model.id.to_s)
        end
      end

      describe "reason" do
        let(:query) { "{ reason }" }

        it "returns the moderation's reason" do
          expect(response["reason"]).to eq(model.reason)
        end
      end

      describe "details" do
        let(:query) { "{ details }" }

        it "returns the moderation's details" do
          expect(response["details"]).to eq(model.details)
        end
      end

      describe "user" do
        let(:query) { "{ user { id } }" }

        it "returns the moderation's user" do
          expect(response["user"]["id"]).to eq(model.user.id.to_s)
        end

        context "when the user is anonymous" do
          let(:moderation) { create(:user_moderation, user: create(:user)) }

          let!(:model) { create(:user_report, moderation:, user: moderation.user, details: "Testing reason") }

          it "returns nil" do
            expect(response["user"]).to be_nil
          end
        end
      end
    end
  end
end
