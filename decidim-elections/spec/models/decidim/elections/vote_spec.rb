# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe Vote do
      subject { vote }

      let(:question) { create(:election_question, :with_response_options) }
      let(:response_option) { question.response_options.first }
      let(:vote) { create(:election_vote, question:, response_option:) }

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      it "has an association of question" do
        expect(subject.question).to eq(question)
      end

      it "has an association of response option" do
        expect(subject.response_option).to eq(response_option)
      end

      it "can be edited" do
        expect { subject.update(response_option: question.response_options.last) }.not_to raise_error
        expect(subject.response_option).not_to eq(question.response_options.first)
        expect(subject.response_option).to eq(question.response_options.last)
      end

      describe "#voter_uid" do
        it "is read-only" do
          expect { subject.voter_uid = "new_uid" }.to raise_error(ActiveRecord::ReadonlyAttributeError)
        end
      end

      it "cannot be destroyed" do
        expect { subject.destroy! }.to raise_error(ActiveRecord::ReadOnlyRecord)
        expect(subject.reload).to be_persisted
      end

      describe "validations" do
        context "when voter_uid is missing" do
          let(:vote) { build(:election_vote, voter_uid: nil, question:, response_option:) }

          it { is_expected.not_to be_valid }
        end

        context "when question is missing" do
          let(:vote) { build(:election_vote, question: nil, response_option:) }

          it { is_expected.not_to be_valid }
        end

        context "when response option is missing" do
          let(:vote) { build(:election_vote, response_option: nil, question:) }

          it { is_expected.not_to be_valid }
        end

        context "when response option does not belong to question" do
          let(:other_question) { create(:election_question, :with_response_options) }
          let(:vote) { build(:election_vote, question:, response_option: other_question.response_options.first) }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
