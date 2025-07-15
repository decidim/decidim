# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe ResponseOption do
      subject { response_option }

      let(:question) { create(:election_question) }
      let(:response_option) { create(:election_response_option, :with_votes, question:) }

      it { is_expected.to be_valid }

      it "has an association of question" do
        expect(subject.question).to eq(question)
      end

      it "has many votes" do
        expect(subject.votes.count).to be_positive
      end

      describe "validations" do
        context "when body is missing" do
          let(:response_option) { build(:election_response_option, question:, body: {}) }

          it { is_expected.not_to be_valid }
        end
      end

      describe "#presenter" do
        it "returns a presenter instance" do
          expect(subject.presenter).to be_a(Decidim::Elections::ResponseOptionPresenter)
        end
      end

      context "when destroying" do
        it "raises an error" do
          expect { subject.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
          expect(subject.reload).to be_persisted
        end

        context "when destroying without votes" do
          let(:response_option) { create(:election_response_option, question:) }

          it "does not raise an error" do
            expect { subject.destroy! }.not_to raise_error
          end
        end
      end
    end
  end
end
