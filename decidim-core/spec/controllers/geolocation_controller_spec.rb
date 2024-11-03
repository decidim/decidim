# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe GeolocationController do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:current_user) { create(:user, :confirmed, organization:) }
    let!(:component) { create(:proposal_component, organization:) }
    let(:params) do
      {
        latitude:,
        longitude:
      }
    end

    let(:latitude) { 51.0 }
    let(:longitude) { 2.1 }
    let(:address) { "Puddle Lane" }
    let(:result) do
      [double(coordinates: [latitude, longitude], address:)]
    end
    let(:json) { response.parsed_body }

    before do
      allow(Geocoder).to receive(:search).and_return(result)
      request.env["decidim.current_organization"] = organization
      sign_in current_user, scope: :user
    end

    shared_examples "error" do
      it "fails" do
        post :locate, params:, xhr: true

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["message"]).to have_content("not configured")
        expect(json["found"]).to be_blank
      end
    end

    shared_examples "not found" do
      it "fails" do
        post :locate, params:, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["address"]).not_to eq(address)
        expect(json["message"]).to have_content("not authorized")
        expect(json["found"]).to be_blank
      end
    end

    shared_examples "found" do
      it "succeeds" do
        post :locate, params:, xhr: true
        expect(response).to have_http_status(:ok)
        expect(json["address"]).to eq(address)
        expect(json["found"]).to be_truthy
      end
    end

    it_behaves_like "found"

    context "when user is not logged" do
      let(:current_user) { nil }

      it_behaves_like "not found"
    end

    context "when geocoding is not configured" do
      before do
        allow(Decidim::Map).to receive("configured?").and_return(false)
      end

      it_behaves_like "error"
    end
  end
end
