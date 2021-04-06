# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe CreateBallotStyle do
        subject { described_class.new(form) }

        let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
        let(:user) { create :user, :admin, :confirmed, organization: organization }
        let(:election) { create :election, :complete, component: elections_component }
        let(:elections_component) { create :elections_component, participatory_space: voting }
        let(:voting) { create :voting, organization: organization }

        let(:form) do
          double(
            valid?: valid,
            code: code,
            question_ids: question_ids,
            current_participatory_space: voting
          )
        end

        let(:valid) { true }
        let(:code) { "Code" }
        let(:question_ids) { election.questions.sample(2).map(&:id) }

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
          expect(ballot_style.code).to eq code
          expect(ballot_style.questions.pluck(:id)).to match_array(question_ids)
        end

        context "when the form is not valid" do
          let(:valid) { false }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
