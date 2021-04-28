# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe DestroyBallotStyle do
        subject { described_class.new(ballot_style) }

        let(:voting) { create(:voting) }
        let(:ballot_style) { create :ballot_style, voting: voting }
        let(:election) { create :election, :complete, component: elections_component }
        let(:elections_component) { create :elections_component, participatory_space: voting }
        let!(:ballot_style_questions) do
          election.questions.map { |question| create(:ballot_style_question, question: question, ballot_style: ballot_style) }
        end

        context "when everything is ok" do
          it "destroys the ballot style" do
            subject.call

            expect { ballot_style.reload }.to raise_error(ActiveRecord::RecordNotFound)
          end

          it "destroys the ballot style questions" do
            subject.call

            expect(Decidim::Votings::BallotStyleQuestion.where(decidim_votings_ballot_style_id: ballot_style.id).count).to eq 0
          end
        end
      end
    end
  end
end
