# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe Question do
      subject { question }

      let(:election) { create(:election) }
      let(:question) { create(:election_question, election:) }

      it { is_expected.to be_valid }

      it "has an association with election" do
        expect(subject.election).to eq(election)
      end

      it "has many response options" do
        expect(subject.response_options.count).to be_positive
      end

      describe "validations" do
        context "when question_type is invalid" do
          let(:question) { build(:election_question, election:, question_type: "invalid") }

          it { is_expected.not_to be_valid }
        end

        context "when body is missing" do
          let(:question) { build(:election_question, election:, body: {}) }

          it { is_expected.not_to be_valid }
        end
      end

      describe "#translated_body" do
        it "returns the translated body" do
          expect(subject.translated_body).to eq(subject.body["en"])
        end
      end

      describe "#number_of_options" do
        it "returns the number of associated response options" do
          expect(subject.number_of_options).to eq(subject.response_options.count)
        end
      end
    end
  end
end
