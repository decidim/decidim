# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Api
    describe QueriesController, type: :controller do
      let!(:participatory_process) { create(:participatory_process) }
      let!(:other_participatory_process) { create(:participatory_process) }

      before do
        @request.env["decidim.current_organization"] = participatory_process.organization
      end

      it "executes a query" do
        post :create, params: { query: "{ processes { id }}" }

        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response["processes"]).to eq(["id" => participatory_process.id.to_s])
      end
    end
  end
end
