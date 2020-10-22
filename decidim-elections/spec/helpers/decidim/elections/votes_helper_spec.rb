# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe VotesHelper do
      describe "ordered_answers" do
        subject(:uniq_results) { repetitions.times.map { helper.ordered_answers(question) }.uniq }

        let(:question) { create :question, :complete, answers: 3, random_answers_order: random_answers_order }
        let(:repetitions) { 100 }
        let(:random_answers_order) { true }

        it "orders answers in different order on different calls" do
          # This test could randomly fail with a very low probability (6*(5.0/6)**100, or 1 of 13.802.995 times)
          expect(uniq_results.length).to eq 6
        end

        context "when random order is disabled" do
          let(:repetitions) { 10 }
          let(:random_answers_order) { false }

          it "orders answers with the same order on every calls" do
            # This test could randomly result on a false positive with a very low probability ((1.0/6)**9, or 1 of 10.077.696 tiems)
            expect(uniq_results.length).to eq(1)
          end

          it "orders answers by weight and creation order" do
            ordered_ids = question.answers.map { |question| [question.weight, question.id] }.sort.map(&:last)

            expect(uniq_results.first.map(&:id)).to eq(ordered_ids)
          end
        end
      end
    end
  end
end
