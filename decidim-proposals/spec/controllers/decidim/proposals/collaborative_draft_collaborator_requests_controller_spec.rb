# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CollaborativeDraftCollaboratorRequestsController, type: :controller do
      routes { Decidim::Proposals::Engine.routes }

      let(:component) { create(:proposal_component, :with_creation_enabled, :with_collaborative_drafts_enabled) }
      let(:params) { { component_id: component.id } }
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:author) { create(:user, :confirmed, organization: component.organization) }
      let!(:collaborative_draft) { create(:collaborative_draft, component: component, users: [author]) }
      let(:user2) { create(:user, :confirmed, organization: component.organization) }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      describe "POST request_access" do
        before do
          sign_in user, scope: :user
        end

        it "creates a new access request for the given collaborative_draft" do
          expect { post :request_access, params: { id: collaborative_draft.id, state: collaborative_draft.state } }.to change {
            collaborative_draft.reload
            collaborative_draft.requesters.count
          }.by(1)

          expect(response).to have_http_status(:found)
        end
      end

      describe "POST request_accept" do
        before do
          sign_in author, scope: :user
        end

        it "accepts a request from another user to the given collaborative_draft" do
          expect(collaborative_draft.requesters.count).to eq 0
          expect(collaborative_draft.coauthorships.count).to eq 1

          expect(response).to have_http_status(:ok)
        end
      end

      describe "POST request_reject" do
        before do
          sign_in user2, scope: :user
          post :request_access, params: { id: collaborative_draft.id, state: collaborative_draft.state }
          sign_in author, scope: :user
        end

        it "accepts a request from another user to the given collaborative_draft" do
          expect(collaborative_draft.requesters.count).to eq 1

          expect(response).to have_http_status(:found)
        end
      end
    end
  end
end
