# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CollaborativeDraftsController, type: :controller do
      routes { Decidim::Proposals::Engine.routes }

      let(:component) { create(:proposal_component) }
      let(:params) { { component_id: component.id } }
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:author) { create(:user, :confirmed, organization: component.organization) }
      let!(:draft) { create(:collaborative_draft, component: component, authors: [author]) }
      let(:user_2) { create(:user, :confirmed, organization: component.organization) }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      describe "GET index" do
        context "when invoked without paramters" do
          it "returns a list of open drafts by updated_at" do
            get :index

            expect(response).to have_http_status(:ok)
            expect(assigns[:collaborative_drafts]).not_to be_empty
            expect(subject).to render_template("decidim/proposals/collaborative_drafts/index")
          end
        end
      end

      describe "POST request_access" do
        before do
          sign_in user, scope: :user
        end

        it "creates a new access request for the given collaborative_draft" do
          expect { post :request_access, params: { id: draft.id } }.to change {
            draft.reload
            draft.access_requestors.count
          }.by(1)

          expect(response).to have_http_status(:found)
        end
      end

      describe "POST request_accept" do
        before do
          sign_in author, scope: :user
        end

        it "accepts a request from another user to the given collaborative_draft" do
          expect(draft.access_requestors.count).to eq 0
          expect(draft.coauthorships.count).to eq 2

          expect(response).to have_http_status(:ok)
        end
      end

      describe "POST request_reject" do
        before do
          sign_in user_2, scope: :user
          post :request_access, params: { id: draft.id }
          sign_in author, scope: :user
        end

        it "accepts a request from another user to the given collaborative_draft" do
          expect(draft.access_requestors.count).to eq 1

          expect(response).to have_http_status(:found)
        end
      end
    end
  end
end
