# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe VotesHelper do
      let(:question) { create :question, :complete, answers: 3, random_answers_order: }
      let(:random_answers_order) { true }

      let(:helper) do
        Class.new(ActionView::Base) do
          include VotesHelper
          include TranslatableAttributes
        end.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, [])
      end

      describe "ordered_answers" do
        subject(:uniq_results) { repetitions.times.map { helper.ordered_answers(question) }.uniq }

        let(:repetitions) { 100 }

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

      describe "more_information?" do
        let(:answer) { question.answers.first }
        let(:show_more_information) { helper.more_information?(answer) }

        context "when the answer has a description" do
          before do
            answer.description = { "en" => "Description" }
            answer.save!
          end

          it "returns true" do
            expect(show_more_information).to be_truthy
          end
        end

        context "when the answer has no description" do
          before do
            answer.description = {}
            answer.save!
          end

          it "returns false" do
            expect(show_more_information).to be_falsey
          end
        end
      end
    end
  end
end
