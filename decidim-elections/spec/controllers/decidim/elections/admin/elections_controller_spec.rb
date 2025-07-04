# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/softdeleteable_components_examples"

module Decidim
  module Elections
    module Admin
      describe ElectionsController do
        let(:component) { create(:elections_component) }
        let(:organization) { component.organization }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let!(:election) { create(:election, component:) }
        let(:elections_path) { Decidim::EngineRouter.admin_proxy(component).elections_path }

        let(:election_params) do
          {
            title: { en: "Election title" },
            description: { en: "Election description" },
            manual_start: true,
            start_at: nil,
            end_at: 2.days.from_now,
            results_availability: "real_time"
          }
        end

        def edit_questions_path(election)
          Decidim::EngineRouter.admin_proxy(component).edit_questions_election_path(election)
        end

        def dashboard_path(election)
          Decidim::EngineRouter.admin_proxy(component).dashboard_election_path(election)
        end

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
          allow(controller).to receive(:edit_questions_election_path).and_return(edit_questions_path(election))
          allow(controller).to receive(:elections_path).and_return(elections_path)
          allow(controller).to receive(:dashboard_election_path).and_return(dashboard_path(election))
          sign_in current_user
        end

        describe "GET #new" do
          it "renders new" do
            get :new
            expect(response).to render_template(:new)
          end
        end

        describe "POST #create" do
          let(:new_election_id) { (Decidim::Elections::Election.maximum(:id) || 0) + 1 }

          it "creates and redirects" do
            allow(controller).to receive(:edit_questions_election_path).and_return(edit_questions_path(new_election_id))
            expect do
              post :create, params: { election: election_params }

              expect(response).to redirect_to(edit_questions_path(Decidim::Elections::Election.last))
              expect(flash[:notice]).to be_present
            end.to change(Election, :count).by(1)
          end

          it "renders new on error" do
            post :create, params: { election: election_params.merge(title: { en: "" }) }
            expect(response).to render_template(:new)
            expect(flash[:alert]).to be_present
          end
        end

        describe "GET #edit" do
          it "renders edit" do
            get :edit, params: { id: election.id }
            expect(response).to render_template(:edit)
          end
        end

        describe "PATCH #update" do
          it "updates and redirects" do
            patch :update, params: { id: election.id, election: election_params }
            expect(response).to redirect_to(edit_questions_path(election))
            expect(flash[:notice]).to be_present
          end

          it "renders edit on error" do
            patch :update, params: { id: election.id, election: election_params.merge(title: { en: "" }) }
            expect(response).to render_template(:edit)
            expect(flash[:alert]).to be_present
          end
        end

        describe "GET #dashboard" do
          let!(:election) { create(:election, :with_token_csv_census, component:) }
          let!(:election_question) { create(:election_question, election:) }

          it "renders dashboard page" do
            get :dashboard, params: { id: election.id }
            expect(response).to render_template(:dashboard)
          end
        end

        describe "PATCH #update_status" do
          let!(:election) { create(:election, :with_token_csv_census, component:, published_at: Time.current) }
          let!(:election_question) { create(:election_question, election:) }

          it "updates and redirects" do
            patch :update_status, params: { id: election.id, status_action: "start" }
            expect(response).to redirect_to(Decidim::EngineRouter.admin_proxy(component).dashboard_election_path(election))
            expect(flash[:notice]).to be_present
          end

          it "renders dashboard on invalid" do
            patch :update_status, params: { id: election.id, status_action: nil }
            expect(response).to render_template(:dashboard)
            expect(flash[:alert]).to be_present
          end
        end

        describe "PUT #publish" do
          let!(:election) { create(:election, :with_token_csv_census, component:) }
          let!(:question) { create(:election_question, election:) }

          it "publishes and redirects" do
            put :publish, params: { id: election.id }
            expect(response).to redirect_to(Decidim::EngineRouter.admin_proxy(component).dashboard_election_path(election))
            expect(flash[:notice]).to be_present
          end
        end

        describe "PUT #unpublish" do
          before do
            election.update!(published_at: Time.current)
          end

          it "unpublishes and redirects" do
            put :unpublish, params: { id: election.id }
            expect(response).to redirect_to(Decidim::EngineRouter.admin_proxy(component).elections_path)
            expect(flash[:notice]).to be_present
            expect(election.reload.published_at).to be_nil
          end
        end

        it_behaves_like "a soft-deletable resource",
                        resource_name: :election,
                        resource_path: :elections_path,
                        trash_path: :manage_trash_elections_path
      end
    end
  end
end
