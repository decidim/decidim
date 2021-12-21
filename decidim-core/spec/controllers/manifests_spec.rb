# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ManifestsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "GET /manifest.json" do
      render_views

      it "returns the manifest" do
        get :show, format: :json

        expect(response).to be_successful

        manifest = JSON.parse(response.body)
        expect(manifest["name"]).to eq(organization.name)
      end
    end
  end
end
