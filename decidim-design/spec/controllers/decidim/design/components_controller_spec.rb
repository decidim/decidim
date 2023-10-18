# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Design
    describe ComponentsController, type: :controller do
      routes { Decidim::Design::Engine.routes }
      describe "show" do
        let(:organization) { create(:organization) }

        before do
          request.env["decidim.current_organization"] = organization
        end

        it "shows existing templates by its name" do
          get :show, params: { id: "forms" }
          expect(response).to have_http_status(:ok)
        end

        context "when template is not present" do
          it "throws a routing error exception" do
            expect { get :show, params: { id: "not_exisint_template" } }.to raise_error(ActionController::RoutingError)
          end
        end
      end
    end
  end
end
