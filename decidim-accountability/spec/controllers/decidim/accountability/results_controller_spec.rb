# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    describe ResultsController do
      let(:organization) { create(:organization) }
      let(:participatory_space) { create(:participatory_process, organization:) }
      let(:component) { create(:accountability_component, participatory_space:) }
      let(:result) { create(:result, component:) }

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_participatory_space"] = participatory_space
        request.env["decidim.current_component"] = component
      end

      describe "GET show" do
        it "renders the result" do
          get :show, params: { id: result.id }
          expect(response).to have_http_status(:ok)
        end

        it "returns a 404 status when the result is not found" do
          expect { get :show, params: { id: "non-existent" } }.to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
