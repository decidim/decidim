# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe DebatesController do
      include Decidim::Core::Engine.routes.url_helpers

      let(:user) { create(:user, :confirmed, organization: component.organization) }

      let(:debate_params) do
        {
          component_id: component.id
        }
      end
      let(:params) { { debate: debate_params } }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        stub_const("Decidim::Paginable::OPTIONS", [100])
      end

      describe "GET new" do
        let(:component) { create(:debates_component, :with_creation_enabled) }

        context "when user is not logged in" do
          it "redirects to the login page" do
            get(:new)
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(new_user_session_path)
          end
        end
      end

      describe "GET show" do
        let(:component) { create(:debates_component) }
        let!(:debate) { create(:debate, component:) }

        it "renders the debate" do
          get :show, params: { id: debate.id }
          expect(response).to have_http_status(:ok)
        end

        it "returns a 404 status when the debate does not exist" do
          expect { get :show, params: { id: "non-existent" } }.to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
