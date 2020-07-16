# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe VotesHelper do
      describe "ordered_answers" do
        subject(:uniq_results) { repetitions.times.map { helper.ordered_answers(question) } .uniq }

        let(:repetitions) { 100 }
        let(:question) { create :question, :complete, answers: 3 }

        it "orders answers in different order on different calls" do
          # with 100 repetitions, this test could result on a false negative on 1 of 13.802.995 executions: 1.0/(6*(5.0/6)**100)
          expect(uniq_results.length).to eq 6
        end

        context "when random order is disabled" do
          let(:question) { create :question, :complete, answers: 20, random_answers_order: false }
          let(:repetitions) { 10 }

          it "orders answers with the same order on every calls" do
            # with 10 repetitions, this test could result on a false positive on 1 of 10.077.696 executions: 1.0/(1.0/6)**9
            expect(uniq_results.length).to eq(1)
          end

          it "orders answers by weight and creation order" do
            ordered_ids = question.answers.map { |question| [question.weight, question.id] } .sort.map(&:last)

            expect(uniq_results.first.map(&:id)).to eq(ordered_ids)
          end
        end
      end
    end
  end
end
