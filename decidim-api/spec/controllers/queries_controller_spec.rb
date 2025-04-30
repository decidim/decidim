# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Api
    describe QueriesController do
      routes { Decidim::Api::Engine.routes }

      let(:organization) { create(:organization) }

      before do
        request.env["decidim.current_organization"] = organization
      end

      context "when the organization has private access" do
        let(:organization) do
          create(
            :organization,
            force_users_to_authenticate_before_access_organization: true
          )
        end

        it "does not accept queries" do
          post :create, params: { query: "{ __schema { queryType { name } } }" }

          expect(response).to redirect_to("/users/sign_in")
        end
      end

      it "executes a query" do
        post :create, params: { query: "{ __schema { queryType { name } } }" }

        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response["__schema"]["queryType"]["name"]).to eq("Query")
      end

      context "with force sign in enabled" do
        before do
          allow(Decidim::Api).to receive(:force_api_authentication).and_return(true)
        end

        context "when user is not signed in" do
          it "redirects to login page for HTML requests" do
            post :create, params: {}
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to("/users/sign_in")
          end

          it "returns 401 Unauthorized for JSON requests" do
            post :create, params: {}, format: :json
            expect(response).to have_http_status(:unauthorized)
          end
        end

        context "when user is signed in" do
          let(:current_user) { create(:user, :confirmed, :admin, organization:) }

          before do
            sign_in current_user
          end

          it "allows access for HTML requests" do
            post :create, params: {}
            expect(response).to have_http_status(:success)
          end

          it "allows access for JSON requests" do
            post :create, params: { query: "{ __schema { queryType { name } } }" }, format: :json
            expect(response).to have_http_status(:success)
          end
        end
      end
    end
  end
end
