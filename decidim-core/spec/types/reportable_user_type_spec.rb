# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe ReportableUserType do
      include_context "with a graphql class type"
      let!(:model) { create(:user_report, details: "Testing reason") }

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

      describe "user" do
        let(:query) { "{ user { id } }" }

        it "returns the user object" do
          expect(response["user"]["id"]).to eq(model.user.id.to_s)
        end

        context "when the user has an incidence (i.e. is deleted or blocked)" do
          let(:moderation) { create(:user_moderation, user: create(:user)) }

          let!(:model) { create(:user_report, moderation:, user: moderation.user, details: "Testing reason") }

          it_behaves_like "unauthorized User object"

          context "when the user that made the report deleted their account" do
            let(:moderation) { create(:user_moderation, user: create(:user, :confirmed, :deleted)) }

            it_behaves_like "unauthorized User object"
          end

          context "when the user that made the reporting got blocked" do
            let(:moderation) { create(:user_moderation, user: create(:user, :confirmed, :blocked)) }

            it_behaves_like "unauthorized User object"
          end
        end
      end
    end
  end
end
