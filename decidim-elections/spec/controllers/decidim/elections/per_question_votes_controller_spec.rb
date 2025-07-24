# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe VotesController do
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:component) { create(:elections_component) }
      let(:election) { create(:election, :published, :with_internal_users_census, :ongoing, component:) }
      let!(:existing_vote) { create(:election_vote, question: question, response_option: question.response_options.first, voter_uid: "some-id") }
      let!(:question) { create(:election_question, :with_response_options, :voting_enabled, election:) }
      let!(:second_question) { create(:election_question, :with_response_options, :voting_enabled, election:) }

      let(:params) { { component_id: component.id, election_id: election.id } }
      let(:election_vote_path) { Decidim::EngineRouter.main_proxy(component).election_vote_path(election_id: election.id, id: question.id) }
      let(:second_election_vote_path) { Decidim::EngineRouter.main_proxy(component).election_vote_path(election_id: election.id, id: second_question.id) }
      let(:new_election_vote_path) { Decidim::EngineRouter.main_proxy(component).new_election_vote_path(election_id: election.id) }
      let(:election_path) { Decidim::EngineRouter.main_proxy(component).election_path(id: election.id) }
      let(:waiting_election_votes_path) { Decidim::EngineRouter.main_proxy(component).waiting_election_votes_path(election_id: election.id) }
      let(:receipt_election_votes_path) { Decidim::EngineRouter.main_proxy(component).receipt_election_votes_path(election_id: election.id) }
      let(:confirm_election_votes_path) { Decidim::EngineRouter.main_proxy(component).confirm_election_votes_path(election_id: election.id) }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        allow(controller).to receive(:current_participatory_space).and_return(component.participatory_space)
        allow(controller).to receive(:current_component).and_return(component)
        allow(controller).to receive(:election_vote_path).and_return(election_vote_path)
        allow(controller).to receive(:new_election_vote_path).and_return(new_election_vote_path)
        allow(controller).to receive(:election_path).and_return(election_path)
        allow(controller).to receive(:waiting_election_votes_path).and_return(waiting_election_votes_path)
        allow(controller).to receive(:receipt_election_votes_path).and_return(receipt_election_votes_path)
        allow(controller).to receive(:confirm_election_votes_path).and_return(confirm_election_votes_path)
      end

      describe "GET new" do
        it "renders the new vote form" do
          get :new, params: params
          expect(response).to have_http_status(:ok)
          expect(assigns(:form)).to be_a(Decidim::Elections::Censuses::InternalUsersForm)
          expect(subject).to render_template(:new)
        end

        context "when the user is authenticated" do
          before do
            sign_in user
          end

          it "redirects to the question path" do
            get :new, params: params
            expect(response).to redirect_to(election_vote_path)
          end
        end
      end

      describe "POST create" do
        it "renders the new form with errors when the form is invalid" do
          post :create, params: params

          expect(controller.send(:session_authenticated?)).to be false
          expect(controller.send(:voter_uid)).to be_nil
          expect(response).to redirect_to(new_election_vote_path)
          expect(flash[:alert]).to be_present
        end

        context "with valid form data" do
          before do
            sign_in user
          end

          it "creates the session credentials and redirects to the question path" do
            post :create, params: params

            expect(session[:session_attributes]).to be_present
            expect(controller.send(:session_authenticated?)).to be true
            expect(controller.send(:voter_uid)).to eq(user.to_global_id.to_s)
            expect(response).to redirect_to(election_vote_path)
          end
        end
      end

      describe "GET show" do
        it "redirects to the election path" do
          get :show, params: params
          expect(response).to redirect_to(election_path)
        end

        context "when the user is authenticated" do
          before do
            sign_in user
          end

          it "renders the voting form" do
            get :show, params: params
            expect(response).to have_http_status(:ok)
            expect(controller.helpers.question).to eq(question)
            expect(subject).to render_template(:show)
          end

          it "redirects to the waiting page if waiting for next question" do
            allow(controller).to receive(:waiting_for_next_question?).and_return(true)
            get :show, params: params
            expect(response).to redirect_to(waiting_election_votes_path)
          end

          context "when specific question is requested" do
            it "renders the voting form for the specific question" do
              get :show, params: params.merge(id: second_question.id)
              expect(response).to have_http_status(:ok)
              expect(controller.helpers.question).to eq(second_question)
              expect(subject).to render_template(:show)
            end

            it "shows the next question if not available" do
              election.update(results_availability: "per_question")
              question.update(voting_enabled_at: nil)
              get :show, params: params.merge(id: question.id)
              expect(response).to have_http_status(:ok)
              expect(controller.helpers.question).to eq(second_question)
            end
          end
        end
      end

      describe "PATCH update" do
        it "redirects to the election path" do
          get :show, params: params
          expect(response).to redirect_to(election_path)
        end

        context "when the user is authenticated" do
          before do
            sign_in user
          end

          it "saves the vote and redirects to the next question" do
            patch :update, params: params.merge(id: question.id)
            expect(response).to redirect_to(election_vote_path)
          end

          it "redirects to the waiting page if waiting for next question" do
            allow(controller).to receive(:waiting_for_next_question?).and_return(true)
            patch :update, params: params.merge(id: question.id)
            expect(response).to redirect_to(waiting_election_votes_path)
          end

          it "redirects to the confirm page if no next question is available" do
            allow(controller).to receive(:next_pending_question).and_return(nil)
            patch :update, params: params.merge(id: question.id)
            expect(response).to redirect_to(confirm_election_votes_path)
          end

          context "when the election is per-question" do
            before do
              election.update(results_availability: "per_question")
            end

            it "does not cast the vote and reloads if invalid" do
              patch :update, params: params.merge(id: question.id)
              expect(response).to redirect_to(election_vote_path)
            end

            it "casts the votes and redirects to the receipt page if successful" do
              # ensure there are no pending votes
              allow(controller).to receive(:next_pending_question).and_return(nil)

              patch :update, params: params.merge(id: question.id, response: { question.id.to_s => [question.response_options.first.id] })
              expect(session[:voter_uid]).to eq(user.to_global_id.to_s)
              expect(response).to redirect_to(receipt_election_votes_path)
              expect(flash[:notice]).to eq(I18n.t("votes.cast.success", scope: "decidim.elections"))
            end

            it "redirects to next question if not available" do
              question.update(voting_enabled_at: nil)
              patch :update, params: params.merge(id: question.id, response: { question.id.to_s => [question.response_options.first.id] })
              expect(session[:voter_uid]).to be_nil
              expect(response).to redirect_to(election_vote_path)
            end
          end
        end
      end

      describe "GET waiting" do
        it "redirects to the election path" do
          get :show, params: params
          expect(response).to redirect_to(election_path)
        end

        context "when the user is authenticated" do
          before do
            sign_in user
          end

          it "redirects to the next question" do
            get :waiting, params: params
            expect(response).to redirect_to(election_vote_path)
          end

          context "when the election is per-question" do
            before do
              election.update(results_availability: "per_question")
            end

            it "redirects to the next question" do
              get :waiting, params: params
              expect(response).to redirect_to(election_vote_path)
            end

            context "when waiting for next question" do
              before do
                second_question.update(voting_enabled_at: false)
              end

              it "redirects to the non voted question" do
                get :waiting, params: params
                expect(response).to redirect_to(election_vote_path)
              end

              context "when all non pending questions have been voted" do
                let!(:vote) { create(:election_vote, voter_uid: user.to_global_id.to_s, question:, response_option: question.response_options.first) }

                it "renders the waiting page" do
                  get :waiting, params: params
                  expect(response).to have_http_status(:ok)
                  expect(subject).to render_template(:waiting)
                end
              end
            end
          end

          context "when json format is requested" do
            it "returns the next question URL" do
              get :waiting, params: params, format: :json
              expect(response).to have_http_status(:ok)
              expect(JSON.parse(response.body)["url"]).to eq(election_vote_path)
            end
          end
        end
      end

      describe "GET confirm" do
        it "redirects to the election path" do
          get :confirm, params: params
          expect(response).to redirect_to(election_path)
        end

        context "when the user is authenticated" do
          before do
            sign_in user
          end

          it "renders the confirmation page" do
            get :confirm, params: params
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:confirm)
          end

          it "redirects to the waiting page if per-question election" do
            election.update(results_availability: "per_question")
            get :confirm, params: params
            expect(response).to redirect_to(waiting_election_votes_path)
          end
        end
      end

      describe "PATCH cast" do
        it "redirects to the election path" do
          post :cast, params: params
          expect(response).to redirect_to(election_path)
        end

        context "when the user is authenticated" do
          let(:votes_buffer) do
            {
              question.id.to_s => [question.response_options.first.id],
              second_question.id.to_s => [second_question.response_options.first.id]
            }
          end

          before do
            sign_in user
            allow(controller).to receive(:votes_buffer).and_return(votes_buffer)
          end

          it "casts the votes and redirects to the receipt page" do
            expect(controller.send(:votes_buffer)).to receive(:clear)
            expect(controller.send(:session_attributes)).to receive(:clear)
            post :cast, params: params
            expect(session[:voter_uid]).to eq(user.to_global_id.to_s)
            expect(response).to redirect_to(receipt_election_votes_path)
            expect(flash[:notice]).to eq(I18n.t("votes.cast.success", scope: "decidim.elections"))
          end

          context "when the votes are incomplete" do
            let(:votes_buffer) do
              {
                question.id.to_s => [question.response_options.first.id]
              }
            end

            it "redirects to the confirm page if votes are incomplete" do
              post :cast, params: params
              expect(response).to redirect_to(confirm_election_votes_path)
              expect(flash[:alert]).to eq(I18n.t("votes.cast.invalid", scope: "decidim.elections"))
            end
          end
        end
      end

      describe "GET receipt" do
        it "redirects to the election path" do
          get :receipt, params: params
          expect(response).to redirect_to(election_path)
        end

        context "when the user is authenticated" do
          before do
            sign_in user
          end

          it "redirects to the election path" do
            get :receipt, params: params
            expect(response).to redirect_to(election_path)
          end
        end

        context "when session voter UID is set" do
          before do
            session[:voter_uid] = user.to_global_id.to_s
          end

          it "redirects to the election path" do
            get :receipt, params: params
            expect(response).to redirect_to(election_path)
          end

          context "when the election has votes for the voter UID" do
            before do
              create(:election_vote, voter_uid: session[:voter_uid], question: question, response_option: question.response_options.first)
            end

            it "renders the receipt page" do
              expect(controller.send(:votes_buffer)).to receive(:clear)
              expect(controller.send(:session_attributes)).to receive(:clear)
              get :receipt, params: params
              expect(response).to have_http_status(:ok)
              expect(subject).to render_template(:receipt)
            end
          end
        end
      end
    end
  end
end
