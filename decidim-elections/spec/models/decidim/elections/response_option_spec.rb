# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe ResponseOption do
      subject { response_option }

      let(:question) { create(:election_question, with_response_options: false) }
      let(:response_option) { build(:election_response_option, question:) }

      it { is_expected.to be_valid }

      it "has an association of question" do
        expect(subject.question).to eq(question)
      end

      describe "#translated_body" do
        it "returns the translated body of the response option" do
          expect(subject.translated_body).to eq(subject.body["en"])
        end
      end
    end
  end
end
