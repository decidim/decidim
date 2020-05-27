# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Api
    describe QueriesController, type: :controller do
      routes { Decidim::Api::Engine.routes }

      let(:organization) { create :organization }

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

        it "doesn't accept queries" do
          post :create, params: { query: "{ __schema { queryType { name } } }" }

          expect(response).to redirect_to("/users/sign_in")
        end
      end

      it "executes a query" do
        post :create, params: { query: "{ __schema { queryType { name } } }" }

        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response["__schema"]["queryType"]["name"]).to eq("Query")
      end
    end
  end
end
