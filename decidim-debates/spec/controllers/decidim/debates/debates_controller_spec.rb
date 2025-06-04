# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe DebatesController do
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
            expect(response).to redirect_to("/users/sign_in")
          end
        end
      end
    end
  end
end
