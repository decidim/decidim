# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe CreateBallotStyle do
        subject { described_class.new(form) }

        let(:user) { create :user, :admin, :confirmed }
        let(:election) { create :election, :complete, component: elections_component }
        let(:elections_component) { create :elections_component, participatory_space: voting }
        let(:voting) { create :voting, organization: user.organization }

        let(:form) do
          double(
            valid?: valid,
            code: code,
            question_ids: question_ids,
            current_participatory_space: voting,
            errors: errors
          )
        end

        let(:valid) { true }
        let(:code) { "Code".upcase }
        let(:question_ids) { election.questions.sample(2).map(&:id) }
        let(:errors) { double.as_null_object }

        let(:ballot_style) { Decidim::Votings::BallotStyle.last }

        it "creates the ballot style" do
          expect { subject.call }.to change { Decidim::Votings::BallotStyle.count }.by(1)
        end

        it "creates the association between ballot style and questions" do
          expect { subject.call }.to change { Decidim::Votings::BallotStyleQuestion.count }.by(2)
        end

        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "stores the given data" do
          subject.call
          expect(ballot_style.code).to eq code.upcase
          expect(ballot_style.questions.pluck(:id)).to match_array(question_ids)
        end

        context "when the form is not valid" do
          let(:valid) { false }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when a ballot style with the same code exists" do
          context "when it's in the same voting" do
            let!(:existing_ballot_style) { create(:ballot_style, voting: voting, code: code) }

            it "is not valid" do
              expect(errors).to receive(:add).with(:code, :taken)
              expect { subject.call }.to broadcast(:invalid)
            end
          end

          context "when it's in another voting" do
            let!(:existing_ballot_style) { create(:ballot_style, code: code) }

            it "is valid" do
              expect { subject.call }.to broadcast(:ok)
            end
          end
        end
      end
    end
  end
end
