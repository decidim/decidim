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

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        def edit_questions_election_path(election)
          Decidim::EngineRouter.admin_proxy(component).edit_questions_election_path(election)
        end

        def elections_path
          Decidim::EngineRouter.admin_proxy(component).elections_path
        end

        describe "POST create" do
          let(:new_election_id) { (Decidim::Elections::Election.maximum(:id) || 0) + 1 }

          it "creates the election and redirects" do
            allow(controller).to receive(:edit_questions_election_path).and_return(edit_questions_election_path(new_election_id))

            post :create, params: { election: election_params }

            expect(response).to redirect_to(edit_questions_election_path(Decidim::Elections::Election.last))
            expect(flash[:notice]).to be_present
          end

          it "renders the form with errors when title is blank" do
            post :create, params: { election: election_params.merge(title: { en: "" }) }

            expect(response).to render_template(:new)
            expect(flash[:alert]).to be_present
          end
        end

        describe "PATCH update" do
          it "updates the election and redirects" do
            allow(controller).to receive(:edit_questions_election_path).and_return(edit_questions_election_path(election))
            patch :update, params: { id: election.id, election: election_params.merge(title: { en: "Updated title" }) }

            expect(response).to redirect_to(edit_questions_election_path(election))
            expect(flash[:notice]).to be_present
          end

          it "renders edit with errors when title is blank" do
            patch :update, params: { id: election.id, election: election_params.merge(title: { en: "" }) }

            expect(response).to render_template(:edit)
            expect(flash[:alert]).to be_present
          end
        end

        describe "PUT publish" do
          context "when the election is not published yet" do
            let!(:election) { create(:election, component:, published_at: nil) }

            it "publishes the election and redirects" do
              allow(controller).to receive(:elections_path).and_return(elections_path)

              put :publish, params: { id: election.id }

              expect(response).to redirect_to(elections_path)
              expect(flash[:notice]).to be_present
              expect(election.reload).to be_published
            end
          end

          context "when the election is already published" do
            it "renders index with error when publish fails" do
              put :publish, params: { id: election.id }

              expect(response).to render_template(:index)
              expect(flash[:alert]).to be_present
            end
          end
        end

        describe "PUT unpublish" do
          context "when the election is published" do
            it "unpublishes the election and redirects" do
              allow(controller).to receive(:elections_path).and_return(elections_path)

              put :unpublish, params: { id: election.id }

              expect(response).to redirect_to(elections_path)
              expect(flash[:notice]).to be_present
              expect(election.reload).not_to be_published
            end
          end

          context "when the election is already unpublished" do
            let!(:election) { create(:election, component:, published_at: nil) }

            it "renders index with error when unpublish fails" do
              put :unpublish, params: { id: election.id }

              expect(response).to render_template(:index)
              expect(flash[:alert]).to be_present
            end
          end
        end
      end
    end
  end
end
