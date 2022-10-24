# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe UpdateBallotStyle do
        let(:ballot_style) { create :ballot_style }
        let(:user) { create(:user, organization: ballot_style.voting.organization) }
        let!(:other_ballot_style) { create :ballot_style, voting: ballot_style.voting, code: taken_code.upcase }
        let(:election) { create :election, :complete, component: elections_component }
        let(:elections_component) { create :elections_component, participatory_space: ballot_style.voting }
        let(:ballot_style_questions) do
          election.questions.first(2).map { |question| create(:ballot_style_question, question:, ballot_style:) }
        end
        let(:params) do
          {
            ballot_style: {
              id: ballot_style.id,
              code: updated_code,
              voting: ballot_style.voting,
              question_ids: updated_question_ids
            }
          }
        end
        let(:updated_code) { "Updated code" }
        let(:taken_code) { "Taken code" }
        let(:updated_question_ids) { election.questions.last(3).map(&:id) }
        let(:form) do
          BallotStyleForm.from_params(params).with_context(
            voting: ballot_style.voting,
            ballot_style_id: ballot_style.id,
            current_user: user
          )
        end

        subject { described_class.new(form, ballot_style) }

        context "when the form is not valid" do
          context "when the code is not present" do
            let(:updated_code) { nil }

            it "is not valid" do
              expect { subject.call }.to broadcast(:invalid)
            end
          end

          context "when the code is already in use" do
            let(:updated_code) { taken_code }

            it "is not valid" do
              expect { subject.call }.to broadcast(:invalid)
            end
          end
        end

        describe "when the form is valid" do
          it "updates the ballot style attributes" do
            expect { subject.call }.to broadcast(:ok)
            ballot_style.reload

            expect(ballot_style.code).to eq(updated_code.upcase)
          end

          it "updates the ballot style questions" do
            expect { subject.call }.to broadcast(:ok)

            ballot_style.reload
            expect(ballot_style.questions.map(&:id)).to match_array(updated_question_ids)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:update!)
              .with(ballot_style, user, hash_including(:code), visibility: "all")
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.action).to eq "update"
          end
        end
      end
    end
  end
end
