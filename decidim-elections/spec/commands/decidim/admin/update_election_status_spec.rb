# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe UpdateElectionStatus do
        subject { described_class.new(form, election) }

        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:component) { create(:elections_component, organization:) }
        let(:election) { create(:election, :with_token_csv_census, component:) }
        let(:form) do
          ElectionStatusForm.from_params(form_params).with_context(
            current_user: user,
            current_organization: organization,
            current_component: component
          )
        end
        let(:user) { create(:user, :admin, :confirmed, organization:) }

        before { create(:election_question, election:) }

        context "when form is invalid" do
          let(:form_params) { { status_action: nil } }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when starting the election" do
          let(:form_params) { { status_action: :start } }

          it "sets start_at and broadcasts :ok" do
            expect { subject.call }.to broadcast(:ok)
            expect(election.reload.start_at).to be_present
          end
        end

        context "when ending the election" do
          let(:form_params) { { status_action: :end } }

          it "sets end_at and broadcasts :ok" do
            expect { subject.call }.to broadcast(:ok)
            expect(election.reload.end_at).to be_present
          end
        end

        context "when enabling voting for a question" do
          let!(:election) { create(:election, :with_token_csv_census, component:, start_at: 1.hour.ago, end_at: 1.hour.from_now, published_at: 1.day.ago) }
          let(:question) { election.questions.first }
          let(:form_params) { { status_action: :enable_voting, question_id: question.id } }

          it "sets voting_enabled_at on the question" do
            expect { subject.call }.to broadcast(:ok)
            expect(question.reload.voting_enabled_at).to be_present
          end

          context "when question does not exist" do
            let(:form_params) { { status_action: :enable_voting, question_id: 9999 } }

            it "broadcasts :invalid" do
              expect { subject.call }.to broadcast(:invalid)
            end
          end
        end

        context "when publishing results" do
          let(:form_params) { { status_action: :publish_results } }

          context "with after_end setting" do
            let(:election) { create(:election, :with_token_csv_census, results_availability: "after_end", component:, start_at: 1.hour.ago, end_at: 10.minutes.ago, published_at: 1.day.ago) }

            it "sets published_results_at" do
              expect { subject.call }.to broadcast(:ok)
              expect(election.reload.published_results_at).to be_present
            end
          end

          context "with per_question setting" do
            let!(:election) { create(:election, :with_token_csv_census, results_availability: "per_question", component:, start_at: 1.hour.ago, end_at: 1.hour.from_now, published_at: 1.day.ago) }
            let!(:questions) { create_list(:election_question, 3, election:) }
            let(:voting_enabled_at) { 30.minutes.ago }
            let(:first_question) { questions.first }
            let(:second_question) { questions.second }

            before do
              first_question.update!(voting_enabled_at:)
            end

            it "sets published_results_at on the next eligible question" do
              expect { subject.call }.to broadcast(:ok)
              expect(first_question.reload.published_results_at).to be_present
            end

            context "when no publishable questions remain" do
              before do
                election.questions.each { |q| q.update!(published_results_at: Time.current) }
              end

              it "broadcasts :invalid" do
                expect { subject.call }.to broadcast(:invalid)
              end
            end
          end
        end
      end
    end
  end
end
