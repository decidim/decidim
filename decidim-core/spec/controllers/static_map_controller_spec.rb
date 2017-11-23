# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe StaticMapController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:feature) { create(:feature, organization: organization) }
    let(:resource) { create(:dummy_resource, feature: feature) }

    before do
      request.env["decidim.current_organization"] = organization
      request.env["decidim.current_feature"] = feature
    end

    describe "GET /static_map" do
      let(:params) do
        {
          sgid: resource.to_sgid.to_s
        }
      end
      let(:data) { "1234" }

      it "generates a static map image data using the StaticMapGenerator" do
        generator = double

        expect(StaticMapGenerator).to receive(:new).with(resource).and_return(generator)
        expect(generator).to receive(:data).and_return(data)
        expect(controller).to receive(:send_data).with(data, type: "image/jpeg", disposition: "inline")

        get :show, format: "image/jpeg", params: params
      end
    end
  end
end
