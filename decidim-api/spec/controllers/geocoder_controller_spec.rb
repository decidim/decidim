# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Api
    describe GeocoderController, type: :controller do
      routes { Decidim::Api::Engine.routes }

      let(:organization) { create :organization }
      let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }

      before do
        request.env["decidim.current_organization"] = organization

        stub_geocoding_search(address)
      end

      context "when the organization has private access" do
        let(:organization) do
          create(
            :organization,
            force_users_to_authenticate_before_access_organization: true
          )
        end

        it "doesn't accept queries" do
          get :search, params: { term: address }

          expect(response).to redirect_to("/users/sign_in")
        end
      end

      it "executes a query" do
        get :search, params: { term: address }
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.first["label"]).to eq(address)
        expect(parsed_response.first["value"]).to eq(address)
      end
    end
  end
end
