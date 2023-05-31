# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe StaticMapController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:component) { create(:component, organization:) }
    let(:resource) { create(:dummy_resource, component:) }

    before do
      request.env["decidim.current_organization"] = organization
      request.env["decidim.current_component"] = component
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

        allow(StaticMapGenerator).to receive(:new).with(resource).and_return(generator)
        allow(generator).to receive(:data).and_return(data)
        allow(controller).to receive(:send_data).with(data, type: "image/jpeg", disposition: "inline")
        expect(controller).not_to receive(:store_current_location)

        get :show, format: "image/jpeg", params:
      end
    end
  end
end
