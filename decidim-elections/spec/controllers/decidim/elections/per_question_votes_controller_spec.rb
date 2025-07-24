# frozen_string_literal: true

require "spec_helper"
require "decidim/elections/test/vote_controller_examples"

module Decidim
  module Elections
    describe PerQuestionVotesController do
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:component) { create(:elections_component) }
      let(:election) { create(:election, :published, :with_internal_users_census, :per_question, :ongoing, component:) }
      let!(:existing_vote) { create(:election_vote, question: question, response_option: question.response_options.first, voter_uid: "some-id") }
      let!(:question) { create(:election_question, :with_response_options, :voting_enabled, election:) }
      let!(:second_question) { create(:election_question, :with_response_options, :voting_enabled, election:) }

      let(:params) { { component_id: component.id, election_id: election.id } }
      let(:election_vote_path) { Decidim::EngineRouter.main_proxy(component).election_per_question_vote_path(election_id: election.id, id: question.id) }
      let(:second_election_vote_path) { Decidim::EngineRouter.main_proxy(component).election_per_question_vote_path(election_id: election.id, id: second_question.id) }
      let(:new_election_vote_path) { Decidim::EngineRouter.main_proxy(component).new_election_per_question_vote_path(election_id: election.id) }
      let(:new_election_normal_vote_path) { Decidim::EngineRouter.main_proxy(component).new_election_vote_path(election_id: election.id) }
      let(:election_path) { Decidim::EngineRouter.main_proxy(component).election_path(id: election.id) }
      let(:waiting_election_votes_path) { Decidim::EngineRouter.main_proxy(component).waiting_election_per_question_votes_path(election_id: election.id) }
      let(:receipt_election_votes_path) { Decidim::EngineRouter.main_proxy(component).receipt_election_per_question_votes_path(election_id: election.id) }

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
      end

      it_behaves_like "an authenticated vote controller"

      describe "GET show" do
        it_behaves_like "an unauthenticated per question vote controller", :show

        context "when the user is authenticated" do
          before do
            sign_in user
          end

          it_behaves_like "a redirect to the waiting room", :show

          it "renders the voting form" do
            get :show, params: params
            expect(response).to have_http_status(:ok)
            expect(controller.helpers.question).to eq(question)
            expect(subject).to render_template(:show)
          end
        end
      end

      describe "PATCH update" do
        it_behaves_like "an unauthenticated per question vote controller", :update do
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

          it_behaves_like "a redirect to the waiting room", :update do
            let(:params) do
              {
                component_id: component.id,
                election_id: election.id,
                id: question.id
              }
            end
          end

          it "sets a flash error and redirect to itself if no response is given" do
            expect(controller).to receive(:redirect_to).with(action: :show, id: question)
            patch :update, params: params.merge(id: question.id)
            expect(flash[:alert]).to eq(I18n.t("votes.cast.invalid", scope: "decidim.elections"))
            expect(response).to have_http_status(:no_content)
          end

          it "sets a flash error and redirect to next question if no response is given and the question is not voting enabled" do
            question.update(voting_enabled_at: nil)
            expect(controller).to receive(:redirect_to).with(action: :show, id: second_question)
            patch :update, params: params.merge(id: question.id)
            expect(flash[:alert]).to eq(I18n.t("votes.cast.invalid", scope: "decidim.elections"))
            expect(response).to have_http_status(:no_content)
          end

          it "casts the votes and redirects to the receipt page if successful" do
            # ensure there are no pending votes
            allow(controller).to receive(:votes_buffer).and_return({ question.id.to_s => [question.response_options.first.id], second_question.id.to_s => [second_question.response_options.first.id] })

            expect(controller).to receive(:redirect_to).with(action: :receipt)
            patch :update, params: params.merge(id: question.id, response: { question.id.to_s => [question.response_options.first.id] })
            expect(session[:voter_uid]).to eq(user.to_global_id.to_s)
            expect(flash[:notice]).to eq(I18n.t("votes.cast.success", scope: "decidim.elections"))
          end
        end
      end

      describe "GET waiting" do
        it_behaves_like "an unauthenticated per question vote controller", :waiting

        context "when the user is authenticated" do
          before do
            sign_in user
          end

          it "redirects to the next question" do
            create(:election_vote, voter_uid: user.to_global_id.to_s, question:, response_option: question.response_options.first)
            allow(controller).to receive(:votes_buffer).and_return({ question.id.to_s => [question.response_options.first.id] })

            expect(controller).to receive(:redirect_to).with(action: :show, id: second_question)
            get :waiting, params: params
            expect(response).to have_http_status(:ok)
          end

          context "when waiting for next question" do
            before do
              second_question.update(voting_enabled_at: nil)
            end

            it "redirects to the non voted question" do
              expect(controller).to receive(:redirect_to).with(action: :show, id: question)
              get :waiting, params: params
              expect(response).to have_http_status(:ok)
            end

            context "when all non pending questions have been voted" do
              let!(:vote) { create(:election_vote, voter_uid: user.to_global_id.to_s, question:, response_option: question.response_options.first) }

              it "redirects to the non voted question" do
                expect(controller).to receive(:redirect_to).with(action: :show, id: question)
                get :waiting, params: params
                expect(response).to have_http_status(:ok)
              end

              it "renders the waiting page if votes_buffer exist" do
                allow(controller).to receive(:votes_buffer).and_return({ question.id.to_s => [question.response_options.first.id] })
                get :waiting, params: params
                expect(response).to have_http_status(:ok)
                expect(subject).to render_template(:waiting)
              end
            end
          end

          context "when json format is requested" do
            it "returns the next question URL" do
              create(:election_vote, voter_uid: user.to_global_id.to_s, question:, response_option: question.response_options.first)
              allow(controller).to receive(:votes_buffer).and_return({ question.id.to_s => [question.response_options.first.id] })

              expect(controller).to receive(:url_for).with(action: :show, id: second_question)
              get :waiting, params: params, format: :json
              expect(response).to have_http_status(:ok)
              expect(JSON.parse(response.body)).to have_key("url")
            end
          end
        end
      end

      describe "GET receipt" do
        it_behaves_like "an unauthenticated per question vote controller", :receipt

        context "when the user is authenticated" do
          before do
            sign_in user
          end

          context "when session voter UID is set" do
            before do
              # ensure there are no pending votes
              allow(controller).to receive(:votes_buffer).and_return({ question.id.to_s => [question.response_options.first.id], second_question.id.to_s => [second_question.response_options.first.id] })
              session[:voter_uid] = user.to_global_id.to_s
            end

            it "redirects to the election path" do
              get :receipt, params: params
              expect(response).to redirect_to(election_path)
            end

            context "when the election has votes for the voter UID" do
              before do
                create(:election_vote, voter_uid: session[:voter_uid], question: question, response_option: question.response_options.first)
                create(:election_vote, voter_uid: session[:voter_uid], question: second_question, response_option: second_question.response_options.first)
              end

              it_behaves_like "a redirect to the waiting room", :receipt

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
end
