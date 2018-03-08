# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Api
    describe QueriesController, type: :controller do
      routes { Decidim::Api::Engine.routes }

      before do
        request.env["decidim.current_organization"] = create(:organization)
      end

      it "executes a query" do
        post :create, params: { query: "{ __schema { queryType { name } } }" }

        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response["__schema"]["queryType"]["name"]).to eq("Query")
      end
    end
  end
end
