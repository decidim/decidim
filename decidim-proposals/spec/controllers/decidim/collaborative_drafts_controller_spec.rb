# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CollaborativeDraftsController, type: :controller do
      routes { Decidim::Proposals::Engine.routes }

      # let(:user) { create(:user, :confirmed, organization: component.organization) }

      let(:params) { { component_id: component.id } }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

#        sign_in user

      describe "GET index" do
        let(:component) { create(:proposal_component) }
        let!(:draft) { create(:collaborative_draft, component: component) }

        context "when invoked without paramters" do
          it "returns a list of open drafts by updated_at" do
            get :index

            expect(response).to have_http_status(:ok)
            expect(assigns[:collaborative_drafts]).to_not be_empty
            expect(subject).to render_template("decidim/proposals/collaborative_drafts/index")
          end
        end
      end
    end
  end
end
