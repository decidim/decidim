# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe ApplicationHelper do
      describe "#question_description" do
        subject(:rendered_description) { helper.question_description(question, :span, class: "question__description") }

        context "when the description is blank" do
          let(:question) { build(:election_question, description: { "en" => "" }) }

          it { is_expected.to be_nil }
        end

        context "when the description has plain text" do
          let(:question) { create(:election_question, description: { "en" => "More info" }) }

          it { is_expected.to eq('<span class="question__description">More info</span>') }
        end

        context "when the description includes markup" do
          let(:question) { build(:election_question, description: { "en" => "<strong>Intro</strong>" }) }

          it "keeps the allowed tags" do
            expect(rendered_description).to eq('<span class="question__description"><strong>Intro</strong></span>')
          end
        end
      end
    end
  end
end
