# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ShortLinksController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:component) { create(:component, organization: organization) }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "GET /s" do
      it "returns to the organization root path" do
        get :index

        expect(response).to redirect_to("/")
      end
    end

    describe "GET /s/:id" do
      let(:short_link) { create(:short_link, target: component) }

      let(:params) { { id: short_link.identifier } }

      it "redirects to the full URL of the short link" do
        get :show, params: params

        expect(response).to redirect_to(short_link.target_url)
      end

      context "when the link does not exist with the given identifier" do
        let(:params) { { id: "thI5Do3SNotEx1st" } }

        it "returns a 404" do
          expect { get :show, params: params }.to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
