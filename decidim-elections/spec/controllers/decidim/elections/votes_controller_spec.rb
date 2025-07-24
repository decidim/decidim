# frozen_string_literal: true

require "spec_helper"
require "decidim/elections/test/vote_controller_examples"

module Decidim
  module Elections
    describe VotesController do
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:component) { create(:elections_component) }
      let(:election) { create(:election, :published, :with_internal_users_census, :ongoing, component:) }
      let!(:existing_vote) { create(:election_vote, question: question, response_option: question.response_options.first, voter_uid: "some-id") }
      let!(:question) { create(:election_question, :with_response_options, :voting_enabled, election:) }
      let!(:second_question) { create(:election_question, :with_response_options, :voting_enabled, election:) }

      let(:params) do
        {
          component_id: component.id,
          election_id: election.id
        }
      end
      let(:election_vote_path) { Decidim::EngineRouter.main_proxy(component).election_vote_path(election_id: election.id, id: question.id) }
      let(:second_election_vote_path) { Decidim::EngineRouter.main_proxy(component).election_vote_path(election_id: election.id, id: second_question.id) }
      let(:new_election_vote_path) { Decidim::EngineRouter.main_proxy(component).new_election_vote_path(election_id: election.id) }
      let(:new_election_per_question_vote_path) { Decidim::EngineRouter.main_proxy(component).new_election_per_question_vote_path(election_id: election.id) }
      let(:election_path) { Decidim::EngineRouter.main_proxy(component).election_path(id: election.id) }
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
        allow(controller).to receive(:receipt_election_votes_path).and_return(receipt_election_votes_path)
        allow(controller).to receive(:confirm_election_votes_path).and_return(confirm_election_votes_path)
      end

      it_behaves_like "an authenticated vote controller"

      describe "GET show" do
        it_behaves_like "an unauthenticated vote controller", :show
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

        context "when specific question is requested" do
          it "renders the voting form for the specific question" do
            get :show, params: params.merge(id: second_question.id)
            expect(response).to have_http_status(:ok)
            expect(controller.helpers.question).to eq(second_question)
            expect(subject).to render_template(:show)
          end
        end
      end

      describe "PATCH update" do
        it_behaves_like "an unauthenticated vote controller", :update do
          let(:params) do
            {
              component_id: component.id,
              election_id: election.id,
              id: question.id
            }
          end
        end

        context "when the user is authenticated" do
          before do
            sign_in user
          end

          it "saves the vote and redirects to the next question" do
            patch :update, params: params.merge(id: question.id)
            expect(session[:votes_buffer]).to eq({ question.id.to_s => nil })
            expect(response).to redirect_to(election_vote_path)
          end

          it "redirects to the confirm page if no next question is available" do
            session[:votes_buffer] = { question.id.to_s => nil }
            patch :update, params: params.merge(id: second_question.id)
            expect(session[:votes_buffer]).to eq({ question.id.to_s => nil, second_question.id.to_s => nil })
            expect(response).to redirect_to(confirm_election_votes_path)
          end
        end
      end

      describe "GET confirm" do
        it_behaves_like "an unauthenticated vote controller", :confirm

        context "when the user is authenticated" do
          before do
            sign_in user
          end

          it "renders the confirmation page" do
            get :confirm, params: params
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:confirm)
          end
        end
      end

      describe "PATCH cast" do
        it_behaves_like "an unauthenticated vote controller", :cast

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

          it_behaves_like "an unauthenticated vote controller", :receipt

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
