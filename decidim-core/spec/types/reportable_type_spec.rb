# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe ReportableType do
      include_context "with a graphql class type"
      let!(:model) { create(:report, details: "Testing reason", locale: "en") }

      include_examples "timestamps interface"

      shared_examples "unauthorized User object" do
        it "throws Decidim::Api::Errors::UnauthorizedObjectError" do
          expect { response }.to raise_error(Decidim::Api::Errors::UnauthorizedObjectError, "You cannot view or edit this User because you do not have permissions")
        end
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response).to eq("id" => model.id.to_s)
        end
      end

      describe "reason" do
        let(:query) { "{ reason }" }

        it "returns the reason field" do
          expect(response["reason"]).to eq(model.reason)
        end
      end

      describe "details" do
        let(:query) { "{ details }" }

        it "returns the details field" do
          expect(response["details"]).to eq(model.details)
        end
      end

      describe "locale" do
        let(:query) { "{ locale }" }

        it "returns the locale field" do
          expect(response["locale"]).to eq(model.locale)
        end
      end

      describe "user" do
        let(:query) { "{ user { id } }" }

        it "returns the user object" do
          expect(response["user"]["id"]).to eq(model.user.id.to_s)
        end

        context "when the user is anonymous" do
          let(:moderation) { create(:moderation) }

          context "when user reporting deleted his account" do
            let!(:model) { create(:report, moderation:, user: create(:user, :confirmed, :deleted, organization: moderation.reportable.organization), details: "Testing reason", locale: "en") }

            it_behaves_like "unauthorized User object"
          end

          context "when user reporting got blocked" do
            let!(:model) { create(:report, moderation:, user: create(:user, :confirmed, :blocked, organization: moderation.reportable.organization), details: "Testing reason", locale: "en") }

            it_behaves_like "unauthorized User object"
          end
        end
      end
    end
  end
end
