# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CollaborativeDraftsController, type: :controller do
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

      describe "GET index" do
        context "when invoked without paramters" do
          it "returns a list of open collaborative drafts by updated_at" do
            get :index

            expect(response).to have_http_status(:ok)
            expect(assigns[:collaborative_drafts]).not_to be_empty
            expect(subject).to render_template("decidim/proposals/collaborative_drafts/index")
          end
        end
      end

      describe "GET show" do
        it "returns details of a collaborative_draft" do
          get :show, params: { id: collaborative_draft.id }

          expect(response).to have_http_status(:ok)
          expect(assigns(:collaborative_draft)).to be_kind_of(Decidim::Proposals::CollaborativeDraft)
          expect(subject).to render_template("decidim/proposals/collaborative_drafts/show")
        end
      end

      context "when creating a collaborative draft (wizard)" do
        before do
          sign_in user, scope: :user
        end

        let(:component) { create(:proposal_component, :with_creation_enabled, :with_collaborative_drafts_enabled) }

        describe "GET new" do
          it "renders the empty form" do
            get :new, params: params
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:new)
          end
        end
      end

      describe "POST create" do
        let(:params) do
          {
            component_id: component.id,
            collaborative_draft: {
              title: collaborative_draft.title,
              body: collaborative_draft.body
            }
          }
        end

        context "when creation is not enabled" do
          let(:component) { create(:proposal_component, :with_collaborative_drafts_enabled) }

          it "redirects" do
            post :create, params: params
            expect(response).to have_http_status(:found)
          end
        end

        context "when creation is enabled" do
          it "creates a collaborative draft" do
            post :create, params: params
            expect(response).to have_http_status(:found)
          end
        end
      end

      describe "GET edit" do
        before do
          sign_in author, scope: :user
        end

        it "renders the edit form" do
          get :edit, params: { id: collaborative_draft.id }
          expect(response).to have_http_status(:ok)
          expect(assigns(:collaborative_draft)).to be_kind_of(Decidim::Proposals::CollaborativeDraft)
          expect(subject).to render_template(:edit)
        end
      end

      describe "POST update" do
        let(:params) do
          {
            component_id: component.id,
            id: collaborative_draft.id,
            collaborative_draft: {
              title: Decidim::Faker::Localized.sentence,
              body: Decidim::Faker::Localized.sentence(word_count: 2)
            }
          }
        end

        it "updates the collaborative draft" do
          put :update, params: params
          expect(assigns(:collaborative_draft)).to be_kind_of(Decidim::Proposals::CollaborativeDraft)
          expect(response).to have_http_status(:found)
        end
      end

      context "with collaborative drafts disabled" do
        let(:component) { create(:proposal_component) }

        describe "GET index" do
          it "renders not found page" do
            expect { get :index }.to raise_error(ActionController::RoutingError)
          end
        end
      end
    end
  end
end
